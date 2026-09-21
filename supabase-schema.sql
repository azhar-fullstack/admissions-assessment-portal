-- Admissions Assessment Portal: Supabase schema (Primary 1–6)
-- Run this in a NEW Supabase project's SQL Editor.
-- For an existing project that already ran an older schema, use MIGRATION_FROM_EXISTING.sql instead.

create extension if not exists pgcrypto;

-- ---------------------------------------------------------------------------
-- Staff profiles (linked to auth.users)
-- ---------------------------------------------------------------------------
create table if not exists public.staff_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  role text not null default 'staff' check (role in ('admin', 'staff')),
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Students
-- ---------------------------------------------------------------------------
create table if not exists public.students (
  id uuid primary key default gen_random_uuid(),
  full_name text not null,
  dob date,
  age text,
  guardian text,
  previous_school text,
  home_language text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references auth.users(id)
);

create index if not exists students_full_name_idx on public.students (lower(full_name));
create index if not exists students_created_at_idx on public.students (created_at desc);

-- ---------------------------------------------------------------------------
-- Assessments
-- Student → Admission Year → Class Applied For → Assessment → Scores / Observations / Recommendation
-- ---------------------------------------------------------------------------
create table if not exists public.assessments (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.students(id) on delete cascade,
  admission_year text not null default '',
  class_level int not null check (class_level between 1 and 6),
  assessment_date date not null default current_date,
  status text not null default 'in_progress' check (status in ('in_progress', 'completed')),
  responses jsonb not null default '{}'::jsonb,
  teacher_narrative text,
  score_summary jsonb not null default '{}'::jsonb,
  recommendation text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references auth.users(id),
  updated_by uuid references auth.users(id)
);

create index if not exists assessments_student_id_idx on public.assessments (student_id);
create index if not exists assessments_date_idx on public.assessments (assessment_date desc);
create index if not exists assessments_class_idx on public.assessments (class_level);
create index if not exists assessments_status_idx on public.assessments (status);
create index if not exists assessments_admission_year_idx on public.assessments (admission_year);

-- ---------------------------------------------------------------------------
-- updated_at helper
-- ---------------------------------------------------------------------------
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

-- Auto-create staff profile when a user signs up / is invited
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  -- Always create as staff. Promote admins only via SQL Editor (service role / postgres).
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

-- ---------------------------------------------------------------------------
-- Row Level Security
-- Authenticated active staff may read/write student and assessment records.
-- Answer keys are NOT stored in the database (only in the static question bank
-- for client-side scoring). Anonymous users have no access.
-- ---------------------------------------------------------------------------
alter table public.staff_profiles enable row level security;
alter table public.students enable row level security;
alter table public.assessments enable row level security;

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

drop policy if exists "staff read own profile" on public.staff_profiles;
create policy "staff read own profile" on public.staff_profiles
for select to authenticated
using (id = auth.uid() or public.is_active_staff());

-- Bootstrap insert: staff only, active only (prevents self-promotion to admin).
drop policy if exists "staff insert own profile" on public.staff_profiles;
create policy "staff insert own profile" on public.staff_profiles
for insert to authenticated
with check (id = auth.uid() and role = 'staff' and is_active = true);

-- No UPDATE policy: role / is_active changes must be done in the SQL Editor.
-- (Prevents privilege escalation via the anon key + user JWT.)
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

-- NOTE: After creating the first Auth user in the Supabase dashboard, run:
--   insert into public.staff_profiles (id, full_name, role)
--   values ('<USER_UUID>', 'Admin Name', 'admin')
--   on conflict (id) do update set role = 'admin', is_active = true;
-- Or rely on the auth.users trigger (creates role 'staff' by default).
-- Promote an admin with:
--   update public.staff_profiles set role = 'admin' where id = '<USER_UUID>';
