-- MARGARET E. GEMSTONE STEM ACADEMY
-- CHILD ADMISSION QUESTIONNAIRE AND PRIVATE SUBMISSION DATABASE
-- Install: Supabase > SQL Editor > New query > paste this file > Run as postgres.
-- Dedicated meg_adm_v1_* objects; does not change existing assessment tables.
-- Parent access requires Supabase Auth sign-in. No public application access.
-- This file creates the form definition, response storage and workflow functions.
-- A parent-facing website is NOT included. Connect an existing form/app to these RPCs.
-- Do not expose a service-role key to parents or put it in browser code.
-- School staff must be explicitly authorised by the project administrator.
-- Do not place children’s responses in public storage, analytics or marketing lists.
-- No document uploads, fees, automated admission decisions or emails are configured.
-- Choices for classes/services express interest; school staff confirm availability.
-- Each successful submission records consent answers and a server timestamp.
-- Form version 1 is preserved on repeat installation. Create a new version to revise
-- questions after accepting real responses; do not silently rewrite consent wording.
-- Review the school's own contact information and privacy/retention notice before launch.
--
-- QUESTIONNAIRE PREVIEW (the same labels/options are stored in the form definition)
-- 1. What is the child’s full name? [required]
--    Write in: text
-- 2. What name does the child like to be called? [optional]
--    Write in: text
-- 3. What is the child’s date of birth? [required]
--    Write in: date
-- 4. What is the child’s sex? [optional]
--    Female | Male | Prefer to discuss privately
-- 5. Which class are you applying for? [required]
--    Creche | Nursery | Kindergarten 1 | Kindergarten 2 | Primary 1 | Primary 2 | Primary 3 | Primary 4 | Other / unsure
--    Class availability and placement will be confirmed by the school. Choose Other / unsure for any other class or programme.
-- 6. Please describe the class or programme you need. [optional]
--    Write in: text
--    Show only when class_requested = Other / unsure
-- 7. When would you like your child to start? [optional]
--    Write in: date
--    Choose a preferred date. The school will confirm its available intake.
-- 8. Where does the child live? [required]
--    Write in: text
--    Town or community, house or street details and a nearby landmark. Add a GhanaPost GPS address if available.
-- 9. Which languages does your child speak or understand? [required]
--    Write in: text
--    For example: Twi, Fante, English, Ewe, Ga or another language.
-- 10. What is your full name? [required]
--    Write in: text
-- 11. What is your relationship to the child? [required]
--    Mother | Father | Legal guardian | Other authorised caregiver
-- 12. What phone number should we use to contact you? [required]
--    Write in: phone
--    A Ghana number or an international number with country code.
-- 13. What is your email address? [optional]
--    Write in: email
--    Optional. You may give a phone number only.
-- 14. How would you prefer the school to contact you? [required]
--    Phone call | SMS | WhatsApp | Email
-- 15. Which language would you prefer for school communication? [required]
--    Write in: text
-- 16. Is there another parent or guardian the school may contact? [optional]
--    Write in: text
--    Optional: full name, relationship and phone number. Leave blank if not applicable.
-- 17. Who should we contact if we cannot reach you? [required]
--    Write in: text
--    Choose another trusted adult and let them know you have listed them.
-- 18. How is this emergency contact related to the child? [required]
--    Write in: text
-- 19. What is the emergency contact’s phone number? [required]
--    Write in: phone
-- 20. Who may collect your child from school? [required]
--    Write in: text
--    List each adult’s full name, relationship and phone number. You may list yourself. Final identity checks will be agreed with the school.
-- 21. Are there any collection or parental-contact restrictions the school should discuss with you? [required]
--    No | Yes — please contact me privately
--    Do not upload court or custody documents here. Discuss any relevant restrictions privately with the school.
-- 22. Has your child attended a school, nursery or childcare centre before? [required]
--    Yes | No
-- 23. What is the name and location of the previous school or centre? [optional]
--    Write in: text
--    Show only when previous_schooling = Yes
-- 24. What class or group did the child last attend? [optional]
--    Write in: text
--    Show only when previous_schooling = Yes
-- 25. Why are you seeking a new school? [optional]
--    Write in: text
--    Optional. For example: first school, relocation, teaching approach or learning support.
-- 26. What does your child enjoy? Choose all that apply. [optional]
--    Stories and books | Numbers and puzzles | Building and making things | Computers and technology | Music and dance | Drawing and art | Sports and movement | Plants and animals | Other
--    You may leave this blank if you are still discovering your child’s interests.
-- 27. What does your child do well, or what makes them feel confident? [optional]
--    Write in: text
-- 28. Would you like to share health or learning-support information on this form? [required]
--    Yes — I agree to share relevant details for admission and support planning | No — I prefer to discuss this privately
--    Details are optional and will be available to authorised admissions staff. You may leave them blank and arrange a private discussion. These answers are not automatically scored or used to reject an application.
-- 29. Does your child have any allergies or food restrictions we should plan for? [optional]
--    Write in: text
--    Show only when support_sharing = Yes — I agree to share relevant details for admission and support planning
--    Optional: state the allergy or restriction and any important precautions. You may write None or Unsure.
-- 30. Is there a health condition or emergency care need you would like to tell us about? [optional]
--    Write in: text
--    Show only when support_sharing = Yes — I agree to share relevant details for admission and support planning
--    Optional: share only what is relevant to safe school participation. Detailed care plans can be discussed privately.
-- 31. Will your child need medicine during school hours? [optional]
--    No | Yes — please contact me | Unsure
--    Show only when support_sharing = Yes — I agree to share relevant details for admission and support planning
--    This form does not authorise staff to give medicine. Any arrangements must be agreed separately.
-- 32. In which areas might your child benefit from support? Choose all that apply. [optional]
--    Communication or language | Hearing or vision access | Movement or physical access | Reading, writing or numbers | Attention or managing emotions | Toileting, feeding or personal care | Settling into school | Other
--    Show only when support_sharing = Yes — I agree to share relevant details for admission and support planning
--    A diagnosis is not required. Leave blank if no support is known.
-- 33. What helps your child learn, feel safe or take part? [optional]
--    Write in: text
--    Show only when support_sharing = Yes — I agree to share relevant details for admission and support planning
--    Optional: routines, communication methods, accessibility needs or other helpful arrangements.
-- 34. Would you like information about school transport? [optional]
--    Yes | No | Not sure
--    This is an expression of interest, not a confirmed service booking.
-- 35. Would you like information about school meals? [optional]
--    Yes | No | Not sure
-- 36. What fee information would you like? Choose all that apply. [optional]
--    Full fee schedule | Payment dates | Payment arrangements | Any available financial support
--    Submitting this form is not an agreement to an undisclosed fee.
-- 37. What are the two most important things you want your child to gain from our school? [optional]
--    Write in: text
-- 38. How did you hear about the school? [optional]
--    Friend or family | Social media | School website | Radio | Signboard or flyer | School visit or event | Other
-- 39. Is there anything else you would like the school to know? [optional]
--    Write in: text
--    Please do not repeat private health or custody details here; request a confidential discussion instead.
-- 40. I am a parent, legal guardian or caregiver authorised to apply for this child. [required]
--    Yes | No
-- 41. I confirm that the information is accurate to the best of my knowledge. [required]
--    Yes | No
-- 42. I agree that the school may use the information I provide to process this application, contact me and plan appropriate support. [required]
--    Yes | No
--    Read the privacy notice before choosing. If you do not agree, contact the school to discuss another way to apply. This does not give permission for publicity or advertising.
-- 43. Type your full name to confirm your application. [required]
--    Write in: text
--    The date and time of submission will be recorded automatically. Submission does not guarantee admission.
-- 44. May the school send you optional news and promotional updates? [optional]
--    Yes | No
--    Optional. Leaving this blank means No. Your choice will not affect the admission decision. You may ask the school to stop these updates.

