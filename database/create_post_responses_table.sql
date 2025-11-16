-- ============================================
-- TABLA: post_responses
-- Respuestas a posts tipo pregunta (request)
-- ============================================

CREATE TABLE IF NOT EXISTS post_responses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  author_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  -- Contenido de la respuesta
  content TEXT NOT NULL,
  
  -- Metadata adicional
  is_best_answer BOOLEAN DEFAULT false,
  is_edited BOOLEAN DEFAULT false,
  edit_count INTEGER DEFAULT 0,
  
  -- Interacciones
  likes_count INTEGER DEFAULT 0,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para búsquedas rápidas
CREATE INDEX idx_responses_post_id ON post_responses(post_id);
CREATE INDEX idx_responses_author_id ON post_responses(author_id);
CREATE INDEX idx_responses_created_at ON post_responses(created_at DESC);

-- Índice único parcial: Solo un post puede tener una "mejor respuesta"
CREATE UNIQUE INDEX idx_unique_best_answer ON post_responses(post_id) WHERE is_best_answer = true;

-- ============================================
-- TABLA: response_likes
-- Likes a respuestas
-- ============================================

CREATE TABLE IF NOT EXISTS response_likes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  response_id UUID NOT NULL REFERENCES post_responses(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Un usuario solo puede dar like una vez a cada respuesta
  CONSTRAINT unique_response_like UNIQUE (response_id, user_id)
);

-- Índices
CREATE INDEX idx_response_likes_response_id ON response_likes(response_id);
CREATE INDEX idx_response_likes_user_id ON response_likes(user_id);

-- ============================================
-- FUNCTION: Actualizar contador de likes en respuestas
-- ============================================

CREATE OR REPLACE FUNCTION update_response_likes_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE post_responses 
    SET likes_count = likes_count + 1
    WHERE id = NEW.response_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE post_responses 
    SET likes_count = GREATEST(likes_count - 1, 0)
    WHERE id = OLD.response_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar contador de likes
DROP TRIGGER IF EXISTS trigger_update_response_likes_count ON response_likes;
CREATE TRIGGER trigger_update_response_likes_count
AFTER INSERT OR DELETE ON response_likes
FOR EACH ROW
EXECUTE FUNCTION update_response_likes_count();

-- ============================================
-- FUNCTION: Actualizar contador de respuestas en posts
-- ============================================

CREATE OR REPLACE FUNCTION update_post_comments_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    -- Incrementar contador de comentarios en el post
    UPDATE posts 
    SET metadata = jsonb_set(
      COALESCE(metadata, '{}'::jsonb),
      '{responses_count}',
      to_jsonb(COALESCE((metadata->>'responses_count')::integer, 0) + 1)
    )
    WHERE id = NEW.post_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    -- Decrementar contador de comentarios en el post
    UPDATE posts 
    SET metadata = jsonb_set(
      COALESCE(metadata, '{}'::jsonb),
      '{responses_count}',
      to_jsonb(GREATEST(COALESCE((metadata->>'responses_count')::integer, 0) - 1, 0))
    )
    WHERE id = OLD.post_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar contador de respuestas en posts
DROP TRIGGER IF EXISTS trigger_update_post_comments_count ON post_responses;
CREATE TRIGGER trigger_update_post_comments_count
AFTER INSERT OR DELETE ON post_responses
FOR EACH ROW
EXECUTE FUNCTION update_post_comments_count();

-- ============================================
-- RPC FUNCTION: Obtener respuestas de un post con info del autor
-- ============================================

