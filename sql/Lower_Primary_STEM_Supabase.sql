-- LOWER PRIMARY STEM DISCOVERY QUIZ | Ghana Basic 1 to 3
-- INSTALL: Open your Supabase project > SQL Editor > New query.
-- Paste this entire file and click Run. The final result should show 20 and 20.
-- Run with the SQL Editor's postgres role.
-- This creates dedicated stem_lp_v1_* objects; it does not alter other quizzes.
-- Rerunning updates these same 20 questions and keys without duplicating them.
-- No child names, contact details, responses or scores are stored by this file.
-- This is a database setup, not a quiz website.
--
-- Questions are readable by the quiz website. Keys are restricted to the backend.
-- Scoring is available to service_role (trusted server) and the database owner.
-- Never put a service-role key in a browser or mobile application.
--
-- Curriculum basis: NaCCA lower-primary Mathematics and Science (2019).
-- https://nacca.gov.gh/wp-content/uploads/2019/04/MATHS-LOWER-PRIMARY-22-3-2019.pdf
-- https://nacca.gov.gh/wp-content/uploads/2019/04/SCIENCE-LOWER-PRIMARY-B1-B3.pdf
-- Technology and design items are introductory applications, not a B1-B3
-- Computing examination. This original quiz is not a validated readiness test
-- or a NaCCA-approved assessment. Bands below are provisional teaching guides.
-- Consider age, class, language, prior exposure and practical observations.

BEGIN;

CREATE TABLE IF NOT EXISTS public.stem_lp_v1_questions (
  question_number integer PRIMARY KEY CHECK (question_number BETWEEN 1 AND 20),
  category text NOT NULL,
  question_text text NOT NULL,
  option_a text NOT NULL,
  option_b text NOT NULL,
  option_c text NOT NULL,
  target_classes text NOT NULL DEFAULT 'Basic 1–3'
);
CREATE TABLE IF NOT EXISTS public.stem_lp_v1_answer_keys (
  question_number integer PRIMARY KEY REFERENCES public.stem_lp_v1_questions(question_number),
  correct_answer text NOT NULL CHECK (correct_answer IN ('A','B','C'))
);

ALTER TABLE public.stem_lp_v1_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stem_lp_v1_answer_keys ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.stem_lp_v1_questions FROM PUBLIC, anon, authenticated;
REVOKE ALL ON public.stem_lp_v1_answer_keys FROM PUBLIC, anon, authenticated;
GRANT SELECT ON public.stem_lp_v1_questions TO anon, authenticated;
GRANT ALL ON public.stem_lp_v1_questions, public.stem_lp_v1_answer_keys TO service_role;
DROP POLICY IF EXISTS stem_lp_v1_public_read ON public.stem_lp_v1_questions;
CREATE POLICY stem_lp_v1_public_read ON public.stem_lp_v1_questions
  FOR SELECT TO anon, authenticated USING (true);
-- No client policy on answer keys: children cannot fetch the correct answers.

INSERT INTO public.stem_lp_v1_questions
  (question_number, category, question_text, option_a, option_b, option_c)
VALUES
  (1, 'Numbers and Patterns', 'Ama is building a toy car. She has 3 wheels and gets 1 more. How many wheels does she have now?', '3', '4', '5'),
  (2, 'Numbers and Patterns', 'Kofi has 7 bottle tops. He uses 2 to make a toy. How many bottle tops are left?', '5', '7', '9'),
  (3, 'Numbers and Patterns', 'A robot flashes these shapes: circle, square, circle, square, circle. What comes next?', 'Triangle', 'Circle', 'Square'),
  (4, 'Numbers and Patterns', 'Which shape has exactly 3 straight sides?', 'Circle', 'Triangle', 'Square'),
  (5, 'Numbers and Patterns', 'Children choose what to build: 5 choose a car, 3 choose a boat and 2 choose a house. Which project gets the most votes?', 'Car', 'Boat', 'House'),
  (6, 'Science and Observation', 'Which one is a living thing?', 'A stone', 'A plastic cup', 'A growing maize plant'),
  (7, 'Science and Observation', 'Which part of a maize plant is usually under the soil?', 'Leaves', 'Roots', 'Flowers'),
  (8, 'Science and Observation', 'You want to find out whether a stone is rough or smooth. What is the best way?', 'Listen to it', 'Smell it', 'Gently feel it'),
  (9, 'Science and Observation', 'Rain is coming! Which material would make the best waterproof cover for a toy?', 'A plastic sheet without holes', 'A paper tissue', 'A piece of cotton wool'),
  (10, 'Science and Observation', 'You want to find out whether a leaf floats. What should you do?', 'Measure its length', 'Put it gently in water and watch', 'Put it beside the water'),
  (11, 'Technology Exploration', 'You want to keep a picture of your class project on a tablet. Which tool should you use?', 'The camera', 'The calculator', 'The music player'),
  (12, 'Technology Exploration', 'A learning game says, “Tap the triangle.” What should you do?', 'Touch every shape', 'Touch the circle', 'Touch the triangle once'),
  (13, 'Technology Exploration', 'A toy robot follows commands. You tell it, “Move forward 1 step. Then move forward 1 more step.” How many steps does it move altogether?', '1', '2', '3'),
  (14, 'Technology Exploration', 'Your hands are wet after washing. What should you do before using the class tablet?', 'Dry your hands', 'Wipe your hands on the tablet', 'Tap the screen with wet fingers'),
  (15, 'Technology Exploration', 'A game freezes and does not respond. What should you do first?', 'Hit the screen', 'Pull its cover off', 'Tell the teacher and ask for help'),
  (16, 'Building and Problem Solving', 'A toy car needs wheels that roll easily. Which shape should you choose?', 'Square', 'Circle', 'Triangle'),
  (17, 'Building and Problem Solving', 'Your paper bridge bends when you place a toy car on it. What could help support the middle?', 'Colour the bridge', 'Put a heavier car on it', 'Place a block underneath the middle'),
  (18, 'Building and Problem Solving', 'Your block tower keeps falling. Which change is most likely to help?', 'Make the bottom wider', 'Put the biggest block at the very top', 'Make the bottom narrower'),
  (19, 'Building and Problem Solving', 'You want to find out which of two paper bridges holds more bottle tops. What makes the test fair?', 'Use wet bottle tops on one bridge and dry ones on the other', 'Use the same kind of bottle tops and add them in the same way', 'Hold up only one bridge with your hand'),
  (20, 'Building and Problem Solving', 'You are making a toy boat. Which order makes the most sense?', 'Test it → choose materials → build it', 'Build it → test it → choose materials', 'Choose materials → build it → test it')
