-- ==================================================
-- SCRIPT: Crear Usuarios de Prueba en Supabase Auth
-- ==================================================
-- Este script crea usuarios de prueba en Supabase
-- para poder iniciar sesión en la aplicación
-- ==================================================

-- IMPORTANTE: Este script debe ejecutarse en el SQL Editor de Supabase
-- También necesitas crear los usuarios en Supabase Auth manualmente o usar la API

-- ==================================================
-- PASO 1: Verificar usuarios existentes
-- ==================================================

SELECT 
  id,
  email,
  username,
  name,
  account_type,
  created_at
FROM users
WHERE email IN ('empresa@test.com', 'juan@test.com', 'maria.gerente@test.com', 'carlos.tecnico@test.com')
ORDER BY email;

-- ==================================================
-- PASO 2: Insertar usuarios de prueba en la tabla users
-- ==================================================

-- 🏢 EMPRESA DE PRUEBA
INSERT INTO users (
  id,
  email,
  username,
  name,
  account_type,
  organization_info,
  bio,
  is_verified,
  followers_count,
  following_count,
  must_change_password
) VALUES (
  '00000000-0000-0000-0000-000000000001'::uuid,
  'empresa@test.com',
  'minera_test',
  'Minera Test S.A.',
  'company',
  '{"companyName": "Minera Test S.A.", "companyRole": "owner"}'::jsonb,
  'Empresa minera de prueba para desarrollo',
  true,
  150,
  80,
  false
) ON CONFLICT (email) DO UPDATE SET
  username = EXCLUDED.username,
  name = EXCLUDED.name,
  account_type = EXCLUDED.account_type,
  organization_info = EXCLUDED.organization_info,
  bio = EXCLUDED.bio,
  is_verified = EXCLUDED.is_verified;

-- 🧑 USUARIO INDIVIDUAL
INSERT INTO users (
  id,
  email,
  username,
  name,
  account_type,
  organization_info,
  bio,
  is_verified,
  followers_count,
  following_count,
  must_change_password
) VALUES (
  '00000000-0000-0000-0000-000000000002'::uuid,
  'juan@test.com',
  'juan_minero',
  'Juan Minero',
  'individual',
  '{}'::jsonb,
  'Minero independiente',
  false,
  85,
  120,
  false
) ON CONFLICT (email) DO UPDATE SET
  username = EXCLUDED.username,
  name = EXCLUDED.name,
  account_type = EXCLUDED.account_type;

-- 👔 EMPLEADO CEO
INSERT INTO users (
  id,
  email,
  username,
  name,
  account_type,
  organization_info,
  bio,
  is_verified,
  followers_count,
  following_count,
  must_change_password
) VALUES (
  '00000000-0000-0000-0000-000000000003'::uuid,
  'maria.gerente@test.com',
  'maria_gerente',
  'María Gerente',
  'worker',
  '{
    "companyId": "00000000-0000-0000-0000-000000000001",
    "companyName": "Minera Test S.A.",
    "roleId": "ceo",
    "department": "Gerencia General",
    "companyRole": "employee"
  }'::jsonb,
  'CEO de Minera Test',
  true,
  200,
  50,
  true
) ON CONFLICT (email) DO UPDATE SET
  username = EXCLUDED.username,
  name = EXCLUDED.name,
  account_type = EXCLUDED.account_type,
  organization_info = EXCLUDED.organization_info,
  must_change_password = EXCLUDED.must_change_password;

-- 👷 EMPLEADO TÉCNICO
INSERT INTO users (
  id,
  email,
  username,
  name,
  account_type,
  organization_info,
  bio,
  is_verified,
  followers_count,
  following_count,
  must_change_password
) VALUES (
  '00000000-0000-0000-0000-000000000004'::uuid,
  'carlos.tecnico@test.com',
  'carlos_tecnico',
  'Carlos Técnico',
  'worker',
  '{
    "companyId": "00000000-0000-0000-0000-000000000001",
    "companyName": "Minera Test S.A.",
    "roleId": "technician",
    "department": "Operaciones - Zona Norte",
    "companyRole": "employee"
  }'::jsonb,
  'Técnico operativo en minera',
  false,
  45,
  60,
  false
) ON CONFLICT (email) DO UPDATE SET
  username = EXCLUDED.username,
  name = EXCLUDED.name,
  account_type = EXCLUDED.account_type,
  organization_info = EXCLUDED.organization_info;

