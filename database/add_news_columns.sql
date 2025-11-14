-- ══════════════════════════════════════════════════════════════
-- Script: Agregar soporte para noticias en tabla posts
-- Propósito: Añadir columnas necesarias para tipo 'news'
-- Ejecutar PRIMERO antes de insert_test_news.sql
-- ══════════════════════════════════════════════════════════════

-- 1. Actualizar el CHECK constraint para incluir 'news', 'product', 'service', 'poll'
ALTER TABLE posts DROP CONSTRAINT IF EXISTS posts_type_check;
ALTER TABLE posts ADD CONSTRAINT posts_type_check 
  CHECK (type IN ('community', 'request', 'offer', 'news', 'product', 'service', 'poll'));

-- 2. Agregar columnas para NOTICIAS
ALTER TABLE posts ADD COLUMN IF NOT EXISTS news_source TEXT;
ALTER TABLE posts ADD COLUMN IF NOT EXISTS news_author TEXT;
ALTER TABLE posts ADD COLUMN IF NOT EXISTS news_cover_image TEXT;

-- 3. Agregar columnas para PRODUCTOS
ALTER TABLE posts ADD COLUMN IF NOT EXISTS product_images TEXT[] DEFAULT '{}';
ALTER TABLE posts ADD COLUMN IF NOT EXISTS product_price DECIMAL(10, 2);
ALTER TABLE posts ADD COLUMN IF NOT EXISTS product_currency TEXT DEFAULT 'USD';
ALTER TABLE posts ADD COLUMN IF NOT EXISTS product_stock INTEGER;
ALTER TABLE posts ADD COLUMN IF NOT EXISTS product_condition TEXT;

-- 4. Agregar columnas para ENCUESTAS (polls)
ALTER TABLE posts ADD COLUMN IF NOT EXISTS poll_options TEXT[] DEFAULT '{}';
ALTER TABLE posts ADD COLUMN IF NOT EXISTS poll_votes JSONB DEFAULT '{}'::jsonb;
ALTER TABLE posts ADD COLUMN IF NOT EXISTS poll_allow_multiple BOOLEAN DEFAULT false;
ALTER TABLE posts ADD COLUMN IF NOT EXISTS poll_ends_at TIMESTAMP WITH TIME ZONE;

-- 5. Agregar columna comments si no existe (compatibilidad)
ALTER TABLE posts ADD COLUMN IF NOT EXISTS comments INTEGER DEFAULT 0;

-- 6. Crear índices para las nuevas columnas
CREATE INDEX IF NOT EXISTS idx_posts_news_source ON posts(news_source) WHERE news_source IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_posts_product_price ON posts(product_price) WHERE product_price IS NOT NULL;

-- ══════════════════════════════════════════════════════════════
-- VERIFICACIÓN
-- ══════════════════════════════════════════════════════════════

-- Ver estructura actualizada de la tabla posts
SELECT 
  column_name, 
  data_type, 
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'posts' 
  AND column_name IN (
    'type', 
    'news_source', 
    'news_author', 
    'news_cover_image',
    'product_images',
    'product_price',
    'poll_options',
    'comments'
  )
ORDER BY column_name;

-- Ver tipos permitidos
SELECT constraint_name, check_clause
FROM information_schema.check_constraints
WHERE constraint_name = 'posts_type_check';
