-- STAFF EMPLOYMENT APPLICATION | STEM ACADEMY AND ADULT FUNCTIONAL EDUCATION
-- Margaret E. Gemstone STEM Academy, Ghana
-- INSTALL: Supabase > SQL Editor > New query > paste this entire file > Run as postgres.
-- Dedicated meg_jobs_v1_* objects and separate recruitment staff authorisation.
-- Existing child/adult admissions and assessment tables are not changed.
-- Supabase Auth sign-in is required to save, submit and view an application.
-- Contains questions, private answer storage, validation and recruitment review RPCs.
-- A candidate-facing website is not included. Connect a form to these definitions/RPCs.
-- Never expose the service-role key in a browser or mobile app.
-- No automatic hiring score, ranking, selection, emails, reference checks or file uploads.
-- No gender, religion, ethnicity, marital status, pregnancy or birth-date questions.
-- Conditional questions appear only for the selected role family.
-- Reference permission and future-vacancy permission are separate choices.
-- Verify vacancy criteria and any required qualifications/licences before appointment.
-- Repeat installation preserves version 1 wording and existing applications.
-- Publish actual recruitment contacts and privacy/retention information before launch.
-- QUESTIONNAIRE PREVIEW
-- 1. Where would you like to work? [required when shown]
--    STEM Academy | Adult Functional Education Programme | Either or both
-- 2. Which type of position are you applying for? [required when shown]
--    Teaching or training | Teaching assistant or learner support | Administration or admissions | Finance or accounts | ICT or technical support | Library or laboratory support | Driving or transport | Catering or food service | Cleaning, maintenance or security | Other
-- 3. What position or area of work interests you most? [required when shown]
--    Write in: text
--    For example: lower-primary teacher, adult literacy tutor, robotics instructor, school secretary, accounts assistant, driver or cook. Apply for one main role per application.
-- 4. What working arrangement would suit you? [required when shown]
--    Full-time | Part-time | Fixed-term or temporary | Relief or occasional work | Internship or supervised placement
--    Choose all that apply. Availability depends on actual vacancies.
-- 5. What is your full name? [required when shown]
--    Write in: text
-- 6. What phone number should we use to contact you? [required when shown]
--    Write in: phone
-- 7. What is your email address? [optional]
--    Write in: email
-- 8. How would you prefer us to contact you? [required when shown]
--    Phone call | SMS | WhatsApp | Email
-- 9. In which town or community do you currently live? [required when shown]
--    Write in: text
--    A full residential address is not needed at this stage.
-- 10. Which languages can you use at work? [required when shown]
--    Write in: text
--    List languages and whether you speak, read or write them.
-- 11. Are you currently permitted to work in Ghana? [required when shown]
--    Yes | No — I would need authorisation | Not sure — please discuss
--    Do not enter passport, Ghana Card or immigration document numbers here. Any relevant documents can be verified later.
-- 12. Could you travel to the school regularly if appointed? [required when shown]
--    Yes | I would need to relocate | I would need transport arrangements | Please discuss with me
-- 13. What is your highest completed qualification? [required when shown]
--    No formal qualification | Basic education or BECE | SHS, WASSCE or equivalent | Trade or vocational certificate | Professional certificate | Diploma or HND | Bachelor’s degree | Master’s degree | Doctorate | Other
--    Requirements depend on the role. Practical experience and vocational skills are also relevant.
-- 14. Give the name of your main qualification, institution and completion year. [optional]
--    Write in: text
--    Write Not applicable if you do not hold a formal qualification. You may also mention training in progress.
-- 15. What other training or practical skills would help you in this role? [optional]
--    Write in: text
--    For example: first aid, safeguarding, special education, ICT, bookkeeping, food safety, maintenance or a trade.
-- 16. How much relevant work experience do you have? [required when shown]
--    No previous experience | Less than 1 year | 1 to 3 years | 4 to 6 years | 7 years or more
-- 17. Describe your most recent relevant role or practical experience. [optional]
--    Write in: text
--    Include organisation or setting, role, approximate dates and main duties. Voluntary work and self-employment count. You may write This is my first job.
-- 18. Describe any other experience that would help you do this job. [optional]
--    Write in: text
-- 19. Give one example of a task or problem you handled well. [optional]
--    Write in: text
--    A short answer is enough. You may use an example from work, training, volunteering or community life.
-- 20. Why would you like to work with our school or adult education programme? [required when shown]
--    Write in: text
-- 21. Which subjects or skills could you teach confidently? [required when shown]
--    Early-years learning | Reading and literacy | Writing and communication | Mathematics | Science | Computing and digital skills | Robotics or practical STEM | Adult functional literacy | Business, accounting or money skills | Civic education or basic law | Vocational or practical skills | Music, art or physical education | Other
--    Show only if job_family = Teaching or training
-- 22. Which learners have you taught or are you prepared to teach? [required when shown]
--    Creche or nursery | Kindergarten | Lower primary | Upper primary | Adults beginning basic skills | Adults building on previous schooling | No teaching experience yet
--    Show only if job_family = Teaching or training
--    Select No teaching experience yet by itself if applicable.
-- 23. What is the status of your teaching licence or relevant professional registration? [required when shown]
--    Current | Application or renewal in progress | Previously held — not current | Do not hold one | Not applicable to the role | Unsure
--    Show only if job_family = Teaching or training
--    Do not enter licence numbers here. The school will check requirements and verify documents relevant to the position.
-- 24. Describe a simple activity you would use to teach a useful skill. [required when shown]
--    Write in: text
--    Show only if job_family = Teaching or training
--    State the learner group, the skill and how you would involve learners. About 3 to 5 sentences is enough.
-- 25. What would you do if one learner needed more support than the rest of the class? [required when shown]
--    Write in: text
--    Show only if job_family = Teaching or training
--    Give a short practical example. Do not include a real learner’s name or private details.
-- 26. How would you check whether your learners understood your lesson? [required when shown]
--    Write in: text
--    Show only if job_family = Teaching or training
-- 27. Which teaching tools have you used? [optional]
--    Printed pictures or learning aids | Hands-on materials or models | Phone learning apps | Computer or projector | Online learning platform | Robotics or coding tools | AI tools with human checking | None yet
--    Show only if job_family = Teaching or training
--    If you select None yet, leave the other options unselected.
-- 28. What is the status of your driving licence? [required when shown]
--    Current | Renewal in progress | Not current | Do not hold one
--    Show only if job_family = Driving or transport
--    Do not enter the licence number here. The school will verify the appropriate licence and vehicle class before appointment.
-- 29. Which types of vehicles have you driven, and for approximately how long? [required when shown]
--    Write in: text
--    Show only if job_family = Driving or transport
-- 30. What would you do if you noticed a serious vehicle fault before collecting learners? [required when shown]
--    Write in: text
--    Show only if job_family = Driving or transport
-- 31. What food preparation or food-safety experience do you have? [required when shown]
--    Write in: text
--    Show only if job_family = Catering or food service
-- 32. How would you avoid serving food that could be unsafe or cause an allergy problem? [required when shown]
--    Write in: text
--    Show only if job_family = Catering or food service
--    Answer briefly. Do not include anyone’s private health details.
-- 33. Describe the main tasks you could perform in the role you are applying for. [required when shown]
--    Write in: text
--    Teachers may summarise their teaching strengths. Other applicants may mention administration, accounts, learner support, equipment, cleaning, maintenance or security tasks.
-- 34. Which digital tasks can you do? [optional]
--    Phone calls and messages | Email | Typing documents | Spreadsheets | Online forms and records | Basic device troubleshooting | None yet
--    Select None yet by itself if applicable. Digital skill requirements depend on the job.
-- 35. If a learner told you that someone was hurting or threatening them, what would you do? [required when shown]
--    Write in: text
--    A short answer is enough. Do not describe or identify a real person. The school will discuss its safeguarding procedures during selection and induction.
-- 36. How would you protect private information about learners, families and colleagues? [required when shown]
--    Write in: text
-- 37. Is there a current professional restriction or legal order that may affect your ability to carry out this role safely? [optional]
--    No | Yes — please arrange a confidential discussion | Unsure — please arrange a confidential discussion
--    Do not provide allegations, case details or records here. This is not an automatic rejection question. Any further checks must be relevant to the role and handled through a separate process.
-- 38. Are you willing to follow the school’s safeguarding, respectful-conduct and confidentiality policies and complete relevant induction? [required when shown]
--    Yes | I would like to review and discuss the policies first
--    The school must provide the policies before asking you to accept employment terms.
-- 39. If selected, when could you start? [required when shown]
--    Immediately | Within 2 weeks | Within 1 month | After more than 1 month | Please discuss with me
-- 40. Do you have a notice period or other availability arrangements we should know about? [optional]
--    Write in: text
-- 41. When are you generally available to work? [required when shown]
--    Weekday mornings | Weekday afternoons | Weekday evenings | Weekends | Flexible | Other arrangements — please discuss
-- 42. What pay range or working arrangement would you like to discuss? [optional]
--    Write in: text
--    Optional. If giving a figure, state Ghana cedis and whether it is per hour, day or month. You do not need to disclose previous pay.
-- 43. Would you like any arrangements to help you take part in an interview or practical demonstration? [optional]
--    No | Yes — please contact me privately
--    No diagnosis or medical history is required.
-- 44. Provide one referee who can comment on your work, training or reliability. [optional]
--    Write in: text
--    Name, role, organisation or setting, relationship to you, and phone or email. Prefer someone other than a close relative. Optional at application; the school may request this later.
-- 45. Provide a second referee, if available. [optional]
--    Write in: text
--    Name, role, organisation or setting, relationship and contact details. A trainer or volunteer supervisor may be suitable if you are applying for your first job.
-- 46. When may the school contact the referees you provide? [required when shown]
--    You may contact them now | Ask me before contacting any referee | I will provide referees later
--    Let referees know before sharing their details. Listing a referee does not authorise contact with any other current employer. No reference messages are sent by this application system.
-- 47. Which documents could you provide if requested? [optional]
--    CV or work-history summary | Education or training certificates | Professional registration evidence | Driving licence where relevant | Portfolio or examples of work | Not available yet
--    Select Not available yet by itself. Files are not uploaded through this questionnaire; the school can arrange a secure process later.
-- 48. How did you hear about the opportunity? [optional]
--    School website | Social media | Friend or colleague | Radio or printed advertisement | Job website | Direct school contact | Other
-- 49. Is there anything else relevant to your application that you would like to tell us? [optional]
--    Write in: text
--    Do not include identity numbers, bank details, medical reports or private learner information.
-- 50. I confirm that these are my answers and they are accurate to the best of my knowledge. [required when shown]
--    Yes | No
-- 51. I agree that the school may use this information to assess my job application and contact me about recruitment. [required when shown]
--    Yes | No
--    Read the privacy notice first. Reference contact follows your separate choice above. Any additional background checks need a separate explanation and appropriate authorisation.
-- 52. Type your full name to confirm your application. [required when shown]
--    Write in: text
--    The submission date and time will be recorded automatically. An application does not guarantee an interview or employment.
-- 53. May the school consider this application for other suitable vacancies during its stated recruitment retention period? [optional]
--    Yes | No
--    Optional. Blank means No. This does not affect this application and is not permission for indefinite retention. Ask the school for its retention period before deciding.