-- ==================================================
-- VERIFICAR QUE SE CREARON CORRECTAMENTE
-- ==================================================

SELECT 
  id,
  email,
  username,
  name,
  account_type,
  must_change_password,
  'Usuario creado correctamente' as status
FROM users
WHERE email IN ('empresa@test.com', 'juan@test.com', 'maria.gerente@test.com', 'carlos.tecnico@test.com')
ORDER BY email;

-- ==================================================
-- INSTRUCCIONES IMPORTANTES
-- ==================================================

/*

⚠️ PASO CRÍTICO: CREAR USUARIOS EN SUPABASE AUTH

Los usuarios también necesitan existir en Supabase Authentication.
Tienes 2 opciones:

OPCIÓN 1: Desde el Dashboard de Supabase (RECOMENDADO)
=========================================================
1. Ve a https://app.supabase.com/project/ssyhtymdfkcvindyhyxy
2. Click en "Authentication" en el menú lateral
3. Click en "Users"
4. Click en "Add user" → "Create new user"
5. Crea cada usuario con:
   
   👤 Usuario 1 (Empresa):
   - Email: empresa@test.com
   - Password: test123
   - Auto Confirm User: ✅ SÍ (marcar)
   
   👤 Usuario 2 (Individual):
   - Email: juan@test.com
   - Password: test123
   - Auto Confirm User: ✅ SÍ (marcar)
   
   👤 Usuario 3 (CEO):
   - Email: maria.gerente@test.com
   - Password: test123
   - Auto Confirm User: ✅ SÍ (marcar)
   
   👤 Usuario 4 (Técnico):
   - Email: carlos.tecnico@test.com
   - Password: test123
   - Auto Confirm User: ✅ SÍ (marcar)

OPCIÓN 2: Usando SQL (Avanzado)
=================================
Ejecuta este código en el SQL Editor:

-- Insertar usuarios en auth.users (requiere privilegios admin)
-- NOTA: Las contraseñas deben estar hasheadas con bcrypt

INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  raw_app_meta_data,
  raw_user_meta_data,
  is_super_admin,
  confirmation_token
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  '00000000-0000-0000-0000-000000000001'::uuid,
  'authenticated',
  'authenticated',
  'empresa@test.com',
  crypt('test123', gen_salt('bf')), -- Hashear la contraseña
  NOW(),
  NOW(),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{}',
  false,
  ''
);

-- Repetir para los demás usuarios...

*/

-- ==================================================
-- DESPUÉS DE CREAR LOS USUARIOS EN AUTH
-- ==================================================

-- Vincula los usuarios de auth.users con la tabla public.users
-- usando triggers o manualmente

-- Verificar que los IDs coincidan:
SELECT 
  au.id as auth_id,
  au.email as auth_email,
  u.id as users_id,
  u.email as users_email,
  CASE 
    WHEN au.id::text = u.id::text THEN '✅ IDs coinciden'
    ELSE '❌ IDs NO coinciden'
  END as status
FROM auth.users au
LEFT JOIN users u ON au.id = u.id
WHERE au.email IN ('empresa@test.com', 'juan@test.com', 'maria.gerente@test.com', 'carlos.tecnico@test.com');

-- ==================================================
-- ✅ RESUMEN
-- ==================================================

/*
CREDENCIALES DE ACCESO:

🏢 Empresa:
   Email: empresa@test.com
   Password: test123
   Funcionalidades: Dashboard completo, Empleados, Producción Minera, Métricas

🧑 Usuario Individual:
   Email: juan@test.com
   Password: test123
   Funcionalidades: Vista de minero independiente

👔 Empleado CEO:
   Email: maria.gerente@test.com
   Password: test123
   ⚠️ IMPORTANTE: Debe cambiar contraseña en primer login

👷 Empleado Técnico:
   Email: carlos.tecnico@test.com
   Password: test123
   Funcionalidades: Acceso limitado según rol

*/