CREATE OR REPLACE FUNCTION get_post_responses(target_post_id UUID)
RETURNS TABLE (
  id UUID,
  post_id UUID,
  author_id UUID,
  content TEXT,
  is_best_answer BOOLEAN,
  is_edited BOOLEAN,
  edit_count INTEGER,
  likes_count INTEGER,
  created_at TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE,
  author_name TEXT,
  author_username TEXT,
  author_profile_image TEXT,
  user_has_liked BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    r.id,
    r.post_id,
    r.author_id,
    r.content,
    r.is_best_answer,
    r.is_edited,
    r.edit_count,
    r.likes_count,
    r.created_at,
    r.updated_at,
    u.name AS author_name,
    u.username AS author_username,
    u.profile_image_url AS author_profile_image,
    EXISTS(
      SELECT 1 FROM response_likes rl 
      WHERE rl.response_id = r.id 
      AND rl.user_id = auth.uid()
    ) AS user_has_liked
  FROM post_responses r
  LEFT JOIN users u ON r.author_id = u.id
  WHERE r.post_id = target_post_id
  ORDER BY 
    r.is_best_answer DESC,  -- Mejor respuesta primero
    r.likes_count DESC,      -- Luego por likes
    r.created_at ASC;        -- Luego por antigüedad
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- RPC FUNCTION: Marcar respuesta como mejor respuesta
-- ============================================

CREATE OR REPLACE FUNCTION mark_as_best_answer(
  target_response_id UUID,
  target_post_id UUID
)
RETURNS BOOLEAN AS $$
DECLARE
  post_author_id UUID;
  current_user_id UUID;
BEGIN
  -- Obtener ID del usuario actual
  current_user_id := auth.uid();
  
  -- Verificar que el usuario actual es el autor del post
  SELECT author_id INTO post_author_id
  FROM posts
  WHERE id = target_post_id;
  
  IF post_author_id != current_user_id THEN
    RAISE EXCEPTION 'Solo el autor del post puede marcar la mejor respuesta';
  END IF;
  
  -- Quitar "mejor respuesta" de todas las respuestas del post
  UPDATE post_responses
  SET is_best_answer = false
  WHERE post_id = target_post_id;
  
  -- Marcar la respuesta seleccionada como mejor respuesta
  UPDATE post_responses
  SET is_best_answer = true
  WHERE id = target_response_id AND post_id = target_post_id;
  
  RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- POLÍTICAS RLS (Row Level Security)
-- ============================================

-- Habilitar RLS
ALTER TABLE post_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE response_likes ENABLE ROW LEVEL SECURITY;

-- Políticas para post_responses
CREATE POLICY "Respuestas visibles para todos"
  ON post_responses FOR SELECT
  USING (true);

CREATE POLICY "Usuarios autenticados pueden crear respuestas"
  ON post_responses FOR INSERT
  WITH CHECK (auth.uid() = author_id);

CREATE POLICY "Autores pueden editar sus propias respuestas"
  ON post_responses FOR UPDATE
  USING (auth.uid() = author_id);

CREATE POLICY "Autores pueden eliminar sus propias respuestas"
  ON post_responses FOR DELETE
  USING (auth.uid() = author_id);

-- Políticas para response_likes
CREATE POLICY "Likes visibles para todos"
  ON response_likes FOR SELECT
  USING (true);

CREATE POLICY "Usuarios autenticados pueden dar like"
  ON response_likes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuarios pueden quitar su propio like"
  ON response_likes FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================
-- DATOS DE PRUEBA (Opcional)
-- ============================================

-- Insertar respuestas de prueba para las preguntas existentes
DO $$
DECLARE
  first_post_id UUID;
  test_user_id UUID;
BEGIN
  -- Obtener el primer post de tipo 'request'
  SELECT id INTO first_post_id FROM posts WHERE type = 'request' LIMIT 1;
  
  -- Obtener el primer usuario
  SELECT id INTO test_user_id FROM users LIMIT 1;
  
  -- Solo insertar si existen posts y usuarios
  IF first_post_id IS NOT NULL AND test_user_id IS NOT NULL THEN
    -- Respuesta 1 (mejor respuesta)
    INSERT INTO post_responses (post_id, author_id, content, is_best_answer, likes_count)
    VALUES (
      first_post_id,
      test_user_id,
      'Te recomiendo empezar con un martillo neumático de 25kg y una perforadora de roca básica. Para minería a pequeña escala, la marca Atlas Copco tiene equipos confiables. Con $5,000 podrías adquirir equipo usado en buen estado. No olvides el equipo de seguridad: cascos, botas con punta de acero, y detectores de gas.',
      true,
      15
    );
    
    -- Respuesta 2
    INSERT INTO post_responses (post_id, author_id, content, likes_count)
    VALUES (
      first_post_id,
      test_user_id,
      'Yo arranqué con equipos usados y me fue bien. Busca en ferias mineras regionales, a veces hay gangas. También considera rentar equipo al principio para no comprometer todo tu capital.',
      8
    );
    
    -- Respuesta 3
    INSERT INTO post_responses (post_id, author_id, content, likes_count)
    VALUES (
      first_post_id,
      test_user_id,
      'Importante: antes de comprar equipos, asegúrate de tener los permisos en orden. A veces el equipo termina parado por temas legales.',
      3
    );
    
    RAISE NOTICE 'Respuestas de prueba insertadas correctamente';
  ELSE
    RAISE NOTICE 'No se encontraron posts o usuarios para insertar respuestas de prueba';
  END IF;
END $$;

-- ============================================
-- VERIFICACIÓN
-- ============================================

-- Ver respuestas insertadas
SELECT 
  r.id,
  r.content,
  r.is_best_answer,
  r.likes_count,
  u.name as author_name
FROM post_responses r
LEFT JOIN users u ON r.author_id = u.id
ORDER BY r.created_at DESC
LIMIT 5;
