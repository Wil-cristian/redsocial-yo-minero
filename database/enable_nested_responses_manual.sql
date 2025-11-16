-- Script para ejecutar manualmente en Supabase SQL Editor
-- Copiá y pegá este código en el SQL Editor de tu dashboard de Supabase

-- 1. Agregar columna parent_response_id si no existe
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'responses' 
                   AND column_name = 'parent_response_id') THEN
        ALTER TABLE responses 
        ADD COLUMN parent_response_id UUID REFERENCES responses(id) ON DELETE CASCADE;
        RAISE NOTICE 'Columna parent_response_id agregada exitosamente';
    ELSE
        RAISE NOTICE 'Columna parent_response_id ya existe';
    END IF;
END
$$;

-- 2. Crear índice para mejorar performance
CREATE INDEX IF NOT EXISTS idx_responses_parent_response_id 
ON responses(parent_response_id);

-- 3. Crear índice compuesto para consultas complejas  
CREATE INDEX IF NOT EXISTS idx_responses_post_parent 
ON responses(post_id, parent_response_id);

-- 4. Función RPC para crear respuestas anidadas
CREATE OR REPLACE FUNCTION create_nested_response(
  p_post_id UUID,
  p_parent_response_id UUID,
  p_content TEXT
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  response_id UUID;
  current_user_id UUID;
BEGIN
  -- Verificar autenticación
  current_user_id := auth.uid();
  IF current_user_id IS NULL THEN
    RAISE EXCEPTION 'Usuario no autenticado';
  END IF;

  -- Verificar que el post existe
  IF NOT EXISTS (SELECT 1 FROM posts WHERE id = p_post_id) THEN
    RAISE EXCEPTION 'Post no encontrado';
  END IF;

  -- Verificar que la respuesta padre existe y pertenece al mismo post
  IF NOT EXISTS (
    SELECT 1 FROM responses 
    WHERE id = p_parent_response_id 
    AND post_id = p_post_id
  ) THEN
    RAISE EXCEPTION 'Respuesta padre no encontrada o no pertenece al post';
  END IF;

  -- Insertar la respuesta anidada
  INSERT INTO responses (post_id, author_id, content, parent_response_id)
  VALUES (p_post_id, current_user_id, p_content, p_parent_response_id)
  RETURNING id INTO response_id;

  RETURN response_id;
END;
$$;

-- 5. Otorgar permisos
GRANT EXECUTE ON FUNCTION create_nested_response(UUID, UUID, TEXT) TO authenticated;

-- 6. Función mejorada para obtener respuestas con estructura anidada
CREATE OR REPLACE FUNCTION get_post_responses_with_nesting(post_id_param UUID)
RETURNS TABLE (
  id UUID,
  post_id UUID,
  author_id UUID,
  content TEXT,
  parent_response_id UUID,
  is_best_answer BOOLEAN,
  is_edited BOOLEAN,
  edit_count INTEGER,
  likes_count BIGINT,
  created_at TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE,
  author_name TEXT,
  author_username TEXT,
  author_profile_image TEXT,
  user_has_liked BOOLEAN
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    r.id,
    r.post_id,
    r.author_id,
    r.content,
    r.parent_response_id,
    r.is_best_answer,
    r.is_edited,
    r.edit_count,
    COALESCE(like_counts.likes_count, 0)::BIGINT as likes_count,
    r.created_at,
    r.updated_at,
    p.name as author_name,
    p.username as author_username,
    p.profile_image_url as author_profile_image,
    CASE 
      WHEN user_likes.response_id IS NOT NULL THEN true 
      ELSE false 
    END as user_has_liked
  FROM responses r
  LEFT JOIN profiles p ON r.author_id = p.user_id
  LEFT JOIN (
    SELECT response_id, COUNT(*) as likes_count
    FROM response_likes
    GROUP BY response_id
  ) like_counts ON r.id = like_counts.response_id
  LEFT JOIN response_likes user_likes ON r.id = user_likes.response_id 
    AND user_likes.user_id = auth.uid()
  WHERE r.post_id = post_id_param
  ORDER BY 
    CASE WHEN r.parent_response_id IS NULL THEN r.created_at END ASC,
    CASE WHEN r.parent_response_id IS NOT NULL THEN r.created_at END ASC;
END;
$$;

-- 7. Otorgar permisos para la nueva función
GRANT EXECUTE ON FUNCTION get_post_responses_with_nesting(UUID) TO authenticated;

-- 8. Comentarios para documentación
COMMENT ON COLUMN responses.parent_response_id IS 'ID de respuesta padre para respuestas anidadas. NULL para respuestas de primer nivel.';
COMMENT ON FUNCTION create_nested_response(UUID, UUID, TEXT) IS 'Crea una respuesta anidada (respuesta a otra respuesta)';
COMMENT ON FUNCTION get_post_responses_with_nesting(UUID) IS 'Obtiene todas las respuestas de un post incluyendo respuestas anidadas ordenadas apropiadamente';

-- ✅ Script completado
-- Ahora tu aplicación Flutter puede usar respuestas anidadas completamente