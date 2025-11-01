-- ========================================
-- DESACTIVAR RLS EN TODAS LAS TABLAS (DESARROLLO)
-- ========================================
-- Ejecuta esto en Supabase SQL Editor

-- Desactivar RLS en users
ALTER TABLE users DISABLE ROW LEVEL SECURITY;

-- Desactivar RLS en posts (para que funcione la creación)
ALTER TABLE posts DISABLE ROW LEVEL SECURITY;

-- Desactivar RLS en post_likes
ALTER TABLE post_likes DISABLE ROW LEVEL SECURITY;

-- Desactivar RLS en otras tablas también
ALTER TABLE products DISABLE ROW LEVEL SECURITY;
ALTER TABLE services DISABLE ROW LEVEL SECURITY;
ALTER TABLE groups DISABLE ROW LEVEL SECURITY;
ALTER TABLE group_members DISABLE ROW LEVEL SECURITY;

-- Verificar que se desactivó
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
ORDER BY tablename;

-- Resultado esperado: rowsecurity = false en todas las tablas
