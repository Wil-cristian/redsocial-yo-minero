-- ============================================
-- FIX RÁPIDO: Dar permisos a create_notification
-- ============================================

-- Opción 1: Dar permisos a la función existente
GRANT EXECUTE ON FUNCTION create_notification(UUID, TEXT, TEXT, TEXT, JSONB, TEXT) TO authenticated;

-- Opción 2: Si no funciona, deshabilitar temporalmente el trigger de notificaciones
-- DROP TRIGGER IF EXISTS trigger_notify_new_message ON messages;

-- Verificar triggers activos en messages
SELECT 
    tgname AS trigger_name,
    tgenabled AS enabled
FROM pg_trigger 
WHERE tgrelid = 'messages'::regclass;

SELECT 'Permisos de notificaciones actualizados' AS status;
