-- ============================================
-- DESACTIVAR RLS COMPLETAMENTE (Para desarrollo)
-- Ejecutar en Supabase SQL Editor
-- ============================================

-- Desactivar RLS en todas las tablas principales
ALTER TABLE posts DISABLE ROW LEVEL SECURITY;
ALTER TABLE post_likes DISABLE ROW LEVEL SECURITY;
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE products DISABLE ROW LEVEL SECURITY;
ALTER TABLE services DISABLE ROW LEVEL SECURITY;
ALTER TABLE groups DISABLE ROW LEVEL SECURITY;
ALTER TABLE group_members DISABLE ROW LEVEL SECURITY;
ALTER TABLE employee_roles DISABLE ROW LEVEL SECURITY;

-- Eliminar TODAS las políticas existentes
DROP POLICY IF EXISTS "Allow all for authenticated users" ON posts;
DROP POLICY IF EXISTS "Enable read access for all users" ON posts;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON posts;
DROP POLICY IF EXISTS "Enable update for users based on author_id" ON posts;
DROP POLICY IF EXISTS "Enable delete for users based on author_id" ON posts;

DROP POLICY IF EXISTS "Allow all for authenticated users" ON post_likes;

DROP POLICY IF EXISTS "Allow read for all" ON users;
DROP POLICY IF EXISTS "Allow all for authenticated users" ON users;

-- Verificar que RLS está desactivado
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('posts', 'post_likes', 'users', 'products', 'services');
-- rowsecurity debe ser 'false' para todas
