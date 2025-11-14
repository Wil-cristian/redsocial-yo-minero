-- ══════════════════════════════════════════════════════════════
-- Script: Insertar encuestas de prueba para YoMinero
-- Propósito: Polls interactivas del sector minero
-- Ejecutar en: Dashboard de Supabase → SQL Editor
-- ══════════════════════════════════════════════════════════════

-- Encuesta 1: Tecnología más importante
INSERT INTO posts (
  id,
  author_id,
  title,
  content,
  type,
  tags,
  categories,
  poll_options,
  poll_votes,
  poll_allow_multiple,
  poll_ends_at,
  likes,
  comments,
  created_at
) VALUES (
  gen_random_uuid(),
  (SELECT id FROM users LIMIT 1),
  '¿Cuál es la tecnología más importante para mejorar la productividad minera?',
  'Queremos conocer tu opinión sobre qué tecnología consideras más crucial para el futuro de la minería. Tu voto nos ayudará a entender las prioridades del sector.',
  'poll',
  ARRAY['tecnología', 'productividad', 'innovación'],
  ARRAY['tecnología', 'opinión'],
  ARRAY['Automatización y robótica', 'Análisis de datos e IA', 'Drones y sensores', 'Vehículos autónomos', 'Energías renovables'],
  '{"Automatización y robótica": 45, "Análisis de datos e IA": 67, "Drones y sensores": 23, "Vehículos autónomos": 34, "Energías renovables": 51}'::jsonb,
  false,
  NOW() + INTERVAL '7 days',
  18,
  12,
  NOW() - INTERVAL '3 hours'
);

-- Encuesta 2: Desafío principal
INSERT INTO posts (
  id,
  author_id,
  title,
  content,
  type,
  tags,
  categories,
  poll_options,
  poll_votes,
  poll_allow_multiple,
  poll_ends_at,
  likes,
  comments,
  created_at
) VALUES (
  gen_random_uuid(),
  (SELECT id FROM users LIMIT 1),
  '¿Cuál es el mayor desafío que enfrentas en tu operación minera?',
  'Identifica el principal obstáculo que afecta tu operación diaria. Los resultados nos permitirán enfocar recursos y soluciones.',
  'poll',
  ARRAY['desafíos', 'operaciones', 'mejora continua'],
  ARRAY['operaciones', 'consulta'],
  ARRAY['Cumplimiento normativo', 'Costos operativos', 'Escasez de personal calificado', 'Mantenimiento de equipos', 'Gestión ambiental'],
  '{"Cumplimiento normativo": 89, "Costos operativos": 134, "Escasez de personal calificado": 78, "Mantenimiento de equipos": 56, "Gestión ambiental": 43}'::jsonb,
  false,
  NOW() + INTERVAL '5 days',
  32,
  24,
  NOW() - INTERVAL '1 day'
);

-- Encuesta 3: Capacitación preferida
INSERT INTO posts (
  id,
  author_id,
  title,
  content,
  type,
  tags,
  categories,
  poll_options,
  poll_votes,
  poll_allow_multiple,
  poll_ends_at,
  likes,
  comments,
  created_at
) VALUES (
  gen_random_uuid(),
  (SELECT id FROM users LIMIT 1),
  '¿En qué áreas te gustaría recibir capacitación este año?',
  'Ayúdanos a diseñar el programa de formación 2025. Puedes votar por el área que más te interese.',
  'poll',
  ARRAY['capacitación', 'formación', 'desarrollo profesional'],
  ARRAY['educación', 'consulta'],
  ARRAY['Seguridad y prevención de riesgos', 'Manejo de maquinaria pesada', 'Geología y exploración', 'Gestión de proyectos mineros', 'Software especializado'],
  '{"Seguridad y prevención de riesgos": 112, "Manejo de maquinaria pesada": 67, "Geología y exploración": 45, "Gestión de proyectos mineros": 89, "Software especializado": 92}'::jsonb,
  false,
  NOW() + INTERVAL '10 days',
  45,
  18,
  NOW() - INTERVAL '6 hours'
);

-- Encuesta 4: Horario de trabajo preferido
INSERT INTO posts (
  id,
  author_id,
  title,
  content,
  type,
  tags,
  categories,
  poll_options,
  poll_votes,
  poll_allow_multiple,
  poll_ends_at,
  likes,
  comments,
  created_at
) VALUES (
  gen_random_uuid(),
  (SELECT id FROM users LIMIT 1),
  '¿Qué sistema de turnos prefieres para operaciones mineras?',
  'Estamos evaluando optimizar los turnos de trabajo. Tu opinión es valiosa para encontrar el equilibrio entre productividad y calidad de vida.',
  'poll',
  ARRAY['turnos', 'trabajo', 'bienestar laboral'],
  ARRAY['recursos humanos', 'consulta'],
  ARRAY['7x7 (7 días on/off)', '14x14 (14 días on/off)', '4x3 (4 días on, 3 off)', '5x2 (5 días on, 2 off)', 'Turnos rotativos 12 horas'],
  '{"7x7 (7 días on/off)": 156, "14x14 (14 días on/off)": 89, "4x3 (4 días on, 3 off)": 123, "5x2 (5 días on, 2 off)": 45, "Turnos rotativos 12 horas": 67}'::jsonb,
  false,
  NOW() + INTERVAL '3 days',
  67,
  34,
  NOW() - INTERVAL '12 hours'
);

-- ══════════════════════════════════════════════════════════════
-- VERIFICACIÓN
-- ══════════════════════════════════════════════════════════════

SELECT 
  COUNT(*) as total_encuestas,
  ROUND(AVG(likes), 0) as promedio_likes,
  ROUND(AVG(comments), 0) as promedio_comentarios
FROM posts 
WHERE type = 'poll';

-- Listar encuestas con información
SELECT 
  title,
  array_length(poll_options, 1) as num_opciones,
  poll_ends_at,
  likes,
  comments,
  created_at
FROM posts 
WHERE type = 'poll'
ORDER BY created_at DESC;
