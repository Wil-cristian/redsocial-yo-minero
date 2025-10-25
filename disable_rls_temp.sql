-- ========================================
-- SOLUCIÓN TEMPORAL: Desactivar RLS en users
-- ========================================
-- SOLO PARA DESARROLLO - En producción debes usar políticas correctas

-- Ver estado actual de RLS
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' AND tablename = 'users';

-- OPCIÓN 1: Desactivar RLS completamente (MÁS FÁCIL PARA DESARROLLO)
ALTER TABLE users DISABLE ROW LEVEL SECURITY;

-- OPCIÓN 2: Mantener RLS pero permitir todo (si prefieres esta)
-- ALTER TABLE users ENABLE ROW LEVEL SECURITY;
-- DROP POLICY IF EXISTS "allow_all" ON users;
-- CREATE POLICY "allow_all" ON users FOR ALL USING (true) WITH CHECK (true);

-- Verificar
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' AND tablename = 'users';

-- Ver datos actuales en la tabla
SELECT id, email, username, name, account_type FROM users;
