-- ADULT FUNCTIONAL EDUCATION ADMISSION APPLICATION
-- Margaret E. Gemstone STEM Academy | Ghana | Applicants aged 18 and above
-- INSTALL: Supabase > SQL Editor > New query > paste all of this file > Run as postgres.
-- Dedicated meg_adult_adm_v1_* objects; leaves child applications and quizzes unchanged.
-- Supabase Auth sign-in is required to save, submit and view a private application.
-- Includes question definitions, private response storage and staff review functions.
-- A learner-facing website is NOT included; connect your form to these RPCs.
-- Never put the service-role key in browser or mobile application code.
-- Questions about skill/confidence are self-reports, not scores or admission cutoffs.
-- This programme accepts applications from adults; no Primary 4 school qualification
-- is imposed by this questionnaire. A learning assessment can be arranged separately.
-- Course, transport, fee/support and delivery preferences do not promise availability.
-- Marketing consent is optional and separate from application processing.
-- No fees are charged, files uploaded, emails sent or admission decisions automated.
-- Repeat installation preserves version 1 wording and existing responses.
-- Before launch, display approved school contacts, fees, privacy and retention notices.
--
-- QUESTIONNAIRE PREVIEW
-- 1. What is your full name? [required]
--    Write in: text
-- 2. What name would you like us to use? [optional]
--    Write in: text
-- 3. Are you 18 years old or above? [required]
--    Yes | No
--    This programme is for adults aged 18 and above. If you are younger, contact the school about suitable alternatives.
-- 4. What is your date of birth? [optional]
--    Write in: date
--    Optional. Leave blank if you are unsure; do not guess.
-- 5. Where do you live? [required]
--    Write in: text
--    Town or community and a nearby landmark are enough. Add a GhanaPost GPS address if available.
-- 6. Which phone number can the school use to reach you? [required]
--    Write in: phone
--    Your own number or a trusted contact’s number with their permission.
-- 7. Is this your own phone number or a shared contact? [required]
--    My own number | Shared phone or trusted contact
--    If shared, the school should avoid sending sensitive application details by SMS or WhatsApp.
-- 8. What is your email address? [optional]
--    Write in: email
--    Optional unless you choose email as your contact method.
-- 9. How would you prefer us to contact you? [required]
--    Phone call | SMS | WhatsApp | Email
-- 10. Which language would you prefer us to use when contacting you? [required]
--    Write in: text
-- 11. When is a good time to contact you? [optional]
--    Write in: text
-- 12. What is the highest level of school you attended? [required]
--    No formal schooling | Some primary school | Completed primary school | Some JHS or middle school | Completed JHS or middle school | Some SHS or secondary school | Completed SHS or secondary school | Vocational or technical education | Tertiary education | Other / unsure
--    All backgrounds are welcome. Your answer helps us plan appropriate learning support.
-- 13. When did you last attend school or a training programme? [optional]
--    Within the last year | 1 to 5 years ago | More than 5 years ago | Never attended | Not sure
-- 14. Which languages do you speak or understand? [required]
--    Write in: text
--    For example: Twi, Fante, English, Ewe, Ga or another language.
-- 15. In which language or languages can you read a short message? [optional]
--    Write in: text
--    You may write None yet or Not sure.
-- 16. Can you read and understand a short everyday notice? [optional]
--    On my own | With some help | Not yet | Not sure
-- 17. Can you write a short message or fill in a simple form? [optional]
--    On my own | With some help | Not yet | Not sure
-- 18. Can you work out a simple total or check your change when shopping? [optional]
--    On my own | With some help | Not yet | Not sure
--    These answers describe your confidence. They are not test scores and will not automatically decide admission.
-- 19. Which description best fits your current situation? [optional]
--    Employed | Self-employed or running a business | Farming or trading | Looking for work | Full-time home or caregiving responsibilities | Retired | Student or trainee | Other | Prefer not to say
-- 20. What work, business or practical skills would you like us to know about? [optional]
--    Write in: text
--    Optional. Paid work and unpaid experience both count.
-- 21. What would you like to learn? Choose all that apply. [required]
--    Reading everyday messages | Writing and completing forms | Basic mathematics | Computers and smartphones | Using AI tools safely | Business records and basic accounting | Everyday money management | Basic taxes in Ghana | Civic education and government | Basic law, courts and personal responsibilities | Vocational or practical skills | Other
--    Choose at least one. These are interests; the school will confirm the courses offered.
-- 22. What is the most important change you hope this programme will help you make? [optional]
--    Write in: text
--    For example: read independently, help my children, improve my business, use a computer or prepare for further learning. A short answer is enough.
-- 23. If interested in practical training, what trade or skill would you like to explore? [optional]
--    Write in: text
--    Optional. This does not confirm that a particular course is available.
-- 24. When would you like to begin? [optional]
--    Write in: date
--    Optional preferred date. The school will confirm the intake.
-- 25. On which days could you usually attend? Choose all that apply. [required]
--    Monday | Tuesday | Wednesday | Thursday | Friday | Saturday | Sunday | Schedule changes — please discuss
--    Select the days you could attend; the school will confirm the timetable.
-- 26. Which class time would suit you best? [required]
--    Morning | Afternoon | Evening | Flexible | Please discuss with me
-- 27. How would you prefer to attend? [required]
--    At the school | Online if available | A mix of school and online if available | Please help me choose
--    Your preference does not confirm that a delivery option is available.
-- 28. How much time could you usually spend practising outside class each week? [optional]
--    Less than 1 hour | 1 to 2 hours | 3 to 5 hours | More than 5 hours | Not sure yet
-- 29. What might make attending difficult? Choose any that apply. [optional]
--    Work schedule | Transport | Childcare or caring responsibilities | Cost | Internet or device access | Other
--    Optional. Leave blank if no difficulty is known. The school can discuss possible arrangements.
-- 30. Which device could you usually use for learning? [required]
--    My own smartphone | A shared or borrowed smartphone | A basic phone only | A computer or tablet | No device available | Not sure
--    Not owning a device does not automatically disqualify you.
-- 31. How reliable is your internet or mobile data access? [optional]
--    Usually available | Sometimes available | Rarely or never available | Not sure
-- 32. Can you open a phone message and send a reply? [optional]
--    On my own | With some help | Not yet | Not sure
-- 33. Would you like to share learning-access or health-related support needs on this form? [required]
--    Yes — I agree to share relevant details for admission and support planning | No — I prefer to discuss this privately
--    Details are optional. Share only what helps the school plan access and support; a diagnosis is not required.
-- 34. What could help you take part? Choose any that apply. [optional]
--    Larger print | Audio or questions read aloud | Hearing or communication support | Step-free access or suitable seating | Extra practice time | Language support | Help using digital devices | Other
--    Show only if support_sharing = Yes — I agree to share relevant details for admission and support planning
-- 35. Is there another arrangement or relevant health need you would like to discuss? [optional]
--    Write in: text
--    Show only if support_sharing = Yes — I agree to share relevant details for admission and support planning
--    Optional. Do not provide medical records, ID numbers or detailed diagnoses. You can request a private discussion.
-- 36. Who may we contact in an emergency? [optional]
--    Write in: text
--    Optional at application: full name and relationship. Let the person know you have listed them.
-- 37. What is the emergency contact’s phone number? [optional]
--    Write in: phone
-- 38. What fee information would you like? Choose all that apply. [optional]
--    Full fee schedule | Payment dates | Payment arrangements | Any available financial support
--    Applying does not commit you to an undisclosed fee.
-- 39. How did you hear about the programme? [optional]
--    Friend or family | Social media | School website | Radio | Signboard or flyer | Community, church or workplace | School event or visit | Other
-- 40. Did someone help you complete this form? [required]
--    No | Yes — they read, typed or translated my answers
--    Assistance is welcome and does not reduce your chance of admission. Answers and declarations must reflect your own choices; use your own applicant account.
-- 41. What is the name of the person who helped you? [optional]
--    Write in: text
--    Show only if completion_help = Yes — they read, typed or translated my answers
-- 42. Is there anything else you would like to ask or tell the school? [optional]
--    Write in: text
--    Please request a private discussion for sensitive information.
-- 43. I confirm that these are my answers and they are accurate to the best of my knowledge. [required]
--    Yes | No
-- 44. I agree that the school may use the information I provide to process this application, contact me and plan appropriate learning support. [required]
--    Yes | No
--    Read the privacy notice first. If you do not agree, contact the school about another way to apply. This does not give permission for advertising or publicity.
-- 45. Type your full name to confirm your application. [required]
--    Write in: text
--    A helper may type your name with your permission after reading the declaration to you. Submission time is recorded automatically. Submission does not guarantee admission.
-- 46. May the school send you optional news and promotional updates? [optional]
--    Yes | No
--    Optional. Blank means No. Your choice does not affect admission, and you may ask the school to stop these updates.

