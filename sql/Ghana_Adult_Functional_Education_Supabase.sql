-- GHANA ADULT FUNCTIONAL LEARNING DISCOVERY QUIZ
-- Audience: adults aged 18 and above. Approximate Primary 4 difficulty.
-- INSTALL: Supabase project > SQL Editor > New query. Paste this whole file
-- and click Run as postgres. Expected final counts: 20 questions and 20 keys.
-- Uses dedicated adult_functional_p4_v1_* names; does not alter the STEM quiz.
-- Safe to rerun this version: it updates its seeded questions, not duplicates.
-- Questions and quiz information are public read-only; keys/explanations are
-- restricted to the owner and trusted backend service_role.
-- Scoring is server-side only. Never expose the service-role key to learners.
-- No learners, contact details or attempts are stored. No quiz website is created.
--
-- ORIGINAL EDUCATIONAL CONTENT, not a NaCCA-approved or validated assessment.
-- Reading/writing/numeracy use approximate Primary 4 difficulty. Civic, global
-- and financial scenarios are adult applications, not exact curriculum indicators.
-- MCQs test writing awareness, not actual writing performance.
-- English reading questions should first be attempted without passage read-aloud.
-- If read aloud/translated, record the support and interpret as supported
-- comprehension, not independent English reading. Other items may use audio.
-- Permit paper, pointing or spoken answers; record calculator/help use.
-- Allow roughly 20-25 minutes without a countdown or speed points.
-- Primary 4 describes task difficulty, never the adult's worth or intelligence.
--
-- SOURCES consulted 25 September 2026:
-- https://nacca.gov.gh/wp-content/uploads/2019/04/ENGLISH-UPPER-PRIMARY-B4-B6.pdf
-- https://nacca.gov.gh/wp-content/uploads/2019/04/MATHS-UPPER-PRIMARY-B4-B6.pdf
-- https://ec.gov.gh/voting/
-- https://www.csa.gov.gh/mobile_money_fraud.php
-- Security design follows https://supabase.com/docs/guides/database/postgres/row-level-security

BEGIN;

CREATE TABLE IF NOT EXISTS public.adult_functional_p4_v1_questions (
  question_number integer PRIMARY KEY CHECK (question_number BETWEEN 1 AND 20),
  category text NOT NULL,
  question_text text NOT NULL,
  option_a text NOT NULL,
  option_b text NOT NULL,
  option_c text NOT NULL,
  difficulty_level text NOT NULL DEFAULT 'Approximate Primary 4'
);
CREATE TABLE IF NOT EXISTS public.adult_functional_p4_v1_answer_keys (
  question_number integer PRIMARY KEY REFERENCES public.adult_functional_p4_v1_questions(question_number),
  correct_answer text NOT NULL CHECK (correct_answer IN ('A','B','C')),
  explanation text NOT NULL
);

ALTER TABLE public.adult_functional_p4_v1_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.adult_functional_p4_v1_answer_keys ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.adult_functional_p4_v1_questions FROM PUBLIC, anon, authenticated;
REVOKE ALL ON public.adult_functional_p4_v1_answer_keys FROM PUBLIC, anon, authenticated;
GRANT SELECT ON public.adult_functional_p4_v1_questions TO anon, authenticated;
GRANT ALL ON public.adult_functional_p4_v1_questions, public.adult_functional_p4_v1_answer_keys TO service_role;
DROP POLICY IF EXISTS adult_functional_p4_v1_public_read ON public.adult_functional_p4_v1_questions;
CREATE POLICY adult_functional_p4_v1_public_read ON public.adult_functional_p4_v1_questions
  FOR SELECT TO anon, authenticated USING (true);
-- No client policy on answer keys: children cannot fetch the correct answers.

INSERT INTO public.adult_functional_p4_v1_questions
 (question_number, category, question_text, option_a, option_b, option_c)
