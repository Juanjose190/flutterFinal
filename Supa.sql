-- Supabase schema for schedules app
-- Creates teachers, subjects, classrooms, schedules tables and relationships
-- Includes indexes and views to query by teacher, subject, classroom, and date

-- NOTE: Import this file into Supabase; do not run from the app.

-- Teachers
CREATE TABLE IF NOT EXISTS public.teachers (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name TEXT NOT NULL
);

-- Subjects
CREATE TABLE IF NOT EXISTS public.subjects (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name TEXT NOT NULL
);

-- Classrooms
CREATE TABLE IF NOT EXISTS public.classrooms (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name TEXT NOT NULL,
  is_special BOOLEAN DEFAULT FALSE
);

-- Schedules
CREATE TABLE IF NOT EXISTS public.schedules (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  teacher_id BIGINT NOT NULL REFERENCES public.teachers(id) ON DELETE CASCADE,
  subject_id BIGINT NOT NULL REFERENCES public.subjects(id) ON DELETE CASCADE,
  classroom_id BIGINT NOT NULL REFERENCES public.classrooms(id) ON DELETE CASCADE,
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  notes TEXT
);

-- Indexes for fast filtering
CREATE INDEX IF NOT EXISTS idx_schedules_teacher ON public.schedules(teacher_id);
CREATE INDEX IF NOT EXISTS idx_schedules_subject ON public.schedules(subject_id);
CREATE INDEX IF NOT EXISTS idx_schedules_classroom ON public.schedules(classroom_id);
CREATE INDEX IF NOT EXISTS idx_schedules_date ON public.schedules(date);

-- Views to simplify joins and AI-friendly dataset
CREATE OR REPLACE VIEW public.v_schedules_detailed AS
SELECT s.id,
       s.date,
       s.notes,
       t.id AS teacher_id,
       t.name AS teacher_name,
       subj.id AS subject_id,
       subj.name AS subject_name,
       c.id AS classroom_id,
       c.name AS classroom_name,
       c.is_special
FROM public.schedules s
JOIN public.teachers t ON t.id = s.teacher_id
JOIN public.subjects subj ON subj.id = s.subject_id
JOIN public.classrooms c ON c.id = s.classroom_id;

-- Example policies (owner will configure auth separately)
-- Uncomment and adapt as needed
-- Basic RLS scaffold: allow authenticated users full CRUD during development
ALTER TABLE public.teachers   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subjects   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.classrooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.schedules  ENABLE ROW LEVEL SECURITY;

-- SELECT policies
CREATE POLICY teachers_select_authenticated   ON public.teachers   FOR SELECT TO authenticated USING (true);
CREATE POLICY subjects_select_authenticated   ON public.subjects   FOR SELECT TO authenticated USING (true);
CREATE POLICY classrooms_select_authenticated ON public.classrooms FOR SELECT TO authenticated USING (true);
CREATE POLICY schedules_select_authenticated  ON public.schedules  FOR SELECT TO authenticated USING (true);

-- INSERT policies
CREATE POLICY teachers_insert_authenticated   ON public.teachers   FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY subjects_insert_authenticated   ON public.subjects   FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY classrooms_insert_authenticated ON public.classrooms FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY schedules_insert_authenticated  ON public.schedules  FOR INSERT TO authenticated WITH CHECK (true);

-- UPDATE policies
CREATE POLICY teachers_update_authenticated   ON public.teachers   FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY subjects_update_authenticated   ON public.subjects   FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY classrooms_update_authenticated ON public.classrooms FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY schedules_update_authenticated  ON public.schedules  FOR UPDATE TO authenticated USING (true) WITH CHECK (true);

-- DELETE policies
CREATE POLICY teachers_delete_authenticated   ON public.teachers   FOR DELETE TO authenticated USING (true);
CREATE POLICY subjects_delete_authenticated   ON public.subjects   FOR DELETE TO authenticated USING (true);
CREATE POLICY classrooms_delete_authenticated ON public.classrooms FOR DELETE TO authenticated USING (true);
CREATE POLICY schedules_delete_authenticated  ON public.schedules  FOR DELETE TO authenticated USING (true);

