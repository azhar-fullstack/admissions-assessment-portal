-- Upgrade an EXISTING Admissions Portal database to Primary 1–6 + portal fields.
-- Safe to re-run. Does not delete student or assessment rows.

-- Allow Primary 6
alter table public.assessments drop constraint if exists assessments_class_level_check;
alter table public.assessments add constraint assessments_class_level_check check (class_level between 1 and 6);

-- New student columns
alter table public.students add column if not exists age text;
alter table public.students add column if not exists updated_at timestamptz not null default now();

-- New assessment columns
alter table public.assessments add column if not exists admission_year text not null default '';
alter table public.assessments add column if not exists recommendation text;
alter table public.assessments add column if not exists updated_by uuid references auth.users(id);

-- Staff profiles
create table if not exists public.staff_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  role text not null default 'staff' check (role in ('admin', 'staff')),
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists students_set_updated_at on public.students;
create trigger students_set_updated_at
before update on public.students
for each row execute function public.set_updated_at();

drop trigger if exists assessments_set_updated_at on public.assessments;
create trigger assessments_set_updated_at
before update on public.assessments
for each row execute function public.set_updated_at();

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.staff_profiles (id, full_name, role, is_active)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', new.email),
    'staff',
    true
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

-- Backfill staff profiles for existing auth users
insert into public.staff_profiles (id, full_name, role)
select u.id, coalesce(u.raw_user_meta_data->>'full_name', u.email), 'staff'
from auth.users u
on conflict (id) do nothing;

create or replace function public.is_active_staff()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.staff_profiles sp
    where sp.id = auth.uid() and sp.is_active = true
  );
$$;

alter table public.staff_profiles enable row level security;
alter table public.students enable row level security;
alter table public.assessments enable row level security;

drop policy if exists "staff read own profile" on public.staff_profiles;
create policy "staff read own profile" on public.staff_profiles
for select to authenticated
using (id = auth.uid() or public.is_active_staff());

drop policy if exists "staff insert own profile" on public.staff_profiles;
create policy "staff insert own profile" on public.staff_profiles
for insert to authenticated
with check (id = auth.uid() and role = 'staff' and is_active = true);

-- No client UPDATE on staff_profiles (prevents privilege escalation).
drop policy if exists "staff update own profile" on public.staff_profiles;

drop policy if exists "authenticated staff students" on public.students;
create policy "authenticated staff students" on public.students
for all to authenticated
using (public.is_active_staff())
with check (public.is_active_staff());

drop policy if exists "authenticated staff assessments" on public.assessments;
create policy "authenticated staff assessments" on public.assessments
for all to authenticated
using (public.is_active_staff())
with check (public.is_active_staff());

create index if not exists students_full_name_idx on public.students (lower(full_name));
create index if not exists assessments_admission_year_idx on public.assessments (admission_year);
create index if not exists assessments_status_idx on public.assessments (status);
