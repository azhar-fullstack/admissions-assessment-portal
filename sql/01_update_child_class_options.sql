-- Expand child admission class options: Primary 5, Primary 6, JHS 1–3
UPDATE public.meg_adm_v1_forms
SET definition = jsonb_set(
  definition,
  '{questions}',
  (
    SELECT jsonb_agg(
      CASE
        WHEN q->>'key' = 'class_requested' THEN
          jsonb_set(
            q,
            '{options}',
            '["Creche","Nursery","Kindergarten 1","Kindergarten 2","Primary 1","Primary 2","Primary 3","Primary 4","Primary 5","Primary 6","JHS 1","JHS 2","JHS 3","Other / unsure"]'::jsonb
          )
        ELSE q
      END
    )
    FROM jsonb_array_elements(definition->'questions') AS q
  )
)
WHERE form_code = 'child_admission_v1';

UPDATE public.meg_adm_v1_forms
SET definition = jsonb_set(definition, '{version}', '2'::jsonb)
WHERE form_code = 'child_admission_v1';