-- Stored procedures or functions can be added by owner if needed for AI prep

-- New relationships: assign subject to teacher, and classroom to subject
-- Run these in your Supabase SQL editor if your tables already exist.
ALTER TABLE public.teachers
  ADD COLUMN IF NOT EXISTS subject_id BIGINT REFERENCES public.subjects(id) ON DELETE SET NULL;

ALTER TABLE public.subjects
  ADD COLUMN IF NOT EXISTS classroom_id BIGINT REFERENCES public.classrooms(id) ON DELETE SET NULL;

-- Helpful indexes for new foreign keys
CREATE INDEX IF NOT EXISTS idx_teachers_subject ON public.teachers(subject_id);
CREATE INDEX IF NOT EXISTS idx_subjects_classroom ON public.subjects(classroom_id);

-- Availability per teacher and day using timezone-aware ranges
-- Requires btree_gist for exclusion constraints on ranges
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- Each row represents one available period for a teacher on a specific weekday
-- day_of_week: 0=Monday .. 6=Sunday (ISO-8601 style)
-- period: tstzrange stored in UTC; prevents overlapping periods via exclusion
CREATE TABLE IF NOT EXISTS public.teacher_availability (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  teacher_id BIGINT NOT NULL REFERENCES public.teachers(id) ON DELETE CASCADE,
  day_of_week SMALLINT NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
  period TSTZRANGE NOT NULL,
  -- Optional timezone name used when capturing input/display (e.g., "America/Bogota")
  tz TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Prevent overlapping availability periods for the same teacher/day
CREATE INDEX IF NOT EXISTS idx_teacher_availability_teacher_day ON public.teacher_availability(teacher_id, day_of_week);
ALTER TABLE public.teacher_availability ENABLE ROW LEVEL SECURITY;
CREATE POLICY teacher_availability_select_authenticated ON public.teacher_availability FOR SELECT TO authenticated USING (true);
CREATE POLICY teacher_availability_insert_authenticated ON public.teacher_availability FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY teacher_availability_update_authenticated ON public.teacher_availability FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY teacher_availability_delete_authenticated ON public.teacher_availability FOR DELETE TO authenticated USING (true);

-- Exclusion constraint to disallow overlapping ranges per teacher/day
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'teacher_availability_no_overlap'
  ) THEN
    ALTER TABLE public.teacher_availability
      ADD CONSTRAINT teacher_availability_no_overlap
      EXCLUDE USING gist (
        teacher_id WITH =,
        day_of_week WITH =,
        period WITH &&
      );
  END IF;
END $$;

-- Flat view to simplify client consumption (exposes start and end timestamps)
CREATE OR REPLACE VIEW public.v_teacher_availability_flat AS
SELECT id,
       teacher_id,
       day_of_week,
       lower(period) AS start_utc,
       upper(period) AS end_utc,
       tz,
       created_at,
       updated_at
FROM public.teacher_availability;

-- Optional helper: seed default availability for existing teachers (Mon and Fri 07:00-14:00 UTC)
-- Commented out by default; uncomment to apply once.
-- INSERT INTO public.teacher_availability(teacher_id, day_of_week, period, tz)
-- SELECT t.id, d.dow,
--        tstzrange(
--          make_timestamptz(EXTRACT(YEAR FROM NOW())::int, 1, 1, 7, 0, 0, 'UTC'),
--          make_timestamptz(EXTRACT(YEAR FROM NOW())::int, 1, 1, 14, 0, 0, 'UTC'),
--          '[)'
--        ),
--        'UTC'
-- FROM public.teachers t CROSS JOIN (VALUES (0),(4)) AS d(dow)
-- ON CONFLICT DO NOTHING;
