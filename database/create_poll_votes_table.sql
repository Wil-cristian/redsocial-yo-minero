-- ══════════════════════════════════════════════════════════════
-- Tabla: poll_votes - Registro de votos en encuestas
-- Propósito: Almacenar votos reales de usuarios en polls
-- Ejecutar en: Dashboard de Supabase → SQL Editor
-- ══════════════════════════════════════════════════════════════

-- Crear tabla de votos
CREATE TABLE IF NOT EXISTS poll_votes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  poll_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  selected_option TEXT NOT NULL,
  voted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Un usuario solo puede votar una vez por encuesta
  UNIQUE(poll_id, user_id)
);

-- Índices para mejorar performance
CREATE INDEX IF NOT EXISTS idx_poll_votes_poll_id ON poll_votes(poll_id);
CREATE INDEX IF NOT EXISTS idx_poll_votes_user_id ON poll_votes(user_id);

-- Habilitar RLS (Row Level Security)
ALTER TABLE poll_votes ENABLE ROW LEVEL SECURITY;

-- Política: Cualquiera puede ver los votos (para contar)
CREATE POLICY "Cualquiera puede ver votos"
  ON poll_votes
  FOR SELECT
  TO authenticated
  USING (true);

-- Política: Los usuarios pueden insertar su propio voto
CREATE POLICY "Usuarios pueden votar"
  ON poll_votes
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Política: Los usuarios pueden actualizar solo su propio voto
CREATE POLICY "Usuarios pueden cambiar su voto"
  ON poll_votes
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Política: Los usuarios pueden eliminar solo su propio voto
CREATE POLICY "Usuarios pueden eliminar su voto"
  ON poll_votes
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- ══════════════════════════════════════════════════════════════
-- FUNCIÓN: Contar votos de una encuesta
-- ══════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION get_poll_results(poll_id_param UUID)
RETURNS TABLE(option TEXT, votes BIGINT) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    selected_option as option,
    COUNT(*) as votes
  FROM poll_votes
  WHERE poll_id = poll_id_param
  GROUP BY selected_option
  ORDER BY votes DESC;
END;
$$ LANGUAGE plpgsql;

-- ══════════════════════════════════════════════════════════════
-- VERIFICACIÓN
-- ══════════════════════════════════════════════════════════════

-- Ver columnas de la tabla
SELECT 
  column_name, 
  data_type, 
  is_nullable
FROM information_schema.columns
WHERE table_name = 'poll_votes'
ORDER BY ordinal_position;

-- Contar votos actuales (debería estar vacío)
SELECT COUNT(*) as total_votos FROM poll_votes;
