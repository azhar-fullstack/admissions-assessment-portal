# School Portals — Phase 2

## Live URL
https://azhar-fullstack.github.io/admissions-assessment-portal/

## Access links
| Portal | Path |
|---|---|
| Landing (all portals) | `/` |
| Child admission application | `/apply-child/` |
| Adult education application | `/apply-adult/` |
| Staff job application | `/jobs/` |
| STEM discovery quiz | `/quiz-stem/` |
| Adult skills quiz | `/quiz-adult/` |
| Staff child assessments (Primary 1–6) | `/assess/` |

## SQL installed
All client SQL files live in `sql/` and were applied to Supabase:
- Child admission (`meg_adm_v1_*`)
- Adult admission (`meg_adult_adm_v1_*`)
- Staff jobs (`meg_jobs_v1_*`)
- Lower primary STEM quiz (`stem_lp_v1_*`)
- Adult functional quiz (`adult_functional_p4_v1_*`)
- Helpers (`00_portal_helpers.sql`) — quiz score wrappers + academic years

## Notes
- Set `SCHOOL_WEBSITE_URL` and `CONTACT_EMAIL` in `config.js`
- Parent PDF email opens the device mail app with a summary (full PDF via Print)
- Interview-day mode is a staff toggle under Setup in `/assess/`