BEGIN;
CREATE SCHEMA IF NOT EXISTS meg_jobs_v1_private;
REVOKE ALL ON SCHEMA meg_jobs_v1_private FROM PUBLIC, anon, authenticated;

CREATE TABLE IF NOT EXISTS public.meg_jobs_v1_forms (
 form_code text PRIMARY KEY,
 definition jsonb NOT NULL CHECK (jsonb_typeof(definition)='object'),
 created_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS meg_jobs_v1_private.staff (
 user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
 added_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE meg_jobs_v1_private.staff ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON meg_jobs_v1_private.staff FROM PUBLIC, anon, authenticated;

CREATE TABLE IF NOT EXISTS public.meg_jobs_v1_applications (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 owner_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
 form_code text NOT NULL DEFAULT 'staff_application_v1' REFERENCES public.meg_jobs_v1_forms(form_code),
 answers jsonb NOT NULL DEFAULT '{}'::jsonb CHECK (jsonb_typeof(answers)='object'),
 status text NOT NULL DEFAULT 'draft' CHECK (status IN
  ('draft','submitted','under_review','needs_changes','shortlisted','interview','offered','not_selected','withdrawn')),
 applicant_message text,
 submitted_at timestamptz,
 last_submitted_at timestamptz,
 reviewed_at timestamptz,
 created_at timestamptz NOT NULL DEFAULT now(),
 updated_at timestamptz NOT NULL DEFAULT now(),
 CHECK (octet_length(answers::text)<=65536),
 CHECK (status='draft' OR submitted_at IS NOT NULL)
);
CREATE INDEX IF NOT EXISTS meg_jobs_v1_owner_idx ON public.meg_jobs_v1_applications(owner_id);
CREATE INDEX IF NOT EXISTS meg_jobs_v1_status_idx ON public.meg_jobs_v1_applications(status);
CREATE TABLE IF NOT EXISTS public.meg_jobs_v1_review_log (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 application_id uuid NOT NULL REFERENCES public.meg_jobs_v1_applications(id) ON DELETE CASCADE,
 reviewer_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
 previous_status text NOT NULL,
 new_status text NOT NULL,
 applicant_message text,
 internal_note text,
 created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS meg_jobs_v1_review_app_idx ON public.meg_jobs_v1_review_log(application_id);

CREATE OR REPLACE FUNCTION public.meg_jobs_v1_is_staff()
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path=''
AS $$ SELECT EXISTS (SELECT 1 FROM meg_jobs_v1_private.staff WHERE user_id=auth.uid()); $$;
REVOKE ALL ON FUNCTION public.meg_jobs_v1_is_staff() FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.meg_jobs_v1_is_staff() TO authenticated;

ALTER TABLE public.meg_jobs_v1_forms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meg_jobs_v1_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meg_jobs_v1_review_log ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.meg_jobs_v1_forms, public.meg_jobs_v1_applications,
 public.meg_jobs_v1_review_log FROM PUBLIC, anon, authenticated;
GRANT SELECT ON public.meg_jobs_v1_forms TO anon, authenticated;
GRANT SELECT ON public.meg_jobs_v1_applications, public.meg_jobs_v1_review_log TO authenticated;
GRANT ALL ON public.meg_jobs_v1_forms, public.meg_jobs_v1_applications, public.meg_jobs_v1_review_log TO service_role;
-- Applicants and staff use RPCs for writes. There are no client write grants/policies.
DROP POLICY IF EXISTS meg_jobs_v1_form_read ON public.meg_jobs_v1_forms;
CREATE POLICY meg_jobs_v1_form_read ON public.meg_jobs_v1_forms FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS meg_jobs_v1_application_read ON public.meg_jobs_v1_applications;
CREATE POLICY meg_jobs_v1_application_read ON public.meg_jobs_v1_applications FOR SELECT TO authenticated
 USING (owner_id=(SELECT auth.uid()) OR (status<>'draft' AND (SELECT public.meg_jobs_v1_is_staff())));
DROP POLICY IF EXISTS meg_jobs_v1_log_read ON public.meg_jobs_v1_review_log;
CREATE POLICY meg_jobs_v1_log_read ON public.meg_jobs_v1_review_log FOR SELECT TO authenticated
 USING ((SELECT public.meg_jobs_v1_is_staff()));
INSERT INTO public.meg_jobs_v1_forms(form_code,definition) VALUES ('staff_application_v1','{"school": "Margaret E. Gemstone STEM Academy", "programmes": ["STEM Academy", "Adult Functional Education Programme"], "title": "Staff Employment Application", "version": 1, "instructions": "Complete one application for your main preferred role. Required questions are marked with an asterisk. Some questions appear only for teaching, driving or catering roles. Use short answers and save a draft if you need to return later. Qualifications and experience are considered against the actual role; this questionnaire does not automatically score or select applicants.", "privacy_notice": "The school uses your answers to assess your application and communicate about recruitment. Through this system, your account can access your application and authorised recruitment staff can access submitted applications. Internal recruitment notes are restricted to authorised recruitment staff. Reference contact follows your selected permission. Contact school administration about access, corrections, withdrawal and the recruitment retention period. Do not submit identity numbers, bank details, medical records or private learner information. Optional permission for future vacancies is separate from this application.", "implementation_note": "Before launch, display the actual vacancy description, essential criteria, location, recruitment contact, approved privacy/retention notice and any relevant safeguarding/check procedures. Do not request protected personal characteristics or use answers to automate hiring decisions. This database does not verify qualifications, references or professional licences.", "questions": [{"key": "programme", "section": "Position and programme", "label": "Where would you like to work?", "type": "single", "required": true, "order": 1, "options": ["STEM Academy", "Adult Functional Education Programme", "Either or both"]}, {"key": "job_family", "section": "Position and programme", "label": "Which type of position are you applying for?", "type": "single", "required": true, "order": 2, "options": ["Teaching or training", "Teaching assistant or learner support", "Administration or admissions", "Finance or accounts", "ICT or technical support", "Library or laboratory support", "Driving or transport", "Catering or food service", "Cleaning, maintenance or security", "Other"]}, {"key": "position_title", "section": "Position and programme", "label": "What position or area of work interests you most?", "type": "text", "required": true, "order": 3, "help": "For example: lower-primary teacher, adult literacy tutor, robotics instructor, school secretary, accounts assistant, driver or cook. Apply for one main role per application."}, {"key": "employment_preference", "section": "Position and programme", "label": "What working arrangement would suit you?", "type": "multi", "required": true, "order": 4, "options": ["Full-time", "Part-time", "Fixed-term or temporary", "Relief or occasional work", "Internship or supervised placement"], "help": "Choose all that apply. Availability depends on actual vacancies."}, {"key": "full_name", "section": "Applicant and contact details", "label": "What is your full name?", "type": "text", "required": true, "order": 5}, {"key": "phone", "section": "Applicant and contact details", "label": "What phone number should we use to contact you?", "type": "phone", "required": true, "order": 6}, {"key": "email", "section": "Applicant and contact details", "label": "What is your email address?", "type": "email", "required": false, "order": 7}, {"key": "contact_method", "section": "Applicant and contact details", "label": "How would you prefer us to contact you?", "type": "single", "required": true, "order": 8, "options": ["Phone call", "SMS", "WhatsApp", "Email"]}, {"key": "location", "section": "Applicant and contact details", "label": "In which town or community do you currently live?", "type": "text", "required": true, "order": 9, "help": "A full residential address is not needed at this stage."}, {"key": "languages", "section": "Applicant and contact details", "label": "Which languages can you use at work?", "type": "text", "required": true, "order": 10, "help": "List languages and whether you speak, read or write them."}, {"key": "work_permission", "section": "Applicant and contact details", "label": "Are you currently permitted to work in Ghana?", "type": "single", "required": true, "order": 11, "options": ["Yes", "No — I would need authorisation", "Not sure — please discuss"], "help": "Do not enter passport, Ghana Card or immigration document numbers here. Any relevant documents can be verified later."}, {"key": "travel_arrangements", "section": "Applicant and contact details", "label": "Could you travel to the school regularly if appointed?", "type": "single", "required": true, "order": 12, "options": ["Yes", "I would need to relocate", "I would need transport arrangements", "Please discuss with me"]}, {"key": "highest_qualification", "section": "Education and professional preparation", "label": "What is your highest completed qualification?", "type": "single", "required": true, "order": 13, "options": ["No formal qualification", "Basic education or BECE", "SHS, WASSCE or equivalent", "Trade or vocational certificate", "Professional certificate", "Diploma or HND", "Bachelor’s degree", "Master’s degree", "Doctorate", "Other"], "help": "Requirements depend on the role. Practical experience and vocational skills are also relevant."}, {"key": "qualification_details", "section": "Education and professional preparation", "label": "Give the name of your main qualification, institution and completion year.", "type": "text", "required": false, "order": 14, "help": "Write Not applicable if you do not hold a formal qualification. You may also mention training in progress."}, {"key": "relevant_training", "section": "Education and professional preparation", "label": "What other training or practical skills would help you in this role?", "type": "text", "required": false, "order": 15, "help": "For example: first aid, safeguarding, special education, ICT, bookkeeping, food safety, maintenance or a trade."}, {"key": "experience_length", "section": "Work experience", "label": "How much relevant work experience do you have?", "type": "single", "required": true, "order": 16, "options": ["No previous experience", "Less than 1 year", "1 to 3 years", "4 to 6 years", "7 years or more"]}, {"key": "recent_role", "section": "Work experience", "label": "Describe your most recent relevant role or practical experience.", "type": "text", "required": false, "order": 17, "help": "Include organisation or setting, role, approximate dates and main duties. Voluntary work and self-employment count. You may write This is my first job."}, {"key": "earlier_experience", "section": "Work experience", "label": "Describe any other experience that would help you do this job.", "type": "text", "required": false, "order": 18}, {"key": "achievement", "section": "Work experience", "label": "Give one example of a task or problem you handled well.", "type": "text", "required": false, "order": 19, "help": "A short answer is enough. You may use an example from work, training, volunteering or community life."}, {"key": "motivation", "section": "Work experience", "label": "Why would you like to work with our school or adult education programme?", "type": "text", "required": true, "order": 20}, {"key": "teaching_subjects", "section": "Teaching and training applicants", "label": "Which subjects or skills could you teach confidently?", "type": "multi", "required": true, "order": 21, "options": ["Early-years learning", "Reading and literacy", "Writing and communication", "Mathematics", "Science", "Computing and digital skills", "Robotics or practical STEM", "Adult functional literacy", "Business, accounting or money skills", "Civic education or basic law", "Vocational or practical skills", "Music, art or physical education", "Other"], "show_if": {"key": "job_family", "equals": "Teaching or training"}}, {"key": "teaching_levels", "section": "Teaching and training applicants", "label": "Which learners have you taught or are you prepared to teach?", "type": "multi", "required": true, "order": 22, "options": ["Creche or nursery", "Kindergarten", "Lower primary", "Upper primary", "Adults beginning basic skills", "Adults building on previous schooling", "No teaching experience yet"], "help": "Select No teaching experience yet by itself if applicable.", "show_if": {"key": "job_family", "equals": "Teaching or training"}}, {"key": "teaching_registration", "section": "Teaching and training applicants", "label": "What is the status of your teaching licence or relevant professional registration?", "type": "single", "required": true, "order": 23, "options": ["Current", "Application or renewal in progress", "Previously held — not current", "Do not hold one", "Not applicable to the role", "Unsure"], "help": "Do not enter licence numbers here. The school will check requirements and verify documents relevant to the position.", "show_if": {"key": "job_family", "equals": "Teaching or training"}}, {"key": "teaching_example", "section": "Teaching and training applicants", "label": "Describe a simple activity you would use to teach a useful skill.", "type": "text", "required": true, "order": 24, "help": "State the learner group, the skill and how you would involve learners. About 3 to 5 sentences is enough.", "show_if": {"key": "job_family", "equals": "Teaching or training"}}, {"key": "learning_support_example", "section": "Teaching and training applicants", "label": "What would you do if one learner needed more support than the rest of the class?", "type": "text", "required": true, "order": 25, "help": "Give a short practical example. Do not include a real learner’s name or private details.", "show_if": {"key": "job_family", "equals": "Teaching or training"}}, {"key": "progress_check", "section": "Teaching and training applicants", "label": "How would you check whether your learners understood your lesson?", "type": "text", "required": true, "order": 26, "show_if": {"key": "job_family", "equals": "Teaching or training"}}, {"key": "teaching_technology", "section": "Teaching and training applicants", "label": "Which teaching tools have you used?", "type": "multi", "required": false, "order": 27, "options": ["Printed pictures or learning aids", "Hands-on materials or models", "Phone learning apps", "Computer or projector", "Online learning platform", "Robotics or coding tools", "AI tools with human checking", "None yet"], "help": "If you select None yet, leave the other options unselected.", "show_if": {"key": "job_family", "equals": "Teaching or training"}}, {"key": "driving_licence", "section": "Practical role requirements", "label": "What is the status of your driving licence?", "type": "single", "required": true, "order": 28, "options": ["Current", "Renewal in progress", "Not current", "Do not hold one"], "help": "Do not enter the licence number here. The school will verify the appropriate licence and vehicle class before appointment.", "show_if": {"key": "job_family", "equals": "Driving or transport"}}, {"key": "vehicle_experience", "section": "Practical role requirements", "label": "Which types of vehicles have you driven, and for approximately how long?", "type": "text", "required": true, "order": 29, "show_if": {"key": "job_family", "equals": "Driving or transport"}}, {"key": "driver_safety", "section": "Practical role requirements", "label": "What would you do if you noticed a serious vehicle fault before collecting learners?", "type": "text", "required": true, "order": 30, "show_if": {"key": "job_family", "equals": "Driving or transport"}}, {"key": "catering_experience", "section": "Practical role requirements", "label": "What food preparation or food-safety experience do you have?", "type": "text", "required": true, "order": 31, "show_if": {"key": "job_family", "equals": "Catering or food service"}}, {"key": "food_safety_example", "section": "Practical role requirements", "label": "How would you avoid serving food that could be unsafe or cause an allergy problem?", "type": "text", "required": true, "order": 32, "help": "Answer briefly. Do not include anyone’s private health details.", "show_if": {"key": "job_family", "equals": "Catering or food service"}}, {"key": "role_tasks", "section": "Practical role requirements", "label": "Describe the main tasks you could perform in the role you are applying for.", "type": "text", "required": true, "order": 33, "help": "Teachers may summarise their teaching strengths. Other applicants may mention administration, accounts, learner support, equipment, cleaning, maintenance or security tasks."}, {"key": "computer_skills", "section": "Practical role requirements", "label": "Which digital tasks can you do?", "type": "multi", "required": false, "order": 34, "options": ["Phone calls and messages", "Email", "Typing documents", "Spreadsheets", "Online forms and records", "Basic device troubleshooting", "None yet"], "help": "Select None yet by itself if applicable. Digital skill requirements depend on the job."}, {"key": "safeguarding_response", "section": "Safety and professional conduct", "label": "If a learner told you that someone was hurting or threatening them, what would you do?", "type": "text", "required": true, "order": 35, "help": "A short answer is enough. Do not describe or identify a real person. The school will discuss its safeguarding procedures during selection and induction."}, {"key": "confidentiality", "section": "Safety and professional conduct", "label": "How would you protect private information about learners, families and colleagues?", "type": "text", "required": true, "order": 36}, {"key": "professional_restriction", "section": "Safety and professional conduct", "label": "Is there a current professional restriction or legal order that may affect your ability to carry out this role safely?", "type": "single", "required": false, "order": 37, "options": ["No", "Yes — please arrange a confidential discussion", "Unsure — please arrange a confidential discussion"], "help": "Do not provide allegations, case details or records here. This is not an automatic rejection question. Any further checks must be relevant to the role and handled through a separate process."}, {"key": "conduct_commitment", "section": "Safety and professional conduct", "label": "Are you willing to follow the school’s safeguarding, respectful-conduct and confidentiality policies and complete relevant induction?", "type": "single", "required": true, "order": 38, "options": ["Yes", "I would like to review and discuss the policies first"], "help": "The school must provide the policies before asking you to accept employment terms."}, {"key": "start_availability", "section": "Availability and expectations", "label": "If selected, when could you start?", "type": "single", "required": true, "order": 39, "options": ["Immediately", "Within 2 weeks", "Within 1 month", "After more than 1 month", "Please discuss with me"]}, {"key": "notice_period", "section": "Availability and expectations", "label": "Do you have a notice period or other availability arrangements we should know about?", "type": "text", "required": false, "order": 40}, {"key": "available_times", "section": "Availability and expectations", "label": "When are you generally available to work?", "type": "multi", "required": true, "order": 41, "options": ["Weekday mornings", "Weekday afternoons", "Weekday evenings", "Weekends", "Flexible", "Other arrangements — please discuss"]}, {"key": "salary_expectation", "section": "Availability and expectations", "label": "What pay range or working arrangement would you like to discuss?", "type": "text", "required": false, "order": 42, "help": "Optional. If giving a figure, state Ghana cedis and whether it is per hour, day or month. You do not need to disclose previous pay."}, {"key": "selection_adjustments", "section": "Availability and expectations", "label": "Would you like any arrangements to help you take part in an interview or practical demonstration?", "type": "single", "required": false, "order": 43, "options": ["No", "Yes — please contact me privately"], "help": "No diagnosis or medical history is required."}, {"key": "referee_one", "section": "References and supporting information", "label": "Provide one referee who can comment on your work, training or reliability.", "type": "text", "required": false, "order": 44, "help": "Name, role, organisation or setting, relationship to you, and phone or email. Prefer someone other than a close relative. Optional at application; the school may request this later."}, {"key": "referee_two", "section": "References and supporting information", "label": "Provide a second referee, if available.", "type": "text", "required": false, "order": 45, "help": "Name, role, organisation or setting, relationship and contact details. A trainer or volunteer supervisor may be suitable if you are applying for your first job."}, {"key": "reference_permission", "section": "References and supporting information", "label": "When may the school contact the referees you provide?", "type": "single", "required": true, "order": 46, "options": ["You may contact them now", "Ask me before contacting any referee", "I will provide referees later"], "help": "Let referees know before sharing their details. Listing a referee does not authorise contact with any other current employer. No reference messages are sent by this application system."}, {"key": "available_documents", "section": "References and supporting information", "label": "Which documents could you provide if requested?", "type": "multi", "required": false, "order": 47, "options": ["CV or work-history summary", "Education or training certificates", "Professional registration evidence", "Driving licence where relevant", "Portfolio or examples of work", "Not available yet"], "help": "Select Not available yet by itself. Files are not uploaded through this questionnaire; the school can arrange a secure process later."}, {"key": "referral_source", "section": "References and supporting information", "label": "How did you hear about the opportunity?", "type": "single", "required": false, "order": 48, "options": ["School website", "Social media", "Friend or colleague", "Radio or printed advertisement", "Job website", "Direct school contact", "Other"]}, {"key": "other_information", "section": "References and supporting information", "label": "Is there anything else relevant to your application that you would like to tell us?", "type": "text", "required": false, "order": 49, "help": "Do not include identity numbers, bank details, medical reports or private learner information."}, {"key": "accuracy_confirmation", "section": "Declaration and submission", "label": "I confirm that these are my answers and they are accurate to the best of my knowledge.", "type": "single", "required": true, "order": 50, "options": ["Yes", "No"], "must_equal": "Yes"}, {"key": "data_consent", "section": "Declaration and submission", "label": "I agree that the school may use this information to assess my job application and contact me about recruitment.", "type": "single", "required": true, "order": 51, "options": ["Yes", "No"], "help": "Read the privacy notice first. Reference contact follows your separate choice above. Any additional background checks need a separate explanation and appropriate authorisation.", "must_equal": "Yes"}, {"key": "signature_name", "section": "Declaration and submission", "label": "Type your full name to confirm your application.", "type": "text", "required": true, "order": 52, "help": "The submission date and time will be recorded automatically. An application does not guarantee an interview or employment."}, {"key": "future_vacancies", "section": "Declaration and submission", "label": "May the school consider this application for other suitable vacancies during its stated recruitment retention period?", "type": "single", "required": false, "order": 53, "options": ["Yes", "No"], "help": "Optional. Blank means No. This does not affect this application and is not permission for indefinite retention. Ask the school for its retention period before deciding."}]}'::jsonb) ON CONFLICT(form_code) DO NOTHING;

-- Server validation uses the frozen question definition for the application's version.
CREATE OR REPLACE FUNCTION meg_jobs_v1_private.validate_answers(
 p_answers jsonb, p_form_code text, p_complete boolean)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path=''
AS $fn$
DECLARE
 v_definition jsonb; q jsonb; v jsonb; k text; t text;
 v_text text; v_present boolean; v_date date;
BEGIN
 IF p_answers IS NULL OR jsonb_typeof(p_answers)<>'object' THEN
  RAISE EXCEPTION 'Answers must be an object.';
 END IF;
 IF octet_length(p_answers::text)>65536 THEN RAISE EXCEPTION 'The application is too large.'; END IF;
 SELECT definition INTO v_definition FROM public.meg_jobs_v1_forms WHERE form_code=p_form_code;
 IF NOT FOUND THEN RAISE EXCEPTION 'Unknown application form.'; END IF;
 IF EXISTS (SELECT 1 FROM jsonb_object_keys(p_answers) AS a(key)
   WHERE NOT EXISTS (SELECT 1 FROM jsonb_array_elements(v_definition->'questions') AS b(value)
      WHERE b.value->>'key'=a.key)) THEN
  RAISE EXCEPTION 'An answer uses an unknown question key.';
 END IF;
 FOR q IN SELECT value FROM jsonb_array_elements(v_definition->'questions') LOOP
  k:=q->>'key'; t:=q->>'type'; v:=p_answers->k;
  v_present:=v IS NOT NULL AND v<>'null'::jsonb AND v<>'""'::jsonb AND v<>'[]'::jsonb;
  IF jsonb_typeof(v)='string' AND btrim(p_answers->>k)='' THEN v_present:=false; END IF;
  IF q ? 'show_if' AND (p_answers->>(q->'show_if'->>'key')) IS DISTINCT FROM (q->'show_if'->>'equals') THEN
   IF v_present THEN RAISE EXCEPTION 'Remove the hidden answer for: %', q->>'label'; END IF;
   CONTINUE;
  END IF;
  IF NOT v_present THEN
   IF p_complete AND (q->>'required')::boolean THEN RAISE EXCEPTION 'Please answer: %', q->>'label'; END IF;
   CONTINUE;
  END IF;
  IF t='multi' THEN
   IF jsonb_typeof(v)<>'array' THEN RAISE EXCEPTION 'Choose one or more listed options: %', q->>'label'; END IF;
   IF EXISTS (SELECT 1 FROM jsonb_array_elements(v) a(value)
     WHERE jsonb_typeof(a.value)<>'string' OR NOT (q->'options' @> jsonb_build_array(a.value))) THEN
    RAISE EXCEPTION 'Invalid choice for: %', q->>'label';
   END IF;
   IF (SELECT count(*)<>count(DISTINCT value) FROM jsonb_array_elements(v)) THEN
    RAISE EXCEPTION 'Duplicate choices for: %', q->>'label';
   END IF;
   IF (v @> '["None yet"]'::jsonb OR v @> '["Not available yet"]'::jsonb OR v @> '["No teaching experience yet"]'::jsonb)
      AND jsonb_array_length(v)>1 THEN
    RAISE EXCEPTION 'Select the no-experience or none option by itself: %',q->>'label';
   END IF;
  ELSE
   IF jsonb_typeof(v)<>'string' THEN RAISE EXCEPTION 'Please enter text or choose an option: %', q->>'label'; END IF;
   v_text:=btrim(p_answers->>k);
   IF length(v_text)>2000 THEN RAISE EXCEPTION 'Please keep this answer below 2000 characters: %', q->>'label'; END IF;
   IF t='single' AND NOT (q->'options' @> jsonb_build_array(v_text)) THEN
    RAISE EXCEPTION 'Invalid choice for: %', q->>'label';
   END IF;
   IF p_complete AND q ? 'must_equal' AND v_text<>(q->>'must_equal') THEN
    RAISE EXCEPTION 'This declaration is needed to submit. Contact the school if you need help: %', q->>'label';
   END IF;
   IF t='email' AND v_text !~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$' THEN
    RAISE EXCEPTION 'Please check the email address.';
   END IF;
   IF t='phone' AND (v_text !~ '^\+?[0-9 ()-]+$' OR length(regexp_replace(v_text,'[^0-9]','','g')) NOT BETWEEN 7 AND 15) THEN
    RAISE EXCEPTION 'Please check the phone number for: %', q->>'label';
   END IF;
   IF t='date' THEN
    IF v_text !~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN RAISE EXCEPTION 'Use YYYY-MM-DD for: %', q->>'label'; END IF;
    BEGIN v_date:=v_text::date;
    EXCEPTION WHEN OTHERS THEN RAISE EXCEPTION 'Please enter a valid date for: %', q->>'label'; END;
    
   END IF;
  END IF;
 END LOOP;
 IF p_complete AND p_answers->>'contact_method'='Email' AND coalesce(btrim(p_answers->>'email'),'')='' THEN
  RAISE EXCEPTION 'Please enter an email address or choose another contact method.';
 END IF;
END;
$fn$;
REVOKE ALL ON FUNCTION meg_jobs_v1_private.validate_answers(jsonb,text,boolean) FROM PUBLIC, anon, authenticated;

-- Creates a draft when p_application_id is null, otherwise replaces ALL answers
-- on the applicant's editable application. Send the complete answer object, not a patch.
CREATE OR REPLACE FUNCTION public.meg_jobs_v1_save_draft(p_answers jsonb, p_application_id uuid DEFAULT NULL)
RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path=''
AS $fn$
DECLARE v_user uuid:=auth.uid(); v_id uuid; v_form text; v_status text;
BEGIN
 IF v_user IS NULL THEN RAISE EXCEPTION 'Please sign in before saving an application.'; END IF;
 IF p_application_id IS NULL THEN
  PERFORM meg_jobs_v1_private.validate_answers(p_answers,'staff_application_v1',false);
  INSERT INTO public.meg_jobs_v1_applications(owner_id,answers)
    VALUES(v_user,p_answers) RETURNING id INTO v_id;
 ELSE
  SELECT form_code,status INTO v_form,v_status FROM public.meg_jobs_v1_applications
   WHERE id=p_application_id AND owner_id=v_user FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Application unavailable.'; END IF;
  IF v_status NOT IN ('draft','needs_changes') THEN RAISE EXCEPTION 'This application has been submitted. Ask the school to reopen it for corrections.'; END IF;
  PERFORM meg_jobs_v1_private.validate_answers(p_answers,v_form,false);
  UPDATE public.meg_jobs_v1_applications SET answers=p_answers,updated_at=now() WHERE id=p_application_id;
  v_id:=p_application_id;
 END IF;
 RETURN v_id;
END;
$fn$;
REVOKE ALL ON FUNCTION public.meg_jobs_v1_save_draft(jsonb,uuid) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.meg_jobs_v1_save_draft(jsonb,uuid) TO authenticated;

CREATE OR REPLACE FUNCTION public.meg_jobs_v1_submit(p_application_id uuid)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path=''
AS $fn$
DECLARE a public.meg_jobs_v1_applications%ROWTYPE;
BEGIN
 IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Please sign in before submitting.'; END IF;
 SELECT * INTO a FROM public.meg_jobs_v1_applications
  WHERE id=p_application_id AND owner_id=auth.uid() FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Application unavailable.'; END IF;
 IF a.status NOT IN ('draft','needs_changes') THEN RAISE EXCEPTION 'Application already submitted or closed.'; END IF;
 PERFORM meg_jobs_v1_private.validate_answers(a.answers,a.form_code,true);
 UPDATE public.meg_jobs_v1_applications
 SET status='submitted',submitted_at=coalesce(submitted_at,now()),last_submitted_at=now(),
     applicant_message=NULL,updated_at=now()
 WHERE id=a.id;
 RETURN jsonb_build_object('application_id',a.id,'status','submitted','message',
  'Your application has been submitted. Keep this reference. The school will contact you about the next steps. Submission does not guarantee an interview or employment.');
END;
$fn$;
REVOKE ALL ON FUNCTION public.meg_jobs_v1_submit(uuid) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.meg_jobs_v1_submit(uuid) TO authenticated;

CREATE OR REPLACE FUNCTION public.meg_jobs_v1_review(
 p_application_id uuid, p_status text, p_applicant_message text DEFAULT NULL, p_internal_note text DEFAULT NULL)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path=''
AS $fn$
DECLARE v_previous text;
BEGIN
 IF NOT public.meg_jobs_v1_is_staff() THEN RAISE EXCEPTION 'School staff authorisation is required.'; END IF;
 IF p_status IS NULL OR p_status NOT IN ('under_review','needs_changes','shortlisted','interview','offered','not_selected','withdrawn') THEN
  RAISE EXCEPTION 'Invalid review status.';
 END IF;
 IF coalesce(length(p_applicant_message),0)>4000 OR coalesce(length(p_internal_note),0)>4000 THEN
  RAISE EXCEPTION 'Keep each review message below 4000 characters.';
 END IF;
 IF p_status='needs_changes' AND coalesce(btrim(p_applicant_message),'')='' THEN
  RAISE EXCEPTION 'Explain which corrections the applicant should make.';
 END IF;
 SELECT status INTO v_previous FROM public.meg_jobs_v1_applications WHERE id=p_application_id FOR UPDATE;
 IF NOT FOUND OR v_previous='draft' THEN RAISE EXCEPTION 'No submitted application available.'; END IF;
 UPDATE public.meg_jobs_v1_applications SET status=p_status,applicant_message=nullif(btrim(p_applicant_message),''),
  reviewed_at=now(),updated_at=now() WHERE id=p_application_id;
 INSERT INTO public.meg_jobs_v1_review_log(application_id,reviewer_id,previous_status,new_status,applicant_message,internal_note)
 VALUES(p_application_id,auth.uid(),v_previous,p_status,nullif(btrim(p_applicant_message),''),nullif(btrim(p_internal_note),''));
END;
$fn$;
REVOKE ALL ON FUNCTION public.meg_jobs_v1_review(uuid,text,text,text) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.meg_jobs_v1_review(uuid,text,text,text) TO authenticated;

-- Smoke checks run within the installation transaction. No test family data is saved.
DO $check$
DECLARE v_bad_rejected boolean:=false;
BEGIN
 IF jsonb_array_length((SELECT definition->'questions' FROM public.meg_jobs_v1_forms WHERE form_code='staff_application_v1'))<>53 THEN
  RAISE EXCEPTION 'Expected 53 questionnaire fields.';
 END IF;
 PERFORM meg_jobs_v1_private.validate_answers('{}'::jsonb,'staff_application_v1',false);
 BEGIN
  PERFORM meg_jobs_v1_private.validate_answers('{}'::jsonb,'staff_application_v1',true);
 EXCEPTION WHEN raise_exception THEN v_bad_rejected:=true;
 END;
 IF NOT v_bad_rejected THEN RAISE EXCEPTION 'Required-question validation failed.'; END IF;
 IF has_table_privilege('anon','public.meg_jobs_v1_applications','SELECT')
 OR has_table_privilege('authenticated','public.meg_jobs_v1_applications','INSERT')
 OR has_table_privilege('authenticated','public.meg_jobs_v1_applications','UPDATE')
 OR has_table_privilege('authenticated','meg_jobs_v1_private.staff','INSERT') THEN
  RAISE EXCEPTION 'Unexpected application permissions.';
 END IF;
END;
$check$;
COMMIT;
SELECT form_code, jsonb_array_length(definition->'questions') AS questions_loaded
 FROM public.meg_jobs_v1_forms WHERE form_code='staff_application_v1';

-- SCHOOL SETUP AFTER INSTALLATION
-- 1. Enable a suitable Supabase Auth sign-in method for applicants and staff.
-- 2. The administrator authorises each recruitments staff account in SQL Editor:
--    INSERT INTO meg_jobs_v1_private.staff(user_id) VALUES ('REAL-STAFF-AUTH-USER-UUID')
--    ON CONFLICT DO NOTHING;
--    Use the exact user's ID from Authentication > Users; never put a guessed ID here.
--    To revoke access, delete that staff row as the project administrator.
-- 3. Connect a applicant form to public.meg_jobs_v1_forms.definition.questions.
--    Render text/phone/email/date inputs, single-choice buttons/dropdowns and multi-select
--    checkboxes. Mark required fields. Respect show_if, and clear answers when hidden.
--    Use short sections, Save draft and Submit application buttons. No countdown.
-- 4. Applicant RPC meg_jobs_v1_save_draft:
--    {p_answers: {full_name: '...', ...}, p_application_id: null}
--    Keep the returned UUID. For edits, pass it and the complete current answer object.
-- 5. Applicant RPC meg_jobs_v1_submit: {p_application_id: returned UUID}.
--    Validation errors identify missing/invalid responses. Display them helpfully.
--    The submitted record is immediately available to authorised staff; no email is sent.
-- 6. Applicants SELECT their own meg_jobs_v1_applications for reference/status/messages.
--    Staff SELECT submitted applications, and call meg_jobs_v1_review to change status.
--    Private staff notes are in meg_jobs_v1_review_log, not applicant-visible application rows.
--    needs_changes reopens the applicant's answers; they save and submit again.
-- 7. Future-vacancy permission is affirmative only when answers->>'future_vacancies' = 'Yes'.
--    Blank/No means no future-vacancy consideration. Follow the stated retention period.
--    Reference contact is permitted only according to answers->>'reference_permission'.
--    No references or employers are contacted by this SQL or its functions.
-- 8. Public job form definitions are safe to read without signing in. Applications
--    are not public. The private schema must remain outside the Data API exposed schemas.
-- 9. Project administrators can manage records in the dashboard. Decide retention and
--    deletion processes, and verify applicant A/applicant B/staff access before launch.
