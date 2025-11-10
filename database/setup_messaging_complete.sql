-- ============================================
-- SISTEMA COMPLETO DE MENSAJERÍA
-- ============================================

-- Crear tablas si no existen
CREATE TABLE IF NOT EXISTS conversations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  -- Participantes (2 usuarios en conversación directa)
  user1_id UUID REFERENCES users(id) ON DELETE CASCADE,
  user2_id UUID REFERENCES users(id) ON DELETE CASCADE,
  
  -- Metadatos
  last_message_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  unread_count_user1 INTEGER DEFAULT 0,
  unread_count_user2 INTEGER DEFAULT 0,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Una conversación única entre dos usuarios
  UNIQUE(user1_id, user2_id),
  
  -- user1_id debe ser menor que user2_id para evitar duplicados
  CHECK (user1_id < user2_id)
);

CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
  sender_id UUID REFERENCES users(id) ON DELETE CASCADE,
  
  -- Contenido
  content TEXT NOT NULL,
  message_type TEXT DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'file')),
  
  -- Metadatos
  is_read BOOLEAN DEFAULT false,
  read_at TIMESTAMP WITH TIME ZONE,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear índices si no existen
CREATE INDEX IF NOT EXISTS idx_conversations_user1 ON conversations(user1_id);
CREATE INDEX IF NOT EXISTS idx_conversations_user2 ON conversations(user2_id);
CREATE INDEX IF NOT EXISTS idx_conversations_last_message ON conversations(last_message_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_conversation ON messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at DESC);

-- ============================================
-- FUNCIONES Y TRIGGERS
-- ============================================

-- Función para actualizar el timestamp de updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger para conversations.updated_at
DROP TRIGGER IF EXISTS update_conversations_updated_at ON conversations;
CREATE TRIGGER update_conversations_updated_at
    BEFORE UPDATE ON conversations
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para messages.updated_at
DROP TRIGGER IF EXISTS update_messages_updated_at ON messages;
CREATE TRIGGER update_messages_updated_at
    BEFORE UPDATE ON messages
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Función para actualizar la conversación cuando se envía un mensaje
CREATE OR REPLACE FUNCTION update_conversation_on_message()
RETURNS TRIGGER AS $$
DECLARE
    conv_record RECORD;
BEGIN
    -- Obtener la conversación
    SELECT * INTO conv_record FROM conversations WHERE id = NEW.conversation_id;
    
    IF conv_record IS NOT NULL THEN
        -- Actualizar last_message_at
        UPDATE conversations
        SET last_message_at = NEW.created_at
        WHERE id = NEW.conversation_id;
        
        -- Incrementar contador de no leídos del receptor
        IF NEW.sender_id = conv_record.user1_id THEN
            UPDATE conversations
            SET unread_count_user2 = unread_count_user2 + 1
            WHERE id = NEW.conversation_id;
        ELSE
            UPDATE conversations
            SET unread_count_user1 = unread_count_user1 + 1
            WHERE id = NEW.conversation_id;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar conversación al insertar mensaje
DROP TRIGGER IF EXISTS trigger_update_conversation_on_message ON messages;
CREATE TRIGGER trigger_update_conversation_on_message
    AFTER INSERT ON messages
    FOR EACH ROW
    EXECUTE FUNCTION update_conversation_on_message();

-- ============================================
-- POLÍTICAS RLS (Row Level Security)
-- ============================================

-- Habilitar RLS
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Eliminar políticas existentes
DROP POLICY IF EXISTS "Users can view their conversations" ON conversations;
DROP POLICY IF EXISTS "Users can create conversations" ON conversations;
DROP POLICY IF EXISTS "Users can update their conversations" ON conversations;
DROP POLICY IF EXISTS "Users can view messages in their conversations" ON messages;
DROP POLICY IF EXISTS "Users can send messages" ON messages;
DROP POLICY IF EXISTS "Users can update their messages" ON messages;

-- CONVERSATIONS: Ver conversaciones donde el usuario participa
CREATE POLICY "Users can view their conversations"
ON conversations FOR SELECT
TO authenticated
USING (
    auth.uid() = user1_id OR auth.uid() = user2_id
);

-- CONVERSATIONS: Crear conversaciones
CREATE POLICY "Users can create conversations"
ON conversations FOR INSERT
TO authenticated
WITH CHECK (
    auth.uid() = user1_id OR auth.uid() = user2_id
);

-- CONVERSATIONS: Actualizar conversaciones propias
CREATE POLICY "Users can update their conversations"
ON conversations FOR UPDATE
TO authenticated
USING (
    auth.uid() = user1_id OR auth.uid() = user2_id
)
WITH CHECK (
    auth.uid() = user1_id OR auth.uid() = user2_id
);

-- MESSAGES: Ver mensajes de conversaciones propias
CREATE POLICY "Users can view messages in their conversations"
ON messages FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM conversations
        WHERE conversations.id = messages.conversation_id
        AND (conversations.user1_id = auth.uid() OR conversations.user2_id = auth.uid())
    )
);

-- MESSAGES: Enviar mensajes
CREATE POLICY "Users can send messages"
ON messages FOR INSERT
TO authenticated
WITH CHECK (
    auth.uid() = sender_id
    AND EXISTS (
        SELECT 1 FROM conversations
        WHERE conversations.id = conversation_id
        AND (conversations.user1_id = auth.uid() OR conversations.user2_id = auth.uid())
    )
);

-- MESSAGES: Actualizar mensajes propios (marcar como leído)
CREATE POLICY "Users can update their messages"
ON messages FOR UPDATE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM conversations
        WHERE conversations.id = messages.conversation_id
        AND (conversations.user1_id = auth.uid() OR conversations.user2_id = auth.uid())
    )
);

-- ============================================
-- FUNCIÓN HELPER: Obtener o crear conversación
-- ============================================

CREATE OR REPLACE FUNCTION get_or_create_conversation(
    p_user1_id UUID,
    p_user2_id UUID
)
RETURNS UUID AS $$
DECLARE
    v_conversation_id UUID;
    v_sorted_user1 UUID;
    v_sorted_user2 UUID;
BEGIN
    -- Ordenar IDs para garantizar user1 < user2
    IF p_user1_id < p_user2_id THEN
        v_sorted_user1 := p_user1_id;
        v_sorted_user2 := p_user2_id;
    ELSE
        v_sorted_user1 := p_user2_id;
        v_sorted_user2 := p_user1_id;
    END IF;
    
    -- Buscar conversación existente
    SELECT id INTO v_conversation_id
    FROM conversations
    WHERE user1_id = v_sorted_user1 AND user2_id = v_sorted_user2;
    
    -- Si no existe, crear
    IF v_conversation_id IS NULL THEN
        INSERT INTO conversations (user1_id, user2_id)
        VALUES (v_sorted_user1, v_sorted_user2)
        RETURNING id INTO v_conversation_id;
    END IF;
    
    RETURN v_conversation_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Conceder permisos de ejecución
GRANT EXECUTE ON FUNCTION get_or_create_conversation(UUID, UUID) TO authenticated;

-- ============================================
-- VERIFICACIÓN
-- ============================================

SELECT 'Tablas de mensajería creadas exitosamente' AS status;
SELECT COUNT(*) AS total_conversations FROM conversations;
SELECT COUNT(*) AS total_messages FROM messages;
