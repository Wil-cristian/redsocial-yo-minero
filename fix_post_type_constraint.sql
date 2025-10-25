-- ============================================
-- FIX: Actualizar CHECK CONSTRAINT para incluir todos los tipos de post
-- ============================================

-- 1. Ver el constraint actual
SELECT 
    conname AS constraint_name,
    pg_get_constraintdef(oid) AS constraint_definition
FROM pg_constraint
WHERE conrelid = 'posts'::regclass
AND contype = 'c';

-- 2. ELIMINAR el constraint viejo
ALTER TABLE posts DROP CONSTRAINT IF EXISTS posts_type_check;

-- 3. CREAR el nuevo constraint con TODOS los tipos
ALTER TABLE posts 
ADD CONSTRAINT posts_type_check 
CHECK (type IN ('community', 'request', 'offer', 'product', 'service', 'news', 'poll'));

-- 4. Verificar que se aplicó correctamente
SELECT 
    conname AS constraint_name,
    pg_get_constraintdef(oid) AS constraint_definition
FROM pg_constraint
WHERE conrelid = 'posts'::regclass
AND contype = 'c';