VALUES
 (1, 'Functional reading', 'A notice says: “Adult class starts at 6 p.m. Bring a notebook.” What should you bring?', 'A notebook', 'A cooking pot', 'A football'),
 (2, 'Functional reading', 'A shop notice says: “Closed on Sundays.” On which day is the shop closed?', 'Friday', 'Sunday', 'Monday'),
 (3, 'Functional reading', 'Read this message: “Abena, your order is ready. Collect it after 2 p.m.” When should Abena collect the order?', 'Before 10 a.m.', 'At noon', 'After 2 p.m.'),
 (4, 'Writing awareness', 'Which sentence uses capital letters and punctuation correctly?', 'i live in kumasi.', 'I live in Kumasi.', 'I live in kumasi'),
 (5, 'Writing awareness', 'You cannot attend class today because you are ill. Which message clearly tells your teacher this?', 'Class today teacher.', 'I will attend class today.', 'I am ill and cannot attend class today.'),
 (6, 'Basic mathematics', 'A trader packs 6 oranges in each bag. How many oranges are in 4 bags?', '24', '10', '18'),
 (7, 'Basic mathematics', 'Share 20 exercise books equally among 5 learners. How many books does each learner receive?', '5', '4', '15'),
 (8, 'Basic mathematics', 'A meeting starts at 9 a.m. and ends at 11 a.m. How long does it last?', '1 hour', '3 hours', '2 hours'),
 (9, 'Logical reasoning', 'A delivery worker visits houses numbered 5, 10, 15, 20. If the pattern continues, which number comes next?', '25', '21', '30'),
 (10, 'Logical reasoning', 'At a service counter, Ama arrived before Kojo. Esi arrived after Kojo. People are served in arrival order. Who should be served first?', 'Kojo', 'Ama', 'Esi'),
 (11, 'Basic technology', 'You want to send a spoken message on a phone messaging app. Which symbol usually starts a voice recording?', 'A camera', 'A rubbish bin', 'A microphone'),
 (12, 'Basic technology', 'Someone calls and asks for your mobile money PIN to give you a prize. What should you do?', 'Keep the PIN private and end the call', 'Tell the caller your PIN', 'Send the PIN by text'),
 (13, 'Basic technology', 'Before confirming a mobile money transfer, what should you check?', 'Only the phone battery level', 'The recipient details and the amount', 'Only the time on the phone'),
 (14, 'Basic civic education', 'What is the minimum age for a Ghanaian citizen to register to vote, if the other legal requirements are met?', '16 years', '21 years', '18 years'),
 (15, 'Basic civic education', 'At a community meeting, someone has a different opinion. What is a respectful response?', 'Listen, then explain your view calmly', 'Stop the person from speaking', 'Insult the person'),
 (16, 'Global affairs', 'A news report says Ghana sells cocoa to a company in another country. What is this an example of?', 'A local school lesson', 'Trade between countries', 'A community clean-up'),
 (17, 'Global affairs', 'A report says: “Two countries are holding peace talks.” What are the countries trying to do?', 'Begin a football match', 'Change the weather', 'Discuss how to settle a disagreement peacefully'),
 (18, 'Everyday finances', 'You buy goods costing GH₵35 and pay GH₵50. How much change should you receive?', 'GH₵15', 'GH₵25', 'GH₵85'),
 (19, 'Everyday finances', 'Your weekly budget is GH₵100. Food costs GH₵60 and transport costs GH₵25. How much is left?', 'GH₵35', 'GH₵15', 'GH₵25'),
 (20, 'Everyday finances', 'You save GH₵10 each week for 4 weeks and do not withdraw any money. How much have you saved?', 'GH₵14', 'GH₵30', 'GH₵40')
ON CONFLICT (question_number) DO UPDATE SET
 category = EXCLUDED.category, question_text = EXCLUDED.question_text,
 option_a = EXCLUDED.option_a, option_b = EXCLUDED.option_b, option_c = EXCLUDED.option_c;
INSERT INTO public.adult_functional_p4_v1_answer_keys
 (question_number, correct_answer, explanation)
VALUES
 (1, 'A', 'The notice asks learners to bring a notebook.'),
 (2, 'B', 'The notice names Sunday as the closed day.'),
 (3, 'C', 'The message says to collect the order after 2 p.m.'),
 (4, 'B', 'A sentence begins with a capital letter; Kumasi is a place name, and the sentence ends with a full stop.'),
 (5, 'C', 'The message states both the reason and that you cannot attend.'),
 (6, 'A', '6 multiplied by 4 is 24.'),
 (7, 'B', '20 divided by 5 is 4.'),
 (8, 'C', 'From 9 a.m. to 11 a.m. is 2 hours.'),
 (9, 'A', 'Add 5 each time.'),
 (10, 'B', 'Ama arrived before Kojo, who arrived before Esi.'),
 (11, 'C', 'A microphone symbol usually identifies voice recording.'),
 (12, 'A', 'Keep your mobile money PIN private, including from people claiming to offer prizes.'),
 (13, 'B', 'Check that the intended recipient and amount are correct before confirming.'),
 (14, 'C', 'The minimum age is 18; other registration requirements also apply.'),
 (15, 'A', 'Respectful discussion allows people to express different views peacefully.'),
 (16, 'B', 'Buying and selling goods across countries is international trade.'),
 (17, 'C', 'Peace talks aim to find a peaceful way to settle a conflict or disagreement.'),
 (18, 'A', '50 minus 35 is 15.'),
 (19, 'B', '60 plus 25 is 85; 100 minus 85 is 15.'),
 (20, 'C', '10 multiplied by 4 is 40.')
