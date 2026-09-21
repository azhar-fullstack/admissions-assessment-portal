-- Legacy one-liner kept for reference. Prefer MIGRATION_FROM_EXISTING.sql.
ALTER TABLE public.assessments DROP CONSTRAINT IF EXISTS assessments_class_level_check;
ALTER TABLE public.assessments ADD CONSTRAINT assessments_class_level_check CHECK (class_level BETWEEN 1 AND 6);
