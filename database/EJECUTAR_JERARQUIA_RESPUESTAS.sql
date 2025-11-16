-- 🚀 EJECUTAR ESTE SQL EN SUPABASE PARA HABILITAR JERARQUÍA
-- Copia y pega este contenido completo en Supabase SQL Editor

-- 1. Agregar columna parent_response_id si no existe
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'post_responses' 
                   AND column_name = 'parent_response_id') THEN
        ALTER TABLE post_responses 
        ADD COLUMN parent_response_id UUID REFERENCES post_responses(id) ON DELETE CASCADE;
        RAISE NOTICE 'Columna parent_response_id agregada exitosamente';
    ELSE
        RAISE NOTICE 'Columna parent_response_id ya existe';
    END IF;
END
$$;

-- 2. Crear índice para mejorar performance
CREATE INDEX IF NOT EXISTS idx_post_responses_parent_id ON post_responses(parent_response_id);
CREATE INDEX IF NOT EXISTS idx_post_responses_post_parent ON post_responses(post_id, parent_response_id);

-- 3. Eliminar funciones existentes si existen (para evitar conflictos de parámetros)
DROP FUNCTION IF EXISTS create_nested_response(UUID, UUID, TEXT);
DROP FUNCTION IF EXISTS get_post_responses_with_nesting(UUID);

-- 4. Función para crear respuesta anidada
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
  new_response_id UUID;
BEGIN
  -- Validar que el parent_response_id existe y pertenece al mismo post
  IF NOT EXISTS (
    SELECT 1 FROM post_responses 
    WHERE id = p_parent_response_id AND post_id = p_post_id
  ) THEN
    RAISE EXCEPTION 'Parent response does not exist or belongs to different post';
  END IF;
  
  -- Crear la respuesta anidada
  INSERT INTO post_responses (post_id, author_id, content, parent_response_id)
  VALUES (p_post_id, auth.uid(), p_content, p_parent_response_id)
  RETURNING id INTO new_response_id;
  
  RETURN new_response_id;
END;
$$;

-- 5. Función para obtener respuestas con jerarquía
CREATE OR REPLACE FUNCTION get_post_responses_with_nesting(p_post_id UUID)
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
  FROM post_responses r
  LEFT JOIN profiles p ON r.author_id = p.user_id
  LEFT JOIN (
    SELECT response_id, COUNT(*) as likes_count
    FROM response_likes
    GROUP BY response_id
  ) like_counts ON r.id = like_counts.response_id
  LEFT JOIN response_likes user_likes ON r.id = user_likes.response_id 
    AND user_likes.user_id = auth.uid()
  WHERE r.post_id = p_post_id
  ORDER BY 
    CASE WHEN r.parent_response_id IS NULL THEN r.created_at END DESC,
    CASE WHEN r.parent_response_id IS NOT NULL THEN r.created_at END ASC;
END;
$$;

-- 6. Otorgar permisos
GRANT EXECUTE ON FUNCTION create_nested_response(UUID, UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION get_post_responses_with_nesting(UUID) TO authenticated;

-- 7. Comentarios
COMMENT ON FUNCTION get_post_responses_with_nesting(UUID) IS 'Obtiene respuestas de un post con soporte para jerarquía anidada';

-- ✅ LISTO! Ahora la jerarquía visual funcionará correctamente