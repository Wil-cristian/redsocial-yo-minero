-- ============================================
-- FIX: Remover dependencia de notificaciones en mensajería
-- ============================================

-- Primero, eliminar cualquier trigger que use create_notification
DROP TRIGGER IF EXISTS create_message_notification ON messages;

-- Crear función simple de notificación si no existe
CREATE OR REPLACE FUNCTION create_notification(
    p_user_id UUID,
    p_type TEXT,
    p_title TEXT,
    p_message TEXT,
    p_related_id UUID DEFAULT NULL
)
RETURNS void AS $$
BEGIN
    -- Si la tabla notifications existe, insertar
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'notifications') THEN
        INSERT INTO notifications (user_id, type, title, message, related_id)
        VALUES (p_user_id, p_type, p_title, p_message, p_related_id);
    END IF;
    -- Si no existe, simplemente continuar sin error
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Dar permisos
GRANT EXECUTE ON FUNCTION create_notification(UUID, TEXT, TEXT, TEXT, UUID) TO authenticated;

-- Verificar que el trigger de mensajes NO intente crear notificaciones
-- Re-crear el trigger sin notificaciones
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

-- Re-crear trigger
DROP TRIGGER IF EXISTS trigger_update_conversation_on_message ON messages;
CREATE TRIGGER trigger_update_conversation_on_message
    AFTER INSERT ON messages
    FOR EACH ROW
    EXECUTE FUNCTION update_conversation_on_message();

-- Verificación
SELECT 'Fix de notificaciones aplicado exitosamente' AS status;
