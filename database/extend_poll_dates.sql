-- ══════════════════════════════════════════════════════════════
-- Script: Extender fechas de encuestas
-- Propósito: Actualizar poll_ends_at para que las encuestas sigan activas
-- Ejecutar en: Dashboard de Supabase → SQL Editor
-- ══════════════════════════════════════════════════════════════

-- Extender TODAS las encuestas existentes por 30 días más
UPDATE posts 
SET poll_ends_at = NOW() + INTERVAL '30 days'
WHERE post_type = 'poll';

-- Verificar las encuestas actualizadas
SELECT 
  id,
  title,
  poll_ends_at,
  CASE 
    WHEN poll_ends_at > NOW() THEN '✅ ACTIVA'
    ELSE '❌ EXPIRADA'
  END as estado,
  EXTRACT(DAY FROM (poll_ends_at - NOW())) as dias_restantes
FROM posts 
WHERE post_type = 'poll'
ORDER BY created_at DESC;