ON CONFLICT (question_number) DO UPDATE SET correct_answer=EXCLUDED.correct_answer, explanation=EXCLUDED.explanation;

-- Input: JSON object mapping question numbers to A, B, C or null.
-- Example: {"1":"B","2":"A","3":null}. Missing/null = unanswered = 0 points.
-- Invalid question numbers or choices are rejected. No negative marking.
CREATE OR REPLACE FUNCTION public.adult_functional_p4_v1_score(p_answers jsonb)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = ''
AS $function$
DECLARE
  v_score integer;
  v_answered integer;
  v_categories jsonb;
  v_band text;
BEGIN
  IF p_answers IS NULL OR pg_catalog.jsonb_typeof(p_answers) <> 'object' THEN
    RAISE EXCEPTION 'Answers must be a JSON object keyed by question number.';
  END IF;
  IF EXISTS (
    SELECT 1 FROM pg_catalog.jsonb_each(p_answers) AS a
    WHERE a.key !~ '^([1-9]|1[0-9]|20)$'
       OR a.value NOT IN ('"A"'::jsonb, '"B"'::jsonb, '"C"'::jsonb, 'null'::jsonb)
  ) THEN
    RAISE EXCEPTION 'Use question numbers 1 to 20 and answer A, B, C or null.';
  END IF;
  IF (SELECT count(*) FROM public.adult_functional_p4_v1_answer_keys) <> 20 THEN
    RAISE EXCEPTION 'The quiz answer key is incomplete.';
  END IF;
  SELECT count(*) FILTER (WHERE p_answers ->> k.question_number::text = k.correct_answer),
         count(*) FILTER (WHERE p_answers ->> k.question_number::text IS NOT NULL)
  INTO v_score, v_answered
  FROM public.adult_functional_p4_v1_answer_keys AS k;

  SELECT pg_catalog.jsonb_object_agg(c.category,
    pg_catalog.jsonb_build_object('score', c.score, 'maximum', c.maximum))
  INTO v_categories
  FROM (
    SELECT q.category,
      count(*) FILTER (WHERE p_answers ->> q.question_number::text = k.correct_answer) AS score,
      count(*) AS maximum
    FROM public.adult_functional_p4_v1_questions AS q
    JOIN public.adult_functional_p4_v1_answer_keys AS k USING (question_number)
    GROUP BY q.category
  ) AS c;

  v_band := CASE WHEN v_score <= 7 THEN 'Start with supported foundation lessons'
                 WHEN v_score <= 12 THEN 'Build everyday reading and number skills'
                 WHEN v_score <= 16 THEN 'Begin guided functional learning tasks'
                 ELSE 'Try more independent functional learning tasks' END;
  RETURN pg_catalog.jsonb_build_object(
    'score', v_score, 'maximum', 20, 'percentage', v_score * 5,
    'answered', v_answered, 'unanswered', 20 - v_answered,
    'category_scores', v_categories, 'suggested_starting_point', v_band,
    'interpretation', 'Provisional teaching guide, not a validated readiness or admission decision. Every adult can learn with suitable support. This quiz does not establish school-grade equivalence.'
  );
END;
$function$;
REVOKE ALL ON FUNCTION public.adult_functional_p4_v1_score(jsonb) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.adult_functional_p4_v1_score(jsonb) TO service_role;


CREATE TABLE IF NOT EXISTS public.adult_functional_p4_v1_info (
 id integer PRIMARY KEY CHECK (id=1), details jsonb NOT NULL
);
ALTER TABLE public.adult_functional_p4_v1_info ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.adult_functional_p4_v1_info FROM PUBLIC, anon, authenticated;
GRANT SELECT ON public.adult_functional_p4_v1_info TO anon, authenticated;
GRANT ALL ON public.adult_functional_p4_v1_info TO service_role;
DROP POLICY IF EXISTS adult_functional_p4_v1_info_read ON public.adult_functional_p4_v1_info;
CREATE POLICY adult_functional_p4_v1_info_read ON public.adult_functional_p4_v1_info
 FOR SELECT TO anon, authenticated USING (true);
