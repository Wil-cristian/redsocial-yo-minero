-- ============================================
-- RLS POLICIES PARA DESARROLLO
-- Ejecutar en Supabase SQL Editor
-- ============================================

-- 1. TABLA POSTS
-- Activar RLS
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Eliminar políticas antiguas si existen
DROP POLICY IF EXISTS "Allow all for authenticated users" ON posts;
DROP POLICY IF EXISTS "Enable read access for all users" ON posts;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON posts;
DROP POLICY IF EXISTS "Enable update for users based on author_id" ON posts;
DROP POLICY IF EXISTS "Enable delete for users based on author_id" ON posts;

-- Crear política permisiva para usuarios autenticados
CREATE POLICY "Allow all for authenticated users" ON posts
  FOR ALL 
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- 2. TABLA POST_LIKES (por si acaso)
ALTER TABLE post_likes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow all for authenticated users" ON post_likes;

CREATE POLICY "Allow all for authenticated users" ON post_likes
  FOR ALL 
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- 3. TABLA USERS (lectura pública, escritura autenticada)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow read for all" ON users;
DROP POLICY IF EXISTS "Allow all for authenticated users" ON users;

-- Todos pueden leer perfiles
CREATE POLICY "Allow read for all" ON users
  FOR SELECT
  USING (true);

-- Solo autenticados pueden modificar
CREATE POLICY "Allow all for authenticated users" ON users
  FOR ALL 
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- ============================================
-- VERIFICACIÓN
-- ============================================
-- Ejecuta esto para verificar que las políticas están activas:
-- SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
-- FROM pg_policies 
-- WHERE tablename IN ('posts', 'post_likes', 'users');
