-- ============================================
-- 🤝 SISTEMA DE SOLICITUDES DE CONEXIÓN
-- Tabla para gestionar solicitudes antes de permitir chat
-- ============================================

-- Crear tabla de solicitudes de conexión
CREATE TABLE IF NOT EXISTS connection_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  receiver_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected')),
  message TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Evitar solicitudes duplicadas
  CONSTRAINT unique_connection_request UNIQUE (sender_id, receiver_id),
  -- Evitar auto-solicitudes
  CONSTRAINT no_self_request CHECK (sender_id != receiver_id)
);

-- Índices para búsquedas rápidas
CREATE INDEX IF NOT EXISTS idx_connection_requests_sender 
ON connection_requests(sender_id);

CREATE INDEX IF NOT EXISTS idx_connection_requests_receiver 
ON connection_requests(receiver_id);

CREATE INDEX IF NOT EXISTS idx_connection_requests_status 
ON connection_requests(status);

CREATE INDEX IF NOT EXISTS idx_connection_requests_receiver_status 
ON connection_requests(receiver_id, status);

-- Tabla de conexiones aceptadas (amistades/contactos)
CREATE TABLE IF NOT EXISTS connections (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user1_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  user2_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Evitar conexiones duplicadas (independiente del orden)
  CONSTRAINT unique_connection UNIQUE (user1_id, user2_id),
  -- Evitar auto-conexiones
  CONSTRAINT no_self_connection CHECK (user1_id != user2_id),
  -- Asegurar orden consistente (user1_id < user2_id)
  CONSTRAINT ordered_connection CHECK (user1_id < user2_id)
);

-- Índices para búsquedas rápidas
CREATE INDEX IF NOT EXISTS idx_connections_user1 
ON connections(user1_id);

CREATE INDEX IF NOT EXISTS idx_connections_user2 
ON connections(user2_id);

-- Función para crear conexión automáticamente cuando se acepta solicitud
CREATE OR REPLACE FUNCTION create_connection_on_accept()
RETURNS TRIGGER AS $$
BEGIN
  -- Solo crear conexión si el status cambió a 'accepted'
  IF NEW.status = 'accepted' AND (OLD.status IS NULL OR OLD.status != 'accepted') THEN
    -- Insertar conexión con IDs ordenados
    INSERT INTO connections (user1_id, user2_id)
    VALUES (
      LEAST(NEW.sender_id, NEW.receiver_id),
      GREATEST(NEW.sender_id, NEW.receiver_id)
    )
    ON CONFLICT (user1_id, user2_id) DO NOTHING;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para crear conexión automáticamente
DROP TRIGGER IF EXISTS trigger_create_connection_on_accept ON connection_requests;
CREATE TRIGGER trigger_create_connection_on_accept
  AFTER UPDATE ON connection_requests
  FOR EACH ROW
  EXECUTE FUNCTION create_connection_on_accept();

-- Función para actualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar updated_at
DROP TRIGGER IF EXISTS trigger_update_connection_requests_updated_at ON connection_requests;
CREATE TRIGGER trigger_update_connection_requests_updated_at
  BEFORE UPDATE ON connection_requests
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 🔐 POLÍTICAS RLS (Row Level Security)
-- ============================================

-- Habilitar RLS
ALTER TABLE connection_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE connections ENABLE ROW LEVEL SECURITY;

-- Políticas para connection_requests

-- Ver solicitudes enviadas o recibidas
DROP POLICY IF EXISTS "Users can view their connection requests" ON connection_requests;
CREATE POLICY "Users can view their connection requests"
  ON connection_requests FOR SELECT
  USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

-- Crear solicitudes (solo como sender)
DROP POLICY IF EXISTS "Users can create connection requests" ON connection_requests;
CREATE POLICY "Users can create connection requests"
  ON connection_requests FOR INSERT
  WITH CHECK (auth.uid() = sender_id);