INSERT INTO public.adult_functional_p4_v1_info (id, details) VALUES
 (1, '{"title": "Everyday Skills Discovery Challenge", "audience": "Adults aged 18 and above in Ghana", "difficulty": "Approximately Primary 4; adult situations and respectful language", "instructions": "Choose one answer per question. You may choose I am not sure yet. Take your time; this is a starting point for learning, not a pass-or-fail examination.", "marketing_message": "Build confidence for everyday life. Practise reading messages, writing clearly, working with money, using phones safely and understanding the world. Try our 20-question Everyday Skills Discovery Challenge and discover your next learning step. Ask about our adult functional education programme. Your experience matters, and it is never too late to learn.", "score_bands": [{"minimum": 0, "maximum": 7, "guidance": "Start with supported foundation lessons"}, {"minimum": 8, "maximum": 12, "guidance": "Build everyday reading and number skills"}, {"minimum": 13, "maximum": 16, "guidance": "Begin guided functional learning tasks"}, {"minimum": 17, "maximum": 20, "guidance": "Try more independent functional learning tasks"}], "limitations": "Provisional teaching bands, not validated cutoffs or admission rules. Two or three items per area give only a brief snapshot. MCQs do not directly measure writing. Do not claim a school-grade placement from this score.", "follow_up": "Ask the adult to read a short notice and write a two-sentence message. Discuss goals, language and previous schooling. Use the combined evidence to plan support.", "digital_design": "One question per screen; large buttons; progress bar; no speed points. Optional audio except during independent reading assessment. Use null for unsure/unanswered. Show supportive results privately. Do not require marketing consent to see a result."}'::jsonb)
ON CONFLICT (id) DO UPDATE SET details=EXCLUDED.details;

-- Installation checks: abort this transaction if the loaded data is incomplete.
DO $checks$
DECLARE result jsonb;
BEGIN
 IF (SELECT count(*) FROM public.adult_functional_p4_v1_questions) <> 20
 OR (SELECT count(*) FROM public.adult_functional_p4_v1_answer_keys) <> 20 THEN
   RAISE EXCEPTION 'Expected exactly 20 questions and answer keys.';
 END IF;
 SELECT public.adult_functional_p4_v1_score(
   (SELECT jsonb_object_agg(question_number::text, correct_answer)
    FROM public.adult_functional_p4_v1_answer_keys)) INTO result;
 IF (result->>'score')::integer <> 20 THEN RAISE EXCEPTION 'Perfect score check failed'; END IF;
 SELECT public.adult_functional_p4_v1_score('{}'::jsonb) INTO result;
 IF (result->>'score')::integer <> 0 OR (result->>'unanswered')::integer <> 20 THEN
   RAISE EXCEPTION 'Empty response check failed';
 END IF;
 IF has_table_privilege('anon','public.adult_functional_p4_v1_answer_keys','SELECT')
 OR has_table_privilege('authenticated','public.adult_functional_p4_v1_answer_keys','SELECT') THEN
   RAISE EXCEPTION 'Answer keys must not be publicly readable';
 END IF;
END;
$checks$;
COMMIT;

SELECT
 (SELECT count(*) FROM public.adult_functional_p4_v1_questions) AS questions_loaded,
 (SELECT count(*) FROM public.adult_functional_p4_v1_answer_keys) AS answer_keys_loaded;

-- AFTER INSTALLATION
-- Table Editor > adult_functional_p4_v1_questions to see the questions.
-- Order by question_number in your quiz application.
-- Table Editor > adult_functional_p4_v1_info for instructions and marketing copy.
-- The owner can inspect the separate answer-key table in the dashboard.
-- Scoring example in SQL Editor, expected 2/20 (uncomment to run):
-- SELECT public.adult_functional_p4_v1_score('{"1":"A","2":"B"}'::jsonb);
-- Trusted backend RPC: adult_functional_p4_v1_score, argument p_answers.
-- Missing answers and JSON null score zero. Invalid keys or choices are rejected.
-- Returns total, percentage, answered/unanswered, category scores and guidance.
-- Scoring does not save results. A frontend and result-storage design are separate.
