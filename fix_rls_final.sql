-- ========================================
-- SOLUCIÓN DEFINITIVA: RLS para registro
-- ========================================

-- Ver políticas actuales
SELECT policyname, cmd, with_check FROM pg_policies WHERE tablename = 'users';

-- Eliminar TODAS las políticas de users
DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON users;
DROP POLICY IF EXISTS "Users can update their own profile" ON users;
DROP POLICY IF EXISTS "Users can insert their own profile" ON users;

-- Recrear políticas correctamente
-- 1. SELECT: Todos pueden ver perfiles
CREATE POLICY "users_select_policy" ON users
  FOR SELECT 
  USING (true);

-- 2. INSERT: Usuarios autenticados pueden crear su perfil
CREATE POLICY "users_insert_policy" ON users
  FOR INSERT 
  WITH CHECK (auth.uid() = id);

-- 3. UPDATE: Usuarios pueden actualizar su propio perfil  
CREATE POLICY "users_update_policy" ON users
  FOR UPDATE 
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Verificar que se crearon
SELECT policyname, cmd FROM pg_policies WHERE tablename = 'users';
