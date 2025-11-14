-- ══════════════════════════════════════════════════════════════
-- VERIFICAR TABLAS DE MENSAJERÍA
-- Ejecutar en: Dashboard de Supabase → SQL Editor
-- ══════════════════════════════════════════════════════════════

-- Verificar si existen las tablas necesarias para el chat
SELECT 
  table_name,
  CASE 
    WHEN table_name IN (
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public'
    ) THEN '✅ EXISTE'
    ELSE '❌ NO EXISTE'
  END as estado
FROM (
  VALUES ('conversations'), ('messages')
) AS required_tables(table_name);

-- Ver estructura de conversations (si existe)
SELECT 
  column_name, 
  data_type, 
  is_nullable
FROM information_schema.columns
WHERE table_name = 'conversations'
ORDER BY ordinal_position;

-- Ver estructura de messages (si existe)
SELECT 
  column_name, 
  data_type, 
  is_nullable
FROM information_schema.columns
WHERE table_name = 'messages'
ORDER BY ordinal_position;

-- Contar conversaciones existentes
SELECT 
  COUNT(*) as total_conversaciones,
  COUNT(DISTINCT user1_id) + COUNT(DISTINCT user2_id) as usuarios_con_chats
FROM conversations;

-- Contar mensajes existentes
SELECT 
  COUNT(*) as total_mensajes,
  COUNT(DISTINCT conversation_id) as conversaciones_con_mensajes
FROM messages;

-- ══════════════════════════════════════════════════════════════
-- SI LAS TABLAS NO EXISTEN:
-- Ejecuta el archivo: database/additional_tables.sql
-- ══════════════════════════════════════════════════════════════
