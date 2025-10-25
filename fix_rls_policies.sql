-- ========================================
-- FIX: Agregar política de INSERT para tabla users
-- ========================================
-- Este script corrige el error "permission denied for table users"
-- que ocurre durante el registro de nuevos usuarios

-- Eliminar políticas existentes de users (por si acaso)
DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON users;
DROP POLICY IF EXISTS "Users can update their own profile" ON users;
DROP POLICY IF EXISTS "Users can insert their own profile" ON users;

-- Política para SELECT (ver perfiles)
CREATE POLICY "Public profiles are viewable by everyone" ON users
  FOR SELECT USING (true);

-- Política para INSERT (crear perfil durante registro)
CREATE POLICY "Users can insert their own profile" ON users
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Política para UPDATE (actualizar perfil propio)
CREATE POLICY "Users can update their own profile" ON users
  FOR UPDATE USING (auth.uid() = id);

-- ========================================
-- VERIFICACIÓN
-- ========================================
-- Ejecuta esto después para verificar que las políticas existen:
-- SELECT schemaname, tablename, policyname, cmd, qual, with_check
-- FROM pg_policies
-- WHERE tablename = 'users';