BEGIN;
CREATE SCHEMA IF NOT EXISTS meg_adult_adm_v1_private;
REVOKE ALL ON SCHEMA meg_adult_adm_v1_private FROM PUBLIC, anon, authenticated;

CREATE TABLE IF NOT EXISTS public.meg_adult_adm_v1_forms (
 form_code text PRIMARY KEY,
 definition jsonb NOT NULL CHECK (jsonb_typeof(definition)='object'),
 created_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS meg_adult_adm_v1_private.staff (
 user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
 added_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE meg_adult_adm_v1_private.staff ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON meg_adult_adm_v1_private.staff FROM PUBLIC, anon, authenticated;

CREATE TABLE IF NOT EXISTS public.meg_adult_adm_v1_applications (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 owner_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
 form_code text NOT NULL DEFAULT 'adult_admission_v1' REFERENCES public.meg_adult_adm_v1_forms(form_code),
 answers jsonb NOT NULL DEFAULT '{}'::jsonb CHECK (jsonb_typeof(answers)='object'),
 status text NOT NULL DEFAULT 'draft' CHECK (status IN
  ('draft','submitted','under_review','needs_changes','offered','waitlisted','not_offered','withdrawn')),
 applicant_message text,
 submitted_at timestamptz,
 last_submitted_at timestamptz,
 reviewed_at timestamptz,
 created_at timestamptz NOT NULL DEFAULT now(),
 updated_at timestamptz NOT NULL DEFAULT now(),
 CHECK (octet_length(answers::text)<=65536),
 CHECK (status='draft' OR submitted_at IS NOT NULL)
);
CREATE INDEX IF NOT EXISTS meg_adult_adm_v1_owner_idx ON public.meg_adult_adm_v1_applications(owner_id);
CREATE INDEX IF NOT EXISTS meg_adult_adm_v1_status_idx ON public.meg_adult_adm_v1_applications(status);
CREATE TABLE IF NOT EXISTS public.meg_adult_adm_v1_review_log (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 application_id uuid NOT NULL REFERENCES public.meg_adult_adm_v1_applications(id) ON DELETE CASCADE,
 reviewer_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
 previous_status text NOT NULL,
 new_status text NOT NULL,
 applicant_message text,
 internal_note text,
 created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS meg_adult_adm_v1_review_app_idx ON public.meg_adult_adm_v1_review_log(application_id);

CREATE OR REPLACE FUNCTION public.meg_adult_adm_v1_is_staff()
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path=''
AS $$ SELECT EXISTS (SELECT 1 FROM meg_adult_adm_v1_private.staff WHERE user_id=auth.uid()); $$;
REVOKE ALL ON FUNCTION public.meg_adult_adm_v1_is_staff() FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.meg_adult_adm_v1_is_staff() TO authenticated;

ALTER TABLE public.meg_adult_adm_v1_forms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meg_adult_adm_v1_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meg_adult_adm_v1_review_log ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.meg_adult_adm_v1_forms, public.meg_adult_adm_v1_applications,
 public.meg_adult_adm_v1_review_log FROM PUBLIC, anon, authenticated;
GRANT SELECT ON public.meg_adult_adm_v1_forms TO anon, authenticated;
GRANT SELECT ON public.meg_adult_adm_v1_applications, public.meg_adult_adm_v1_review_log TO authenticated;
GRANT ALL ON public.meg_adult_adm_v1_forms, public.meg_adult_adm_v1_applications, public.meg_adult_adm_v1_review_log TO service_role;
-- Parents and staff use RPCs for writes. There are no client write grants/policies.
DROP POLICY IF EXISTS meg_adult_adm_v1_form_read ON public.meg_adult_adm_v1_forms;
CREATE POLICY meg_adult_adm_v1_form_read ON public.meg_adult_adm_v1_forms FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS meg_adult_adm_v1_application_read ON public.meg_adult_adm_v1_applications;
CREATE POLICY meg_adult_adm_v1_application_read ON public.meg_adult_adm_v1_applications FOR SELECT TO authenticated
 USING (owner_id=(SELECT auth.uid()) OR (status<>'draft' AND (SELECT public.meg_adult_adm_v1_is_staff())));
DROP POLICY IF EXISTS meg_adult_adm_v1_log_read ON public.meg_adult_adm_v1_review_log;
CREATE POLICY meg_adult_adm_v1_log_read ON public.meg_adult_adm_v1_review_log FOR SELECT TO authenticated
 USING ((SELECT public.meg_adult_adm_v1_is_staff()));
INSERT INTO public.meg_adult_adm_v1_forms(form_code,definition) VALUES ('adult_admission_v1','{"school": "Margaret E. Gemstone STEM Academy", "programme": "Adult Functional Education Programme", "title": "Adult Functional Education Admission Application", "version": 1, "instructions": "Complete one application for yourself. Required questions are marked with an asterisk. Choose answers that fit your situation and use short write-ins. You may ask someone to read, type or translate the form with your permission. Save a draft and return later if needed. The school will contact you about admission and a suitable learning starting point. This form is not a scored test.", "privacy_notice": "The school uses these answers to process admission, communicate with you and plan appropriate learning support. Your account and authorised admissions staff can access your application through this system. Optional sensitive details can be left blank and discussed privately. Contact school administration about access, corrections, withdrawal and its retention policy. Marketing permission is separate. Do not enter Ghana Card or passport numbers, bank details, passwords, PINs or medical records.", "implementation_note": "Before accepting applications, display the real admissions contact, approved privacy/retention notice, confirmed fees and timetable. Preferences do not promise course availability, financial support or a specific delivery mode. Self-reported skills must not be used as automatic admission scores.", "questions": [{"key": "full_name", "section": "About you", "label": "What is your full name?", "type": "text", "required": true, "order": 1}, {"key": "preferred_name", "section": "About you", "label": "What name would you like us to use?", "type": "text", "required": false, "order": 2}, {"key": "adult_confirmation", "section": "About you", "label": "Are you 18 years old or above?", "type": "single", "required": true, "order": 3, "options": ["Yes", "No"], "help": "This programme is for adults aged 18 and above. If you are younger, contact the school about suitable alternatives.", "must_equal": "Yes"}, {"key": "date_of_birth", "section": "About you", "label": "What is your date of birth?", "type": "date", "required": false, "order": 4, "help": "Optional. Leave blank if you are unsure; do not guess."}, {"key": "home_address", "section": "About you", "label": "Where do you live?", "type": "text", "required": true, "order": 5, "help": "Town or community and a nearby landmark are enough. Add a GhanaPost GPS address if available."}, {"key": "phone", "section": "About you", "label": "Which phone number can the school use to reach you?", "type": "phone", "required": true, "order": 6, "help": "Your own number or a trusted contact’s number with their permission."}, {"key": "phone_privacy", "section": "About you", "label": "Is this your own phone number or a shared contact?", "type": "single", "required": true, "order": 7, "options": ["My own number", "Shared phone or trusted contact"], "help": "If shared, the school should avoid sending sensitive application details by SMS or WhatsApp."}, {"key": "email", "section": "About you", "label": "What is your email address?", "type": "email", "required": false, "order": 8, "help": "Optional unless you choose email as your contact method."}, {"key": "contact_method", "section": "About you", "label": "How would you prefer us to contact you?", "type": "single", "required": true, "order": 9, "options": ["Phone call", "SMS", "WhatsApp", "Email"]}, {"key": "contact_language", "section": "About you", "label": "Which language would you prefer us to use when contacting you?", "type": "text", "required": true, "order": 10}, {"key": "best_contact_time", "section": "About you", "label": "When is a good time to contact you?", "type": "text", "required": false, "order": 11}, {"key": "education_level", "section": "Education and language", "label": "What is the highest level of school you attended?", "type": "single", "required": true, "order": 12, "options": ["No formal schooling", "Some primary school", "Completed primary school", "Some JHS or middle school", "Completed JHS or middle school", "Some SHS or secondary school", "Completed SHS or secondary school", "Vocational or technical education", "Tertiary education", "Other / unsure"], "help": "All backgrounds are welcome. Your answer helps us plan appropriate learning support."}, {"key": "last_education", "section": "Education and language", "label": "When did you last attend school or a training programme?", "type": "single", "required": false, "order": 13, "options": ["Within the last year", "1 to 5 years ago", "More than 5 years ago", "Never attended", "Not sure"]}, {"key": "spoken_languages", "section": "Education and language", "label": "Which languages do you speak or understand?", "type": "text", "required": true, "order": 14, "help": "For example: Twi, Fante, English, Ewe, Ga or another language."}, {"key": "reading_languages", "section": "Education and language", "label": "In which language or languages can you read a short message?", "type": "text", "required": false, "order": 15, "help": "You may write None yet or Not sure."}, {"key": "reading_confidence", "section": "Education and language", "label": "Can you read and understand a short everyday notice?", "type": "single", "required": false, "order": 16, "options": ["On my own", "With some help", "Not yet", "Not sure"]}, {"key": "writing_confidence", "section": "Education and language", "label": "Can you write a short message or fill in a simple form?", "type": "single", "required": false, "order": 17, "options": ["On my own", "With some help", "Not yet", "Not sure"]}, {"key": "math_confidence", "section": "Education and language", "label": "Can you work out a simple total or check your change when shopping?", "type": "single", "required": false, "order": 18, "options": ["On my own", "With some help", "Not yet", "Not sure"], "help": "These answers describe your confidence. They are not test scores and will not automatically decide admission."}, {"key": "current_work", "section": "Work and learning goals", "label": "Which description best fits your current situation?", "type": "single", "required": false, "order": 19, "options": ["Employed", "Self-employed or running a business", "Farming or trading", "Looking for work", "Full-time home or caregiving responsibilities", "Retired", "Student or trainee", "Other", "Prefer not to say"]}, {"key": "work_details", "section": "Work and learning goals", "label": "What work, business or practical skills would you like us to know about?", "type": "text", "required": false, "order": 20, "help": "Optional. Paid work and unpaid experience both count."}, {"key": "learning_interests", "section": "Work and learning goals", "label": "What would you like to learn? Choose all that apply.", "type": "multi", "required": true, "order": 21, "options": ["Reading everyday messages", "Writing and completing forms", "Basic mathematics", "Computers and smartphones", "Using AI tools safely", "Business records and basic accounting", "Everyday money management", "Basic taxes in Ghana", "Civic education and government", "Basic law, courts and personal responsibilities", "Vocational or practical skills", "Other"], "help": "Choose at least one. These are interests; the school will confirm the courses offered."}, {"key": "main_goal", "section": "Work and learning goals", "label": "What is the most important change you hope this programme will help you make?", "type": "text", "required": false, "order": 22, "help": "For example: read independently, help my children, improve my business, use a computer or prepare for further learning. A short answer is enough."}, {"key": "vocational_interest", "section": "Work and learning goals", "label": "If interested in practical training, what trade or skill would you like to explore?", "type": "text", "required": false, "order": 23, "help": "Optional. This does not confirm that a particular course is available."}, {"key": "preferred_start_date", "section": "Class arrangements", "label": "When would you like to begin?", "type": "date", "required": false, "order": 24, "help": "Optional preferred date. The school will confirm the intake."}, {"key": "available_days", "section": "Class arrangements", "label": "On which days could you usually attend? Choose all that apply.", "type": "multi", "required": true, "order": 25, "options": ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday", "Schedule changes — please discuss"], "help": "Select the days you could attend; the school will confirm the timetable."}, {"key": "time_preference", "section": "Class arrangements", "label": "Which class time would suit you best?", "type": "single", "required": true, "order": 26, "options": ["Morning", "Afternoon", "Evening", "Flexible", "Please discuss with me"]}, {"key": "learning_mode", "section": "Class arrangements", "label": "How would you prefer to attend?", "type": "single", "required": true, "order": 27, "options": ["At the school", "Online if available", "A mix of school and online if available", "Please help me choose"], "help": "Your preference does not confirm that a delivery option is available."}, {"key": "practice_time", "section": "Class arrangements", "label": "How much time could you usually spend practising outside class each week?", "type": "single", "required": false, "order": 28, "options": ["Less than 1 hour", "1 to 2 hours", "3 to 5 hours", "More than 5 hours", "Not sure yet"]}, {"key": "attendance_barriers", "section": "Class arrangements", "label": "What might make attending difficult? Choose any that apply.", "type": "multi", "required": false, "order": 29, "options": ["Work schedule", "Transport", "Childcare or caring responsibilities", "Cost", "Internet or device access", "Other"], "help": "Optional. Leave blank if no difficulty is known. The school can discuss possible arrangements."}, {"key": "device_access", "section": "Technology and learning support", "label": "Which device could you usually use for learning?", "type": "single", "required": true, "order": 30, "options": ["My own smartphone", "A shared or borrowed smartphone", "A basic phone only", "A computer or tablet", "No device available", "Not sure"], "help": "Not owning a device does not automatically disqualify you."}, {"key": "internet_access", "section": "Technology and learning support", "label": "How reliable is your internet or mobile data access?", "type": "single", "required": false, "order": 31, "options": ["Usually available", "Sometimes available", "Rarely or never available", "Not sure"]}, {"key": "digital_confidence", "section": "Technology and learning support", "label": "Can you open a phone message and send a reply?", "type": "single", "required": false, "order": 32, "options": ["On my own", "With some help", "Not yet", "Not sure"]}, {"key": "support_sharing", "section": "Technology and learning support", "label": "Would you like to share learning-access or health-related support needs on this form?", "type": "single", "required": true, "order": 33, "options": ["Yes — I agree to share relevant details for admission and support planning", "No — I prefer to discuss this privately"], "help": "Details are optional. Share only what helps the school plan access and support; a diagnosis is not required."}, {"key": "support_needs", "section": "Technology and learning support", "label": "What could help you take part? Choose any that apply.", "type": "multi", "required": false, "order": 34, "options": ["Larger print", "Audio or questions read aloud", "Hearing or communication support", "Step-free access or suitable seating", "Extra practice time", "Language support", "Help using digital devices", "Other"], "show_if": {"key": "support_sharing", "equals": "Yes — I agree to share relevant details for admission and support planning"}}, {"key": "support_details", "section": "Technology and learning support", "label": "Is there another arrangement or relevant health need you would like to discuss?", "type": "text", "required": false, "order": 35, "help": "Optional. Do not provide medical records, ID numbers or detailed diagnoses. You can request a private discussion.", "show_if": {"key": "support_sharing", "equals": "Yes — I agree to share relevant details for admission and support planning"}}, {"key": "emergency_name", "section": "Emergency contact and fees", "label": "Who may we contact in an emergency?", "type": "text", "required": false, "order": 36, "help": "Optional at application: full name and relationship. Let the person know you have listed them."}, {"key": "emergency_phone", "section": "Emergency contact and fees", "label": "What is the emergency contact’s phone number?", "type": "phone", "required": false, "order": 37}, {"key": "fee_information", "section": "Emergency contact and fees", "label": "What fee information would you like? Choose all that apply.", "type": "multi", "required": false, "order": 38, "options": ["Full fee schedule", "Payment dates", "Payment arrangements", "Any available financial support"], "help": "Applying does not commit you to an undisclosed fee."}, {"key": "referral_source", "section": "Emergency contact and fees", "label": "How did you hear about the programme?", "type": "single", "required": false, "order": 39, "options": ["Friend or family", "Social media", "School website", "Radio", "Signboard or flyer", "Community, church or workplace", "School event or visit", "Other"]}, {"key": "completion_help", "section": "Help completing this application", "label": "Did someone help you complete this form?", "type": "single", "required": true, "order": 40, "options": ["No", "Yes — they read, typed or translated my answers"], "help": "Assistance is welcome and does not reduce your chance of admission. Answers and declarations must reflect your own choices; use your own applicant account."}, {"key": "helper_name", "section": "Help completing this application", "label": "What is the name of the person who helped you?", "type": "text", "required": false, "order": 41, "show_if": {"key": "completion_help", "equals": "Yes — they read, typed or translated my answers"}}, {"key": "other_information", "section": "Help completing this application", "label": "Is there anything else you would like to ask or tell the school?", "type": "text", "required": false, "order": 42, "help": "Please request a private discussion for sensitive information."}, {"key": "accuracy_confirmation", "section": "Declaration and submission", "label": "I confirm that these are my answers and they are accurate to the best of my knowledge.", "type": "single", "required": true, "order": 43, "options": ["Yes", "No"], "must_equal": "Yes"}, {"key": "data_consent", "section": "Declaration and submission", "label": "I agree that the school may use the information I provide to process this application, contact me and plan appropriate learning support.", "type": "single", "required": true, "order": 44, "options": ["Yes", "No"], "help": "Read the privacy notice first. If you do not agree, contact the school about another way to apply. This does not give permission for advertising or publicity.", "must_equal": "Yes"}, {"key": "signature_name", "section": "Declaration and submission", "label": "Type your full name to confirm your application.", "type": "text", "required": true, "order": 45, "help": "A helper may type your name with your permission after reading the declaration to you. Submission time is recorded automatically. Submission does not guarantee admission."}, {"key": "marketing_updates", "section": "Declaration and submission", "label": "May the school send you optional news and promotional updates?", "type": "single", "required": false, "order": 46, "options": ["Yes", "No"], "help": "Optional. Blank means No. Your choice does not affect admission, and you may ask the school to stop these updates."}]}'::jsonb) ON CONFLICT(form_code) DO NOTHING;

-- Server validation uses the frozen question definition for the application's version.
CREATE OR REPLACE FUNCTION meg_adult_adm_v1_private.validate_answers(
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
 SELECT definition INTO v_definition FROM public.meg_adult_adm_v1_forms WHERE form_code=p_form_code;
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
    IF k='date_of_birth' AND (v_date>current_date OR (v_date + interval '18 years')::date>current_date) THEN RAISE EXCEPTION 'This programme is for adults aged 18 and above. Check the date or contact the school.'; END IF;
   END IF;
  END IF;
 END LOOP;
 IF p_complete AND p_answers->>'contact_method'='Email' AND coalesce(btrim(p_answers->>'email'),'')='' THEN
  RAISE EXCEPTION 'Please enter an email address or choose another contact method.';
 END IF;
END;
$fn$;
REVOKE ALL ON FUNCTION meg_adult_adm_v1_private.validate_answers(jsonb,text,boolean) FROM PUBLIC, anon, authenticated;

-- Creates a draft when p_application_id is null, otherwise replaces ALL answers
-- on the applicant's editable application. Send the complete answer object, not a patch.
CREATE OR REPLACE FUNCTION public.meg_adult_adm_v1_save_draft(p_answers jsonb, p_application_id uuid DEFAULT NULL)
RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path=''
AS $fn$
DECLARE v_user uuid:=auth.uid(); v_id uuid; v_form text; v_status text;
BEGIN
 IF v_user IS NULL THEN RAISE EXCEPTION 'Please sign in before saving an application.'; END IF;
 IF p_application_id IS NULL THEN
  PERFORM meg_adult_adm_v1_private.validate_answers(p_answers,'adult_admission_v1',false);
  INSERT INTO public.meg_adult_adm_v1_applications(owner_id,answers)
    VALUES(v_user,p_answers) RETURNING id INTO v_id;
 ELSE
  SELECT form_code,status INTO v_form,v_status FROM public.meg_adult_adm_v1_applications
   WHERE id=p_application_id AND owner_id=v_user FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Application unavailable.'; END IF;
  IF v_status NOT IN ('draft','needs_changes') THEN RAISE EXCEPTION 'This application has been submitted. Ask the school to reopen it for corrections.'; END IF;
  PERFORM meg_adult_adm_v1_private.validate_answers(p_answers,v_form,false);
  UPDATE public.meg_adult_adm_v1_applications SET answers=p_answers,updated_at=now() WHERE id=p_application_id;
  v_id:=p_application_id;
 END IF;
 RETURN v_id;
END;
$fn$;
REVOKE ALL ON FUNCTION public.meg_adult_adm_v1_save_draft(jsonb,uuid) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.meg_adult_adm_v1_save_draft(jsonb,uuid) TO authenticated;

CREATE OR REPLACE FUNCTION public.meg_adult_adm_v1_submit(p_application_id uuid)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path=''
AS $fn$
DECLARE a public.meg_adult_adm_v1_applications%ROWTYPE;
BEGIN
 IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Please sign in before submitting.'; END IF;
 SELECT * INTO a FROM public.meg_adult_adm_v1_applications
  WHERE id=p_application_id AND owner_id=auth.uid() FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Application unavailable.'; END IF;
 IF a.status NOT IN ('draft','needs_changes') THEN RAISE EXCEPTION 'Application already submitted or closed.'; END IF;
 PERFORM meg_adult_adm_v1_private.validate_answers(a.answers,a.form_code,true);
 UPDATE public.meg_adult_adm_v1_applications
 SET status='submitted',submitted_at=coalesce(submitted_at,now()),last_submitted_at=now(),
     applicant_message=NULL,updated_at=now()
 WHERE id=a.id;
 RETURN jsonb_build_object('application_id',a.id,'status','submitted','message',
  'Your application has been submitted. Keep this reference. The school will contact you about the next steps. Submission does not guarantee admission.');
END;
$fn$;
REVOKE ALL ON FUNCTION public.meg_adult_adm_v1_submit(uuid) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.meg_adult_adm_v1_submit(uuid) TO authenticated;

CREATE OR REPLACE FUNCTION public.meg_adult_adm_v1_review(
 p_application_id uuid, p_status text, p_applicant_message text DEFAULT NULL, p_internal_note text DEFAULT NULL)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path=''
AS $fn$
DECLARE v_previous text;
BEGIN
 IF NOT public.meg_adult_adm_v1_is_staff() THEN RAISE EXCEPTION 'School staff authorisation is required.'; END IF;
 IF p_status IS NULL OR p_status NOT IN ('under_review','needs_changes','offered','waitlisted','not_offered','withdrawn') THEN
  RAISE EXCEPTION 'Invalid review status.';
 END IF;
 IF coalesce(length(p_applicant_message),0)>4000 OR coalesce(length(p_internal_note),0)>4000 THEN
  RAISE EXCEPTION 'Keep each review message below 4000 characters.';
 END IF;
 IF p_status='needs_changes' AND coalesce(btrim(p_applicant_message),'')='' THEN
  RAISE EXCEPTION 'Explain which corrections the applicant should make.';
 END IF;
 SELECT status INTO v_previous FROM public.meg_adult_adm_v1_applications WHERE id=p_application_id FOR UPDATE;
 IF NOT FOUND OR v_previous='draft' THEN RAISE EXCEPTION 'No submitted application available.'; END IF;
 UPDATE public.meg_adult_adm_v1_applications SET status=p_status,applicant_message=nullif(btrim(p_applicant_message),''),
  reviewed_at=now(),updated_at=now() WHERE id=p_application_id;
 INSERT INTO public.meg_adult_adm_v1_review_log(application_id,reviewer_id,previous_status,new_status,applicant_message,internal_note)
 VALUES(p_application_id,auth.uid(),v_previous,p_status,nullif(btrim(p_applicant_message),''),nullif(btrim(p_internal_note),''));
END;
$fn$;
REVOKE ALL ON FUNCTION public.meg_adult_adm_v1_review(uuid,text,text,text) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.meg_adult_adm_v1_review(uuid,text,text,text) TO authenticated;

-- Smoke checks run within the installation transaction. No real applicant data is saved.
DO $check$
DECLARE v_bad_rejected boolean:=false;
BEGIN
 IF jsonb_array_length((SELECT definition->'questions' FROM public.meg_adult_adm_v1_forms WHERE form_code='adult_admission_v1'))<>46 THEN
  RAISE EXCEPTION 'Expected 46 questionnaire fields.';
 END IF;
 PERFORM meg_adult_adm_v1_private.validate_answers('{}'::jsonb,'adult_admission_v1',false);
 BEGIN
  PERFORM meg_adult_adm_v1_private.validate_answers('{}'::jsonb,'adult_admission_v1',true);
 EXCEPTION WHEN raise_exception THEN v_bad_rejected:=true;
 END;
 IF NOT v_bad_rejected THEN RAISE EXCEPTION 'Required-question validation failed.'; END IF;
 IF has_table_privilege('anon','public.meg_adult_adm_v1_applications','SELECT')
 OR has_table_privilege('authenticated','public.meg_adult_adm_v1_applications','INSERT')
 OR has_table_privilege('authenticated','public.meg_adult_adm_v1_applications','UPDATE')
 OR has_table_privilege('authenticated','meg_adult_adm_v1_private.staff','INSERT') THEN
  RAISE EXCEPTION 'Unexpected application permissions.';
 END IF;
END;
$check$;
COMMIT;
SELECT form_code, jsonb_array_length(definition->'questions') AS questions_loaded
 FROM public.meg_adult_adm_v1_forms WHERE form_code='adult_admission_v1';

-- SCHOOL SETUP AFTER INSTALLATION
-- 1. Enable a suitable Supabase Auth sign-in method for applicants and staff.
-- 2. The administrator authorises each admissions staff account in SQL Editor:
--    INSERT INTO meg_adult_adm_v1_private.staff(user_id) VALUES ('REAL-STAFF-AUTH-USER-UUID')
--    ON CONFLICT DO NOTHING;
--    Use the exact user's ID from Authentication > Users; never put a guessed ID here.
--    To revoke access, delete that staff row as the project administrator.
-- 3. Connect an applicant form to public.meg_adult_adm_v1_forms.definition.questions.
--    Render text/phone/email/date inputs, single-choice buttons/dropdowns and multi-select
--    checkboxes. Mark required fields. Respect show_if, and clear answers when hidden.
--    Use short sections, Save draft and Submit application buttons. No countdown.
-- 4. Applicant RPC meg_adult_adm_v1_save_draft:
--    {p_answers: {full_name: '...', ...}, p_application_id: null}
--    Keep the returned UUID. For edits, pass it and the complete current answer object.
-- 5. Applicant RPC meg_adult_adm_v1_submit: {p_application_id: returned UUID}.
--    Validation errors identify missing/invalid responses. Display them helpfully.
--    The submitted record is immediately available to authorised staff; no email is sent.
-- 6. Applicants SELECT their own meg_adult_adm_v1_applications for reference/status/messages.
--    Staff SELECT submitted applications, and call meg_adult_adm_v1_review to change status.
--    Private staff notes are in meg_adult_adm_v1_review_log, not applicant-visible application rows.
--    needs_changes reopens the applicant's answers; they save and submit again.
-- 7. Marketing permission is only affirmative when answers->>'marketing_updates' = 'Yes'.
--    Empty/missing/No means no optional marketing. Do not infer publicity/photo permission.
-- 8. Public admission form definitions are safe to read without signing in. Applications
--    are not public. The private schema must remain outside the Data API exposed schemas.
-- 9. Project administrators can manage records in the dashboard. Decide retention and
--    deletion processes, and verify applicant A/applicant B/staff access before launch.
