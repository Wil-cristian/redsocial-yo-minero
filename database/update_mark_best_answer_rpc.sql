-- Actualizar función RPC para permitir cambiar mejor respuesta
-- Permite tanto marcar como desmarcar mejor respuesta con lógica mejorada

-- Primero eliminar la función existente para evitar conflictos de tipo de retorno
DROP FUNCTION IF EXISTS mark_as_best_answer(UUID, UUID);

CREATE OR REPLACE FUNCTION mark_as_best_answer(
  target_response_id UUID,
  target_post_id UUID
) RETURNS VOID AS $$
DECLARE
  post_author UUID;
  current_is_best BOOLEAN;
BEGIN
  -- Verificar que el post existe y obtener el autor
  SELECT author_id INTO post_author 
  FROM posts 
  WHERE id = target_post_id;
  
  IF post_author IS NULL THEN
    RAISE EXCEPTION 'Post no encontrado';
  END IF;
  
  -- Verificar que el usuario actual es el autor del post
  IF post_author != auth.uid() THEN
    RAISE EXCEPTION 'Solo el autor del post puede marcar mejor respuesta';
  END IF;
  
  -- Verificar estado actual de la respuesta
  SELECT is_best_answer INTO current_is_best
  FROM post_responses
  WHERE id = target_response_id AND post_id = target_post_id;
  
  IF current_is_best IS NULL THEN
    RAISE EXCEPTION 'Respuesta no encontrada';
  END IF;
  
  -- LÓGICA MEJORADA: Cambio directo de mejor respuesta
  IF current_is_best THEN
    -- Si ya es mejor respuesta, la desmarcamos (permitir no tener mejor respuesta)
    UPDATE post_responses 
    SET is_best_answer = FALSE 
    WHERE id = target_response_id;
  ELSE
    -- Si no es mejor respuesta, primero desmarcamos TODAS las otras del post
    UPDATE post_responses 
    SET is_best_answer = FALSE 
    WHERE post_id = target_post_id;
    
    -- Luego marcamos esta como la nueva mejor respuesta
    UPDATE post_responses 
    SET is_best_answer = TRUE 
    WHERE id = target_response_id;
  END IF;
  
  -- Log para debugging
  RAISE NOTICE 'Mejor respuesta actualizada: respuesta_id=%, nuevo_estado=%', target_response_id, NOT current_is_best;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Dar permisos a usuarios autenticados
GRANT EXECUTE ON FUNCTION mark_as_best_answer(UUID, UUID) TO authenticated;