ON CONFLICT (question_number) DO UPDATE SET
 category = EXCLUDED.category, question_text = EXCLUDED.question_text,
 option_a = EXCLUDED.option_a, option_b = EXCLUDED.option_b, option_c = EXCLUDED.option_c;

INSERT INTO public.stem_lp_v1_answer_keys (question_number, correct_answer)
VALUES
  (1, 'B'),
  (2, 'A'),
  (3, 'C'),
  (4, 'B'),
  (5, 'A'),
  (6, 'C'),
  (7, 'B'),
  (8, 'C'),
  (9, 'A'),
  (10, 'B'),
  (11, 'A'),
  (12, 'C'),
  (13, 'B'),
  (14, 'A'),
  (15, 'C'),
  (16, 'B'),
  (17, 'C'),
  (18, 'A'),
  (19, 'B'),
  (20, 'C')
ON CONFLICT (question_number) DO UPDATE SET correct_answer = EXCLUDED.correct_answer;

-- Input: JSON object mapping question numbers to A, B, C or null.
-- Example: {"1":"B","2":"A","3":null}. Missing/null = unanswered = 0 points.
-- Invalid question numbers or choices are rejected. No negative marking.
CREATE OR REPLACE FUNCTION public.stem_lp_v1_score(p_answers jsonb)
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
  IF (SELECT count(*) FROM public.stem_lp_v1_answer_keys) <> 20 THEN
    RAISE EXCEPTION 'The quiz answer key is incomplete.';
  END IF;
  SELECT count(*) FILTER (WHERE p_answers ->> k.question_number::text = k.correct_answer),
         count(*) FILTER (WHERE p_answers ->> k.question_number::text IS NOT NULL)
  INTO v_score, v_answered
  FROM public.stem_lp_v1_answer_keys AS k;

  SELECT pg_catalog.jsonb_object_agg(c.category,
    pg_catalog.jsonb_build_object('score', c.score, 'maximum', c.maximum))
  INTO v_categories
  FROM (
    SELECT q.category,
      count(*) FILTER (WHERE p_answers ->> q.question_number::text = k.correct_answer) AS score,
      count(*) AS maximum
    FROM public.stem_lp_v1_questions AS q
    JOIN public.stem_lp_v1_answer_keys AS k USING (question_number)
    GROUP BY q.category
  ) AS c;

  v_band := CASE WHEN v_score <= 7 THEN 'Explore with close guidance'
                 WHEN v_score <= 12 THEN 'Build the foundations'
                 WHEN v_score <= 16 THEN 'Try guided STEM projects'
                 ELSE 'Offer extra challenge' END;
  RETURN pg_catalog.jsonb_build_object(
    'score', v_score, 'maximum', 20, 'percentage', v_score * 5,
    'answered', v_answered, 'unanswered', 20 - v_answered,
    'category_scores', v_categories, 'suggested_starting_point', v_band,
    'interpretation', 'Provisional teaching guide, not a validated readiness or admission decision. Every child can begin STEM at an appropriate level.'
  );
END;
$function$;
REVOKE ALL ON FUNCTION public.stem_lp_v1_score(jsonb) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.stem_lp_v1_score(jsonb) TO service_role;

COMMIT;

SELECT
 (SELECT count(*) FROM public.stem_lp_v1_questions) AS questions_loaded,
 (SELECT count(*) FROM public.stem_lp_v1_answer_keys) AS answer_keys_loaded;

-- VIEW QUESTIONS: In Table Editor, select stem_lp_v1_questions.
-- The answer-key table is visible to the project administrator in the dashboard.
-- A quiz website must sort questions by question_number.
-- To try scoring from SQL Editor, uncomment this example (expected: 2/20):
-- SELECT public.stem_lp_v1_score('{"1":"B","2":"A"}'::jsonb);
-- A trusted backend may call the RPC stem_lp_v1_score with p_answers.
-- This function returns a result; it does not save an attempt or create a website.
