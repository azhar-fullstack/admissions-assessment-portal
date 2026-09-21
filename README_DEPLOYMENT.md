# Admissions Assessment Portal — Deployment

## Live URL

https://azhar-fullstack.github.io/admissions-assessment-portal/

## Staff sign-in

Sign in with a staff account from **Supabase → Authentication** (public sign-up is disabled).

Workflow: Dashboard → New Assessment → student → Primary 1–6 → save/resume → complete → report → print.

## Supabase

- Project URL + anon key are in `config.js`
- Schema: `supabase-schema.sql` (already applied)
- Auth Site URL points at the live GitHub Pages URL
- Never put the **service_role** key in the website

## Security

- RLS: only authenticated active staff can read/write students and assessments
- Answer keys are hidden in the assessment UI
- Staff role changes must be done in the SQL Editor
