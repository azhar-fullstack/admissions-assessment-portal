-- Require authenticated login before assessment questions can be read/scored.
-- Frontend also gates quizzes behind signup/sign-in.

-- STEM quiz questions: authenticated only
REVOKE SELECT ON public.stem_lp_v1_questions FROM anon;
DROP POLICY IF EXISTS stem_lp_v1_public_read ON public.stem_lp_v1_questions;
CREATE POLICY stem_lp_v1_auth_read ON public.stem_lp_v1_questions
  FOR SELECT TO authenticated USING (true);

-- Adult quiz questions + info: authenticated only
REVOKE SELECT ON public.adult_functional_p4_v1_questions FROM anon;
REVOKE SELECT ON public.adult_functional_p4_v1_info FROM anon;
DROP POLICY IF EXISTS adult_functional_p4_v1_public_read ON public.adult_functional_p4_v1_questions;
DROP POLICY IF EXISTS adult_functional_p4_v1_info_read ON public.adult_functional_p4_v1_info;
CREATE POLICY adult_functional_p4_v1_auth_read ON public.adult_functional_p4_v1_questions
  FOR SELECT TO authenticated USING (true);
CREATE POLICY adult_functional_p4_v1_info_auth_read ON public.adult_functional_p4_v1_info
  FOR SELECT TO authenticated USING (true);

-- Scoring RPCs: authenticated only (no anonymous scoring)
REVOKE EXECUTE ON FUNCTION public.stem_lp_v1_score_safe(jsonb) FROM anon;
REVOKE EXECUTE ON FUNCTION public.adult_functional_p4_v1_score_safe(jsonb) FROM anon;
GRANT EXECUTE ON FUNCTION public.stem_lp_v1_score_safe(jsonb) TO authenticated;
GRANT EXECUTE ON FUNCTION public.adult_functional_p4_v1_score_safe(jsonb) TO authenticated;
