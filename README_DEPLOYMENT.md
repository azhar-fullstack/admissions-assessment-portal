# Admissions Assessment Portal — Deployment

## Live app

1. Serve the `class_admissions_portal` folder over HTTPS (or local HTTP for testing):
   ```
   python -m http.server 8770
   ```
2. Open the site and sign in with a staff account from **Supabase → Authentication**.
3. Workflow: Dashboard → New Assessment → student → Primary 1–6 → save/resume → complete → report → print.

## Supabase (already configured)

- Project URL + anon key are in `config.js`
- Schema: run `supabase-schema.sql` on a new project (already applied on the live project)
- Public sign-up: disabled
- Never put the **service_role** key in the website

## Static hosting

Deploy the entire folder together (all files required):

- Netlify / Vercel / Cloudflare Pages / GitHub Pages / school web server
- Publish directory = `class_admissions_portal` (or the folder that contains `index.html`)

## Security

- RLS: only authenticated active staff can read/write students and assessments
- Answer keys are hidden in the assessment UI (not displayed to staff during scoring)
- Staff role changes must be done in the SQL Editor