BEGIN;
CREATE SCHEMA IF NOT EXISTS meg_adm_v1_private;
REVOKE ALL ON SCHEMA meg_adm_v1_private FROM PUBLIC, anon, authenticated;

CREATE TABLE IF NOT EXISTS public.meg_adm_v1_forms (
 form_code text PRIMARY KEY,
 definition jsonb NOT NULL CHECK (jsonb_typeof(definition)='object'),
 created_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS meg_adm_v1_private.staff (
 user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
 added_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE meg_adm_v1_private.staff ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON meg_adm_v1_private.staff FROM PUBLIC, anon, authenticated;

CREATE TABLE IF NOT EXISTS public.meg_adm_v1_applications (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 owner_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
 form_code text NOT NULL DEFAULT 'child_admission_v1' REFERENCES public.meg_adm_v1_forms(form_code),
 answers jsonb NOT NULL DEFAULT '{}'::jsonb CHECK (jsonb_typeof(answers)='object'),
 status text NOT NULL DEFAULT 'draft' CHECK (status IN
  ('draft','submitted','under_review','needs_changes','offered','waitlisted','not_offered','withdrawn')),
 parent_message text,
 submitted_at timestamptz,
 last_submitted_at timestamptz,
 reviewed_at timestamptz,
 created_at timestamptz NOT NULL DEFAULT now(),
 updated_at timestamptz NOT NULL DEFAULT now(),
 CHECK (octet_length(answers::text)<=65536),
 CHECK (status='draft' OR submitted_at IS NOT NULL)
);
CREATE INDEX IF NOT EXISTS meg_adm_v1_owner_idx ON public.meg_adm_v1_applications(owner_id);
CREATE INDEX IF NOT EXISTS meg_adm_v1_status_idx ON public.meg_adm_v1_applications(status);
CREATE TABLE IF NOT EXISTS public.meg_adm_v1_review_log (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 application_id uuid NOT NULL REFERENCES public.meg_adm_v1_applications(id) ON DELETE CASCADE,
 reviewer_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
 previous_status text NOT NULL,
 new_status text NOT NULL,
 parent_message text,
 internal_note text,
 created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS meg_adm_v1_review_app_idx ON public.meg_adm_v1_review_log(application_id);

CREATE OR REPLACE FUNCTION public.meg_adm_v1_is_staff()
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path=''
AS $$ SELECT EXISTS (SELECT 1 FROM meg_adm_v1_private.staff WHERE user_id=auth.uid()); $$;
REVOKE ALL ON FUNCTION public.meg_adm_v1_is_staff() FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.meg_adm_v1_is_staff() TO authenticated;

ALTER TABLE public.meg_adm_v1_forms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meg_adm_v1_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meg_adm_v1_review_log ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.meg_adm_v1_forms, public.meg_adm_v1_applications,
 public.meg_adm_v1_review_log FROM PUBLIC, anon, authenticated;
GRANT SELECT ON public.meg_adm_v1_forms TO anon, authenticated;
GRANT SELECT ON public.meg_adm_v1_applications, public.meg_adm_v1_review_log TO authenticated;
GRANT ALL ON public.meg_adm_v1_forms, public.meg_adm_v1_applications, public.meg_adm_v1_review_log TO service_role;
-- Parents and staff use RPCs for writes. There are no client write grants/policies.
DROP POLICY IF EXISTS meg_adm_v1_form_read ON public.meg_adm_v1_forms;
CREATE POLICY meg_adm_v1_form_read ON public.meg_adm_v1_forms FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS meg_adm_v1_application_read ON public.meg_adm_v1_applications;
CREATE POLICY meg_adm_v1_application_read ON public.meg_adm_v1_applications FOR SELECT TO authenticated
 USING (owner_id=(SELECT auth.uid()) OR (status<>'draft' AND (SELECT public.meg_adm_v1_is_staff())));
DROP POLICY IF EXISTS meg_adm_v1_log_read ON public.meg_adm_v1_review_log;
CREATE POLICY meg_adm_v1_log_read ON public.meg_adm_v1_review_log FOR SELECT TO authenticated
 USING ((SELECT public.meg_adm_v1_is_staff()));
INSERT INTO public.meg_adm_v1_forms (form_code, definition) VALUES ('child_admission_v1', '{"school": "Margaret E. Gemstone STEM Academy", "title": "Child Admission Application", "version": 1, "instructions": "Please complete one application per child. Required questions are marked with an asterisk. Choose the answer that fits best, and use short write-in answers where needed. Save a draft if you need to return later. Submission requests admission; the school will contact you about next steps. There is no automatic admission score.", "privacy_notice": "The school will use this information to process your application, communicate with you and plan relevant support. Only the account holder and authorised admissions staff can access the application through this system. Optional health and support details may be left blank and discussed privately. Contact the school administration to ask about access, corrections, withdrawal or its record-retention policy. Optional marketing permission is separate from the application. Do not submit identity numbers, bank details, medical reports or custody documents in the free-text fields.", "implementation_note": "Before opening the form to families, the school must display its real admissions contact and approved privacy/retention notice alongside this notice. This SQL does not invent school contact details or a retention period.", "questions": [{"key": "child_full_name", "section": "Child details", "label": "What is the child’s full name?", "type": "text", "required": true, "order": 1}, {"key": "preferred_name", "section": "Child details", "label": "What name does the child like to be called?", "type": "text", "required": false, "order": 2}, {"key": "date_of_birth", "section": "Child details", "label": "What is the child’s date of birth?", "type": "date", "required": true, "order": 3}, {"key": "sex", "section": "Child details", "label": "What is the child’s sex?", "type": "single", "required": false, "order": 4, "options": ["Female", "Male", "Prefer to discuss privately"]}, {"key": "class_requested", "section": "Child details", "label": "Which class are you applying for?", "type": "single", "required": true, "order": 5, "options": ["Creche", "Nursery", "Kindergarten 1", "Kindergarten 2", "Primary 1", "Primary 2", "Primary 3", "Primary 4", "Other / unsure"], "help": "Class availability and placement will be confirmed by the school. Choose Other / unsure for any other class or programme."}, {"key": "class_other", "section": "Child details", "label": "Please describe the class or programme you need.", "type": "text", "required": false, "order": 6, "show_if": {"key": "class_requested", "equals": "Other / unsure"}}, {"key": "preferred_start_date", "section": "Child details", "label": "When would you like your child to start?", "type": "date", "required": false, "order": 7, "help": "Choose a preferred date. The school will confirm its available intake."}, {"key": "home_address", "section": "Child details", "label": "Where does the child live?", "type": "text", "required": true, "order": 8, "help": "Town or community, house or street details and a nearby landmark. Add a GhanaPost GPS address if available."}, {"key": "home_languages", "section": "Child details", "label": "Which languages does your child speak or understand?", "type": "text", "required": true, "order": 9, "help": "For example: Twi, Fante, English, Ewe, Ga or another language."}, {"key": "guardian_name", "section": "Parent or guardian details", "label": "What is your full name?", "type": "text", "required": true, "order": 10}, {"key": "guardian_relationship", "section": "Parent or guardian details", "label": "What is your relationship to the child?", "type": "single", "required": true, "order": 11, "options": ["Mother", "Father", "Legal guardian", "Other authorised caregiver"]}, {"key": "guardian_phone", "section": "Parent or guardian details", "label": "What phone number should we use to contact you?", "type": "phone", "required": true, "order": 12, "help": "A Ghana number or an international number with country code."}, {"key": "guardian_email", "section": "Parent or guardian details", "label": "What is your email address?", "type": "email", "required": false, "order": 13, "help": "Optional. You may give a phone number only."}, {"key": "contact_method", "section": "Parent or guardian details", "label": "How would you prefer the school to contact you?", "type": "single", "required": true, "order": 14, "options": ["Phone call", "SMS", "WhatsApp", "Email"]}, {"key": "communication_language", "section": "Parent or guardian details", "label": "Which language would you prefer for school communication?", "type": "text", "required": true, "order": 15}, {"key": "second_guardian", "section": "Parent or guardian details", "label": "Is there another parent or guardian the school may contact?", "type": "text", "required": false, "order": 16, "help": "Optional: full name, relationship and phone number. Leave blank if not applicable."}, {"key": "emergency_name", "section": "Emergency and collection arrangements", "label": "Who should we contact if we cannot reach you?", "type": "text", "required": true, "order": 17, "help": "Choose another trusted adult and let them know you have listed them."}, {"key": "emergency_relationship", "section": "Emergency and collection arrangements", "label": "How is this emergency contact related to the child?", "type": "text", "required": true, "order": 18}, {"key": "emergency_phone", "section": "Emergency and collection arrangements", "label": "What is the emergency contact’s phone number?", "type": "phone", "required": true, "order": 19}, {"key": "authorised_pickup", "section": "Emergency and collection arrangements", "label": "Who may collect your child from school?", "type": "text", "required": true, "order": 20, "help": "List each adult’s full name, relationship and phone number. You may list yourself. Final identity checks will be agreed with the school."}, {"key": "collection_restrictions", "section": "Emergency and collection arrangements", "label": "Are there any collection or parental-contact restrictions the school should discuss with you?", "type": "single", "required": true, "order": 21, "options": ["No", "Yes — please contact me privately"], "help": "Do not upload court or custody documents here. Discuss any relevant restrictions privately with the school."}, {"key": "previous_schooling", "section": "Previous schooling and learning", "label": "Has your child attended a school, nursery or childcare centre before?", "type": "single", "required": true, "order": 22, "options": ["Yes", "No"]}, {"key": "previous_school_name", "section": "Previous schooling and learning", "label": "What is the name and location of the previous school or centre?", "type": "text", "required": false, "order": 23, "show_if": {"key": "previous_schooling", "equals": "Yes"}}, {"key": "previous_class", "section": "Previous schooling and learning", "label": "What class or group did the child last attend?", "type": "text", "required": false, "order": 24, "show_if": {"key": "previous_schooling", "equals": "Yes"}}, {"key": "reason_for_change", "section": "Previous schooling and learning", "label": "Why are you seeking a new school?", "type": "text", "required": false, "order": 25, "help": "Optional. For example: first school, relocation, teaching approach or learning support."}, {"key": "interests", "section": "Previous schooling and learning", "label": "What does your child enjoy? Choose all that apply.", "type": "multi", "required": false, "order": 26, "options": ["Stories and books", "Numbers and puzzles", "Building and making things", "Computers and technology", "Music and dance", "Drawing and art", "Sports and movement", "Plants and animals", "Other"], "help": "You may leave this blank if you are still discovering your child’s interests."}, {"key": "strengths", "section": "Previous schooling and learning", "label": "What does your child do well, or what makes them feel confident?", "type": "text", "required": false, "order": 27}, {"key": "support_sharing", "section": "Health and learning support", "label": "Would you like to share health or learning-support information on this form?", "type": "single", "required": true, "order": 28, "options": ["Yes — I agree to share relevant details for admission and support planning", "No — I prefer to discuss this privately"], "help": "Details are optional and will be available to authorised admissions staff. You may leave them blank and arrange a private discussion. These answers are not automatically scored or used to reject an application."}, {"key": "allergies", "section": "Health and learning support", "label": "Does your child have any allergies or food restrictions we should plan for?", "type": "text", "required": false, "order": 29, "help": "Optional: state the allergy or restriction and any important precautions. You may write None or Unsure.", "show_if": {"key": "support_sharing", "equals": "Yes — I agree to share relevant details for admission and support planning"}}, {"key": "health_needs", "section": "Health and learning support", "label": "Is there a health condition or emergency care need you would like to tell us about?", "type": "text", "required": false, "order": 30, "help": "Optional: share only what is relevant to safe school participation. Detailed care plans can be discussed privately.", "show_if": {"key": "support_sharing", "equals": "Yes — I agree to share relevant details for admission and support planning"}}, {"key": "school_medication", "section": "Health and learning support", "label": "Will your child need medicine during school hours?", "type": "single", "required": false, "order": 31, "options": ["No", "Yes — please contact me", "Unsure"], "help": "This form does not authorise staff to give medicine. Any arrangements must be agreed separately.", "show_if": {"key": "support_sharing", "equals": "Yes — I agree to share relevant details for admission and support planning"}}, {"key": "support_areas", "section": "Health and learning support", "label": "In which areas might your child benefit from support? Choose all that apply.", "type": "multi", "required": false, "order": 32, "options": ["Communication or language", "Hearing or vision access", "Movement or physical access", "Reading, writing or numbers", "Attention or managing emotions", "Toileting, feeding or personal care", "Settling into school", "Other"], "help": "A diagnosis is not required. Leave blank if no support is known.", "show_if": {"key": "support_sharing", "equals": "Yes — I agree to share relevant details for admission and support planning"}}, {"key": "helpful_support", "section": "Health and learning support", "label": "What helps your child learn, feel safe or take part?", "type": "text", "required": false, "order": 33, "help": "Optional: routines, communication methods, accessibility needs or other helpful arrangements.", "show_if": {"key": "support_sharing", "equals": "Yes — I agree to share relevant details for admission and support planning"}}, {"key": "transport_interest", "section": "Services and family expectations", "label": "Would you like information about school transport?", "type": "single", "required": false, "order": 34, "options": ["Yes", "No", "Not sure"], "help": "This is an expression of interest, not a confirmed service booking."}, {"key": "meal_interest", "section": "Services and family expectations", "label": "Would you like information about school meals?", "type": "single", "required": false, "order": 35, "options": ["Yes", "No", "Not sure"]}, {"key": "fee_information", "section": "Services and family expectations", "label": "What fee information would you like? Choose all that apply.", "type": "multi", "required": false, "order": 36, "options": ["Full fee schedule", "Payment dates", "Payment arrangements", "Any available financial support"], "help": "Submitting this form is not an agreement to an undisclosed fee."}, {"key": "parent_goals", "section": "Services and family expectations", "label": "What are the two most important things you want your child to gain from our school?", "type": "text", "required": false, "order": 37}, {"key": "referral_source", "section": "Services and family expectations", "label": "How did you hear about the school?", "type": "single", "required": false, "order": 38, "options": ["Friend or family", "Social media", "School website", "Radio", "Signboard or flyer", "School visit or event", "Other"]}, {"key": "other_information", "section": "Services and family expectations", "label": "Is there anything else you would like the school to know?", "type": "text", "required": false, "order": 39, "help": "Please do not repeat private health or custody details here; request a confidential discussion instead."}, {"key": "authority_confirmation", "section": "Declaration and submission", "label": "I am a parent, legal guardian or caregiver authorised to apply for this child.", "type": "single", "required": true, "order": 40, "options": ["Yes", "No"], "must_equal": "Yes"}, {"key": "accuracy_confirmation", "section": "Declaration and submission", "label": "I confirm that the information is accurate to the best of my knowledge.", "type": "single", "required": true, "order": 41, "options": ["Yes", "No"], "must_equal": "Yes"}, {"key": "data_consent", "section": "Declaration and submission", "label": "I agree that the school may use the information I provide to process this application, contact me and plan appropriate support.", "type": "single", "required": true, "order": 42, "options": ["Yes", "No"], "help": "Read the privacy notice before choosing. If you do not agree, contact the school to discuss another way to apply. This does not give permission for publicity or advertising.", "must_equal": "Yes"}, {"key": "signature_name", "section": "Declaration and submission", "label": "Type your full name to confirm your application.", "type": "text", "required": true, "order": 43, "help": "The date and time of submission will be recorded automatically. Submission does not guarantee admission."}, {"key": "marketing_updates", "section": "Declaration and submission", "label": "May the school send you optional news and promotional updates?", "type": "single", "required": false, "order": 44, "options": ["Yes", "No"], "help": "Optional. Leaving this blank means No. Your choice will not affect the admission decision. You may ask the school to stop these updates."}]}'::jsonb) ON CONFLICT (form_code) DO NOTHING;

-- Server validation uses the frozen question definition for the application's version.
CREATE OR REPLACE FUNCTION meg_adm_v1_private.validate_answers(
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
 SELECT definition INTO v_definition FROM public.meg_adm_v1_forms WHERE form_code=p_form_code;
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
    IF k='date_of_birth' AND v_date>current_date THEN RAISE EXCEPTION 'Date of birth cannot be in the future.'; END IF;
   END IF;
  END IF;
 END LOOP;
 IF p_complete AND p_answers->>'contact_method'='Email' AND coalesce(btrim(p_answers->>'guardian_email'),'')='' THEN
  RAISE EXCEPTION 'Please enter an email address or choose another contact method.';
 END IF;
END;
$fn$;
REVOKE ALL ON FUNCTION meg_adm_v1_private.validate_answers(jsonb,text,boolean) FROM PUBLIC, anon, authenticated;

-- Creates a draft when p_application_id is null, otherwise replaces ALL answers
-- on the parent's editable application. Send the complete answer object, not a patch.
CREATE OR REPLACE FUNCTION public.meg_adm_v1_save_draft(p_answers jsonb, p_application_id uuid DEFAULT NULL)
RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path=''
AS $fn$
DECLARE v_user uuid:=auth.uid(); v_id uuid; v_form text; v_status text;
BEGIN
 IF v_user IS NULL THEN RAISE EXCEPTION 'Please sign in before saving an application.'; END IF;
 IF p_application_id IS NULL THEN
  PERFORM meg_adm_v1_private.validate_answers(p_answers,'child_admission_v1',false);
  INSERT INTO public.meg_adm_v1_applications(owner_id,answers)
    VALUES(v_user,p_answers) RETURNING id INTO v_id;
 ELSE
  SELECT form_code,status INTO v_form,v_status FROM public.meg_adm_v1_applications
   WHERE id=p_application_id AND owner_id=v_user FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Application unavailable.'; END IF;
  IF v_status NOT IN ('draft','needs_changes') THEN RAISE EXCEPTION 'This application has been submitted. Ask the school to reopen it for corrections.'; END IF;
  PERFORM meg_adm_v1_private.validate_answers(p_answers,v_form,false);
  UPDATE public.meg_adm_v1_applications SET answers=p_answers,updated_at=now() WHERE id=p_application_id;
  v_id:=p_application_id;
 END IF;
 RETURN v_id;
END;
$fn$;
REVOKE ALL ON FUNCTION public.meg_adm_v1_save_draft(jsonb,uuid) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.meg_adm_v1_save_draft(jsonb,uuid) TO authenticated;

CREATE OR REPLACE FUNCTION public.meg_adm_v1_submit(p_application_id uuid)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path=''
AS $fn$
DECLARE a public.meg_adm_v1_applications%ROWTYPE;
BEGIN
 IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Please sign in before submitting.'; END IF;
 SELECT * INTO a FROM public.meg_adm_v1_applications
  WHERE id=p_application_id AND owner_id=auth.uid() FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Application unavailable.'; END IF;
 IF a.status NOT IN ('draft','needs_changes') THEN RAISE EXCEPTION 'Application already submitted or closed.'; END IF;
 PERFORM meg_adm_v1_private.validate_answers(a.answers,a.form_code,true);
 UPDATE public.meg_adm_v1_applications
 SET status='submitted',submitted_at=coalesce(submitted_at,now()),last_submitted_at=now(),
     parent_message=NULL,updated_at=now()
 WHERE id=a.id;
 RETURN jsonb_build_object('application_id',a.id,'status','submitted','message',
  'Your application has been submitted. Keep this reference. The school will contact you about the next steps. Submission does not guarantee admission.');
END;
$fn$;
REVOKE ALL ON FUNCTION public.meg_adm_v1_submit(uuid) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.meg_adm_v1_submit(uuid) TO authenticated;

CREATE OR REPLACE FUNCTION public.meg_adm_v1_review(
 p_application_id uuid, p_status text, p_parent_message text DEFAULT NULL, p_internal_note text DEFAULT NULL)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path=''
AS $fn$
DECLARE v_previous text;
BEGIN
 IF NOT public.meg_adm_v1_is_staff() THEN RAISE EXCEPTION 'School staff authorisation is required.'; END IF;
 IF p_status IS NULL OR p_status NOT IN ('under_review','needs_changes','offered','waitlisted','not_offered','withdrawn') THEN
  RAISE EXCEPTION 'Invalid review status.';
 END IF;
 IF coalesce(length(p_parent_message),0)>4000 OR coalesce(length(p_internal_note),0)>4000 THEN
  RAISE EXCEPTION 'Keep each review message below 4000 characters.';
 END IF;
 IF p_status='needs_changes' AND coalesce(btrim(p_parent_message),'')='' THEN
  RAISE EXCEPTION 'Explain which corrections the parent should make.';
 END IF;
 SELECT status INTO v_previous FROM public.meg_adm_v1_applications WHERE id=p_application_id FOR UPDATE;
 IF NOT FOUND OR v_previous='draft' THEN RAISE EXCEPTION 'No submitted application available.'; END IF;
 UPDATE public.meg_adm_v1_applications SET status=p_status,parent_message=nullif(btrim(p_parent_message),''),
  reviewed_at=now(),updated_at=now() WHERE id=p_application_id;
 INSERT INTO public.meg_adm_v1_review_log(application_id,reviewer_id,previous_status,new_status,parent_message,internal_note)
 VALUES(p_application_id,auth.uid(),v_previous,p_status,nullif(btrim(p_parent_message),''),nullif(btrim(p_internal_note),''));
END;
$fn$;
REVOKE ALL ON FUNCTION public.meg_adm_v1_review(uuid,text,text,text) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.meg_adm_v1_review(uuid,text,text,text) TO authenticated;

-- Smoke checks run within the installation transaction. No test family data is saved.
DO $check$
DECLARE v_bad_rejected boolean:=false;
BEGIN
 IF jsonb_array_length((SELECT definition->'questions' FROM public.meg_adm_v1_forms WHERE form_code='child_admission_v1'))<>44 THEN
  RAISE EXCEPTION 'Expected 44 questionnaire fields.';
 END IF;
 PERFORM meg_adm_v1_private.validate_answers('{}'::jsonb,'child_admission_v1',false);
 BEGIN
  PERFORM meg_adm_v1_private.validate_answers('{}'::jsonb,'child_admission_v1',true);
 EXCEPTION WHEN raise_exception THEN v_bad_rejected:=true;
 END;
 IF NOT v_bad_rejected THEN RAISE EXCEPTION 'Required-question validation failed.'; END IF;
 IF has_table_privilege('anon','public.meg_adm_v1_applications','SELECT')
 OR has_table_privilege('authenticated','public.meg_adm_v1_applications','INSERT')
 OR has_table_privilege('authenticated','public.meg_adm_v1_applications','UPDATE')
 OR has_table_privilege('authenticated','meg_adm_v1_private.staff','INSERT') THEN
  RAISE EXCEPTION 'Unexpected application permissions.';
 END IF;
END;
$check$;
COMMIT;
SELECT form_code, jsonb_array_length(definition->'questions') AS questions_loaded
 FROM public.meg_adm_v1_forms WHERE form_code='child_admission_v1';

-- SCHOOL SETUP AFTER INSTALLATION
-- 1. Enable a suitable Supabase Auth sign-in method for parents and staff.
-- 2. The administrator authorises each admissions staff account in SQL Editor:
--    INSERT INTO meg_adm_v1_private.staff(user_id) VALUES ('REAL-STAFF-AUTH-USER-UUID')
--    ON CONFLICT DO NOTHING;
--    Use the exact user's ID from Authentication > Users; never put a guessed ID here.
--    To revoke access, delete that staff row as the project administrator.
-- 3. Connect a parent form to public.meg_adm_v1_forms.definition.questions.
--    Render text/phone/email/date inputs, single-choice buttons/dropdowns and multi-select
--    checkboxes. Mark required fields. Respect show_if, and clear answers when hidden.
--    Use short sections, Save draft and Submit application buttons. No countdown.
-- 4. Parent RPC meg_adm_v1_save_draft:
--    {p_answers: {child_full_name: '...', ...}, p_application_id: null}
--    Keep the returned UUID. For edits, pass it and the complete current answer object.
-- 5. Parent RPC meg_adm_v1_submit: {p_application_id: returned UUID}.
--    Validation errors identify missing/invalid responses. Display them helpfully.
--    The submitted record is immediately available to authorised staff; no email is sent.
-- 6. Parents SELECT their own meg_adm_v1_applications for reference/status/messages.
--    Staff SELECT submitted applications, and call meg_adm_v1_review to change status.
--    Private staff notes are in meg_adm_v1_review_log, not parent-visible application rows.
--    needs_changes reopens the parent's answers; they save and submit again.
-- 7. Marketing permission is only affirmative when answers->>'marketing_updates' = 'Yes'.
--    Empty/missing/No means no optional marketing. Do not infer publicity/photo permission.
-- 8. Public admission form definitions are safe to read without signing in. Applications
--    are not public. The private schema must remain outside the Data API exposed schemas.
-- 9. Project administrators can manage records in the dashboard. Decide retention and
--    deletion processes, and verify parent A/parent B/staff access before launch.
