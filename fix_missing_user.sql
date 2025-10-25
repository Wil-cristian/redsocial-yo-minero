-- ========================================
-- VERIFICAR Y ARREGLAR DATOS DE USUARIO
-- ========================================

-- 1. Ver usuarios en Supabase Auth
SELECT id, email, created_at, email_confirmed_at
FROM auth.users
ORDER BY created_at DESC
LIMIT 5;

-- 2. Ver usuarios en tabla users
SELECT id, email, name, username, account_type, created_at
FROM users
ORDER BY created_at DESC
LIMIT 5;

-- 3. Insertar registro faltante en tabla users (AJUSTA EL ID)
-- Copia el ID del paso 1 y pégalo aquí:
INSERT INTO users (
  id, 
  email, 
  name, 
  username, 
  account_type,
  interests,
  watch_keywords,
  services_offered,
  organization_info,
  created_at,
  updated_at
) VALUES (
  'PEGA-AQUI-EL-ID-DEL-AUTH-USERS',  -- ⬅️ CAMBIAR ESTO
  'will.dj1923@gmail.com',
  'wil',
  'wilo',
  'individual',
  ARRAY[]::text[],
  ARRAY[]::text[],
  ARRAY[]::jsonb[],
  '{}'::jsonb,
  NOW(),
  NOW()
);

-- 4. Verificar que se creó correctamente
SELECT id, email, name, username, account_type
FROM users
WHERE email = 'will.dj1923@gmail.com';
