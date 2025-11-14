-- Resetear votos falsos de la encuesta sobre tecnología minera
-- Solo debe tener votos REALES de usuarios REALES

-- 1. Encontrar el ID de la encuesta
-- SELECT id, title, poll_votes FROM posts WHERE type = 'poll' AND title LIKE '%tecnología%';

-- 2. Resetear los votos a los datos REALES (solo los 2 votos actuales)
-- Opción A: Si quieres mantener SOLO los votos de usuarios reales que votaron
UPDATE posts 
SET poll_votes = jsonb_build_object(
  'Automatización y robótica', 1,
  'Drones y sensores', 1
)
WHERE type = 'poll' 
  AND title = '¿Cuál es la tecnología más importante para mejorar la productividad minera?';

-- 3. Eliminar votos duplicados de la tabla poll_votes si existe
-- DELETE FROM poll_votes 
-- WHERE poll_id IN (
--   SELECT id FROM posts 
--   WHERE type = 'poll' 
--   AND title = '¿Cuál es la tecnología más importante para mejorar la productividad minera?'
-- );

-- 4. Verificar que quedó bien
SELECT 
  id,
  title,
  poll_votes,
  (SELECT SUM((value->>'value')::int) FROM jsonb_each(poll_votes)) as total_votes
FROM posts 
WHERE type = 'poll' 
  AND title LIKE '%tecnología%';

-- NOTA: Si quieres BORRAR TODOS los votos y empezar de cero:
-- UPDATE posts 
-- SET poll_votes = '{}'::jsonb
-- WHERE type = 'poll' 
--   AND title = '¿Cuál es la tecnología más importante para mejorar la productividad minera?';
