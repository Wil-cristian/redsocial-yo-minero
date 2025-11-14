-- ══════════════════════════════════════════════════════════════
-- Tabla: saved_posts - Posts guardados por usuarios
-- Propósito: Almacenar posts (ofertas, productos, servicios, noticias, etc.) que los usuarios marcan como favoritos
-- Ejecutar en: Dashboard de Supabase → SQL Editor
-- ══════════════════════════════════════════════════════════════

-- Crear tabla de posts guardados
CREATE TABLE IF NOT EXISTS saved_posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  saved_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  notes TEXT, -- Notas personales del usuario sobre el post
  
  -- Un usuario no puede guardar el mismo post dos veces
  UNIQUE(user_id, post_id)
);

-- Índices para mejorar performance
CREATE INDEX IF NOT EXISTS idx_saved_posts_user_id ON saved_posts(user_id);
CREATE INDEX IF NOT EXISTS idx_saved_posts_post_id ON saved_posts(post_id);
CREATE INDEX IF NOT EXISTS idx_saved_posts_saved_at ON saved_posts(saved_at DESC);

-- Habilitar RLS (Row Level Security)
ALTER TABLE saved_posts ENABLE ROW LEVEL SECURITY;

-- Eliminar políticas existentes si existen
DROP POLICY IF EXISTS "Usuarios ven sus posts guardados" ON saved_posts;
DROP POLICY IF EXISTS "Usuarios pueden guardar posts" ON saved_posts;
DROP POLICY IF EXISTS "Usuarios pueden eliminar posts guardados" ON saved_posts;
DROP POLICY IF EXISTS "Usuarios pueden actualizar notas" ON saved_posts;

-- Política: Los usuarios solo pueden ver sus propios posts guardados
CREATE POLICY "Usuarios ven sus posts guardados"
  ON saved_posts
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Política: Los usuarios pueden guardar posts
CREATE POLICY "Usuarios pueden guardar posts"
  ON saved_posts
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Política: Los usuarios pueden eliminar sus posts guardados
CREATE POLICY "Usuarios pueden eliminar posts guardados"
  ON saved_posts
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Política: Los usuarios pueden actualizar notas de sus posts
CREATE POLICY "Usuarios pueden actualizar notas"
  ON saved_posts
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ══════════════════════════════════════════════════════════════
-- FUNCIÓN: Obtener posts guardados con info completa
-- ══════════════════════════════════════════════════════════════

-- Eliminar función existente si existe
DROP FUNCTION IF EXISTS get_saved_posts(UUID, TEXT);

CREATE OR REPLACE FUNCTION get_saved_posts(user_id_param UUID, post_type_filter TEXT DEFAULT NULL)
RETURNS TABLE(
  post_id UUID,
  post_type TEXT,
  title TEXT,
  content TEXT,
  metadata JSONB,
  author_id UUID,
  author_name TEXT,
  author_username TEXT,
  likes_count INT,
  saved_at TIMESTAMP WITH TIME ZONE,
  notes TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id as post_id,
    p.type as post_type,
    p.title,
    p.content,
    p.metadata,
    p.author_id,
    u.name as author_name,
    u.username as author_username,
    p.likes_count,
    sp.saved_at,
    sp.notes
  FROM saved_posts sp
  JOIN posts p ON p.id = sp.post_id
  JOIN users u ON u.id = p.author_id
  WHERE sp.user_id = user_id_param
    AND (post_type_filter IS NULL OR p.type = post_type_filter)
  ORDER BY sp.saved_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ══════════════════════════════════════════════════════════════
-- FUNCIÓN: Contar posts guardados por tipo
-- ══════════════════════════════════════════════════════════════

-- Eliminar función existente si existe
DROP FUNCTION IF EXISTS count_saved_posts(UUID);

CREATE OR REPLACE FUNCTION count_saved_posts(user_id_param UUID)
RETURNS TABLE(
  post_type TEXT,
  count BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.type as post_type,
    COUNT(*) as count
  FROM saved_posts sp
  JOIN posts p ON p.id = sp.post_id
  WHERE sp.user_id = user_id_param
  GROUP BY p.type
  ORDER BY count DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ══════════════════════════════════════════════════════════════
-- MIGRACIÓN: Copiar datos de saved_offers a saved_posts (si existe)
-- ══════════════════════════════════════════════════════════════

-- Solo ejecutar si tienes datos en saved_offers que quieras migrar
INSERT INTO saved_posts (user_id, post_id, saved_at, notes)
SELECT user_id, post_id, saved_at, notes
FROM saved_offers
ON CONFLICT (user_id, post_id) DO NOTHING;

-- ══════════════════════════════════════════════════════════════
-- VERIFICACIÓN
-- ══════════════════════════════════════════════════════════════

-- Ver estructura de la tabla
SELECT 
  column_name, 
  data_type, 
  is_nullable
FROM information_schema.columns
WHERE table_name = 'saved_posts'
ORDER BY ordinal_position;

-- Contar posts guardados totales
SELECT COUNT(*) as total_guardados FROM saved_posts;

-- Contar posts guardados por tipo
SELECT p.type, COUNT(*) as count
FROM saved_posts sp
JOIN posts p ON p.id = sp.post_id
GROUP BY p.type
ORDER BY count DESC;
