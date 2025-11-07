-- ============================================
-- TABLA: notifications
-- Notificaciones en tiempo real para usuarios
-- ============================================
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  -- Destinatario
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  -- Tipo de notificación
  type TEXT NOT NULL CHECK (type IN (
    'message',           -- Nuevo mensaje
    'group_invite',      -- Invitación a grupo
    'product_liked',     -- Producto marcado como favorito
    'service_request',   -- Solicitud de servicio
    'new_follower',      -- Nuevo seguidor
    'comment',           -- Comentario en publicación
    'mention'            -- Mención en publicación
  )),
  
  -- Contenido
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  
  -- Datos adicionales (JSON)
  data JSONB DEFAULT '{}'::jsonb,
  
  -- URL de acción (opcional)
  action_url TEXT,
  
  -- Estado
  is_read BOOLEAN DEFAULT FALSE,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  read_at TIMESTAMP WITH TIME ZONE
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_unread ON notifications(user_id, is_read) WHERE is_read = FALSE;
CREATE INDEX IF NOT EXISTS idx_notifications_created ON notifications(created_at DESC);

-- RLS Policies
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Los usuarios solo pueden ver sus propias notificaciones
CREATE POLICY notifications_select_policy ON notifications
  FOR SELECT
  USING (auth.uid() = user_id);

-- Los usuarios solo pueden insertar notificaciones para sí mismos
-- Los triggers usarán una función SECURITY DEFINER para saltarse esta restricción
CREATE POLICY notifications_insert_policy ON notifications
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Los usuarios pueden actualizar el estado de sus notificaciones
CREATE POLICY notifications_update_policy ON notifications
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Los usuarios pueden eliminar sus propias notificaciones
CREATE POLICY notifications_delete_policy ON notifications
  FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================
-- FUNCIÓN AUXILIAR: Crear notificación (SECURITY DEFINER)
-- Esta función puede saltarse RLS para permitir triggers del sistema
-- ============================================
CREATE OR REPLACE FUNCTION create_notification(
  p_user_id UUID,
  p_type TEXT,
  p_title TEXT,
  p_body TEXT,
  p_data JSONB DEFAULT '{}'::jsonb,
  p_action_url TEXT DEFAULT NULL
)
RETURNS UUID
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  notification_id UUID;
BEGIN
  -- Insertar la notificación (saltando RLS gracias a SECURITY DEFINER)
  INSERT INTO notifications (user_id, type, title, body, data, action_url)
  VALUES (p_user_id, p_type, p_title, p_body, p_data, p_action_url)
  RETURNING id INTO notification_id;
  
  RETURN notification_id;
END;
$$;

-- Revocar permisos de ejecución para PUBLIC
-- Solo los triggers y funciones del sistema pueden llamar a esta función
REVOKE ALL ON FUNCTION create_notification(UUID, TEXT, TEXT, TEXT, JSONB, TEXT) FROM PUBLIC, anon, authenticated;

-- ============================================
-- FUNCIÓN: Crear notificación de nuevo mensaje
-- ============================================
CREATE OR REPLACE FUNCTION notify_new_message()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  recipient_id UUID;
  sender_name TEXT;
BEGIN
  -- Determinar el destinatario (el otro usuario en la conversación)
  SELECT 
    CASE 
      WHEN c.user1_id = NEW.sender_id THEN c.user2_id
      ELSE c.user1_id
    END INTO recipient_id
  FROM conversations c
  WHERE c.id = NEW.conversation_id;
  
  -- Obtener el nombre del remitente
  SELECT name INTO sender_name
  FROM users
  WHERE id = NEW.sender_id;
  
  -- Crear la notificación usando la función SECURITY DEFINER
  PERFORM create_notification(
    recipient_id,
    'message',
    'Nuevo mensaje de ' || sender_name,
    LEFT(NEW.content, 100),
    jsonb_build_object(
      'conversation_id', NEW.conversation_id,
      'sender_id', NEW.sender_id,
      'message_id', NEW.id
    ),
    '/messages/' || NEW.conversation_id
  );
  
  RETURN NEW;
END;
$$;

-- Trigger para notificar nuevos mensajes
DROP TRIGGER IF EXISTS trigger_notify_new_message ON messages;
CREATE TRIGGER trigger_notify_new_message
  AFTER INSERT ON messages
  FOR EACH ROW
  EXECUTE FUNCTION notify_new_message();

COMMENT ON TABLE notifications IS 'Sistema de notificaciones en tiempo real para usuarios';
COMMENT ON COLUMN notifications.type IS 'Tipo de notificación: message, group_invite, product_liked, etc.';
COMMENT ON COLUMN notifications.data IS 'Datos adicionales en formato JSON para contexto';
COMMENT ON FUNCTION create_notification IS 'Función auxiliar SECURITY DEFINER para crear notificaciones desde triggers. No debe ser llamada directamente por clientes.';
