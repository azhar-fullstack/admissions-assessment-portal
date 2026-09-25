-- Secure scoring wrappers for browser portals (authenticated staff / sessions).
-- Original *_score functions stay service_role-only; these SECURITY DEFINER wrappers
-- allow the live quiz UIs to score without exposing answer keys to clients.

CREATE OR REPLACE FUNCTION public.stem_lp_v1_score_safe(p_answers jsonb)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN public.stem_lp_v1_score(p_answers);
END;
$$;
REVOKE ALL ON FUNCTION public.stem_lp_v1_score_safe(jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.stem_lp_v1_score_safe(jsonb) TO anon, authenticated;

CREATE OR REPLACE FUNCTION public.adult_functional_p4_v1_score_safe(p_answers jsonb)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN public.adult_functional_p4_v1_score(p_answers);
END;
$$;
REVOKE ALL ON FUNCTION public.adult_functional_p4_v1_score_safe(jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.adult_functional_p4_v1_score_safe(jsonb) TO anon, authenticated;

-- Academic year archive helper for kids assessments
CREATE TABLE IF NOT EXISTS public.admission_years (
  year_label text PRIMARY KEY,
  status text NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'archived')),
  opened_at timestamptz NOT NULL DEFAULT now(),
  archived_at timestamptz
);
ALTER TABLE public.admission_years ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS admission_years_staff ON public.admission_years;
CREATE POLICY admission_years_staff ON public.admission_years
  FOR ALL TO authenticated
  USING (public.is_active_staff())
  WITH CHECK (public.is_active_staff());
GRANT SELECT, INSERT, UPDATE ON public.admission_years TO authenticated;

INSERT INTO public.admission_years(year_label, status)
VALUES ('2026/2027', 'open')
ON CONFLICT (year_label) DO NOTHING;