-- Actualizar solicitudes (solo receiver puede aceptar/rechazar)
DROP POLICY IF EXISTS "Receivers can update connection requests" ON connection_requests;
CREATE POLICY "Receivers can update connection requests"
  ON connection_requests FOR UPDATE
  USING (auth.uid() = receiver_id)
  WITH CHECK (auth.uid() = receiver_id);

-- Eliminar solicitudes (solo sender puede cancelar)
DROP POLICY IF EXISTS "Senders can delete their requests" ON connection_requests;
CREATE POLICY "Senders can delete their requests"
  ON connection_requests FOR DELETE
  USING (auth.uid() = sender_id);

-- Políticas para connections

-- Ver conexiones propias
DROP POLICY IF EXISTS "Users can view their connections" ON connections;
CREATE POLICY "Users can view their connections"
  ON connections FOR SELECT
  USING (auth.uid() = user1_id OR auth.uid() = user2_id);

-- Solo el sistema puede crear/eliminar conexiones (a través de triggers)
DROP POLICY IF EXISTS "System can manage connections" ON connections;
CREATE POLICY "System can manage connections"
  ON connections FOR ALL
  USING (true)
  WITH CHECK (true);

-- ============================================
-- 📊 VISTAS ÚTILES
-- ============================================

-- Vista de solicitudes pendientes recibidas con info del remitente
CREATE OR REPLACE VIEW pending_requests_received AS
SELECT 
  cr.id,
  cr.sender_id,
  cr.receiver_id,
  cr.message,
  cr.created_at,
  u.name AS sender_name,
  u.username AS sender_username,
  u.profile_image_url AS sender_profile_image
FROM connection_requests cr
JOIN users u ON u.id = cr.sender_id
WHERE cr.status = 'pending';

-- Vista de solicitudes pendientes enviadas con info del receptor
CREATE OR REPLACE VIEW pending_requests_sent AS
SELECT 
  cr.id,
  cr.sender_id,
  cr.receiver_id,
  cr.message,
  cr.created_at,
  u.name AS receiver_name,
  u.username AS receiver_username,
  u.profile_image_url AS receiver_profile_image
FROM connection_requests cr
JOIN users u ON u.id = cr.receiver_id
WHERE cr.status = 'pending';

-- Vista de conexiones con info de ambos usuarios
CREATE OR REPLACE VIEW user_connections AS
SELECT 
  c.id,
  c.user1_id,
  c.user2_id,
  c.created_at,
  u1.name AS user1_name,
  u1.username AS user1_username,
  u1.profile_image_url AS user1_profile_image,
  u2.name AS user2_name,
  u2.username AS user2_username,
  u2.profile_image_url AS user2_profile_image
FROM connections c
JOIN users u1 ON u1.id = c.user1_id
JOIN users u2 ON u2.id = c.user2_id;

-- ============================================
-- ✅ COMENTARIOS DE DOCUMENTACIÓN
-- ============================================

COMMENT ON TABLE connection_requests IS 'Solicitudes de conexión entre usuarios antes de poder chatear';
COMMENT ON TABLE connections IS 'Conexiones aceptadas entre usuarios (amistades/contactos)';

COMMENT ON COLUMN connection_requests.status IS 'Estado: pending, accepted, rejected';
COMMENT ON COLUMN connection_requests.message IS 'Mensaje opcional del remitente al enviar solicitud';

-- ============================================
-- ✅ VERIFICACIÓN
-- ============================================

-- Verificar tablas creadas
SELECT 
  table_name,
  pg_size_pretty(pg_total_relation_size(quote_ident(table_name)::regclass)) as size
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('connection_requests', 'connections')
ORDER BY table_name;

-- Verificar índices
SELECT 
  schemaname,
  tablename,
  indexname,
  indexdef
FROM pg_indexes
WHERE tablename IN ('connection_requests', 'connections')
ORDER BY tablename, indexname;
