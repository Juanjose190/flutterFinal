-- Seed data for quick testing in Supabase
-- Run this after applying Supa.sql and enabling auth.

-- Teachers
INSERT INTO public.teachers (name) VALUES
  ('Alice Johnson'),
  ('Bob Smith'),
  ('Carol Lee')
ON CONFLICT DO NOTHING;

-- Subjects
INSERT INTO public.subjects (name) VALUES
  ('Mathematics'),
  ('Physics'),
  ('History')
ON CONFLICT DO NOTHING;

-- Classrooms
INSERT INTO public.classrooms (name, is_special) VALUES
  ('Room 101', false),
  ('Room 202', false),
  ('Lab A', true)
ON CONFLICT DO NOTHING;

-- Schedules (assumes IDs start at 1 in a new DB)
-- Adjust IDs if your tables already contain data
INSERT INTO public.schedules (teacher_id, subject_id, classroom_id, date, notes) VALUES
  (1, 1, 1, NOW() + interval '1 day', 'Algebra basics'),
  (2, 2, 3, NOW() + interval '2 days', 'Experiment intro'),
  (3, 3, 2, NOW() + interval '3 days', 'Ancient civilizations')
ON CONFLICT DO NOTHING;

-- Verify view
SELECT * FROM public.v_schedules_detailed LIMIT 10;
