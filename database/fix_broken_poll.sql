-- Script para arreglar la encuesta rota que aparece sin opciones
-- ID: a0911683-a502-4640-816d-890b85f233d7

UPDATE posts 
SET 
  poll_options = ARRAY['Opción A', 'Opción B', 'Opción C'], -- Opciones genéricas para recuperar la encuesta
  poll_ends_at = NOW() + INTERVAL '7 days',
  post_type = 'poll'
WHERE id = 'a0911683-a502-4640-816d-890b85f233d7';

-- Verificar que se arregló
SELECT id, title, poll_options FROM posts WHERE id = 'a0911683-a502-4640-816d-890b85f233d7';