-- ══════════════════════════════════════════════════════════════
-- Script: Crear encuesta nueva de prueba
-- Propósito: Encuesta fresca con 7 días de duración
-- Ejecutar en: Dashboard de Supabase → SQL Editor
-- ══════════════════════════════════════════════════════════════

-- Encuesta: Mejor práctica de seguridad minera
INSERT INTO posts (
  id,
  author_id,
  title,
  content,
  post_type,
  tags,
  categories,
  poll_options,
  poll_ends_at,
  likes,
  comments,
  created_at,
  updated_at
) VALUES (
  gen_random_uuid(),
  (SELECT id FROM users WHERE email = 'empresa@test.com' LIMIT 1), -- Usuario de prueba
  '¿Cuál es la práctica de seguridad más efectiva en tu mina?',
  'Queremos conocer tu experiencia sobre qué medida de seguridad ha tenido mayor impacto en la reducción de accidentes. Vota por la que consideres más importante.',
  'poll',
  ARRAY['seguridad', 'minería', 'prevención'],
  ARRAY['seguridad', 'opinión'],
  ARRAY[
    'Capacitación constante del personal',
    'Equipos de protección de última generación',
    'Tecnología de monitoreo en tiempo real',
    'Protocolos de emergencia actualizados',
    'Inspecciones diarias obligatorias'
  ],
  NOW() + INTERVAL '7 days', -- ✅ Dura 7 días desde ahora
  0,
  0,
  NOW(),
  NOW()
);

-- Verificar que se creó correctamente
SELECT 
  id,
  title,
  poll_options,
  poll_ends_at,
  CASE 
    WHEN poll_ends_at > NOW() THEN '✅ ACTIVA'
    ELSE '❌ EXPIRADA'
  END as estado,
  EXTRACT(DAY FROM (poll_ends_at - NOW())) as dias_restantes
FROM posts 
WHERE post_type = 'poll'
ORDER BY created_at DESC
LIMIT 1;
