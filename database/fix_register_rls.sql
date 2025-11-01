-- ========================================
-- FIX: Permitir registro de nuevos usuarios
-- ========================================
-- El problema: Los usuarios no autenticados no pueden insertar en la tabla users
-- Solución: Crear política que permita INSERT si el ID coincide con el auth.uid()

-- Eliminar política existente
DROP POLICY IF EXISTS "Users can insert their own profile" ON users;

-- OPCIÓN 1: Permitir que usuarios autenticados creen su perfil
CREATE POLICY "Users can insert their own profile" ON users
  FOR INSERT 
  WITH CHECK (auth.uid() = id);

-- OPCIÓN 2 (MÁS PERMISIVA - solo para desarrollo):
-- Permite que cualquiera inserte (descomentar si la opción 1 no funciona)
-- DROP POLICY IF EXISTS "Users can insert their own profile" ON users;
-- CREATE POLICY "Allow authenticated users to insert" ON users
--   FOR INSERT 
--   WITH CHECK (auth.role() = 'authenticated');

-- Verificar políticas
SELECT schemaname, tablename, policyname, cmd, roles, qual, with_check
FROM pg_policies
WHERE tablename = 'users';
