-- ============================================
-- AGREGAR COLUMNA IMAGES A LA TABLA POSTS
-- Ejecutar si quieres guardar imágenes fuera de metadata
-- ============================================

-- Agregar columna images[] para URLs de imágenes
ALTER TABLE posts
ADD COLUMN IF NOT EXISTS images TEXT[] DEFAULT ARRAY[]::TEXT[];

-- Crear índice para posts con imágenes
CREATE INDEX IF NOT EXISTS idx_posts_with_images 
ON posts(type, created_at) 
WHERE images IS NOT NULL AND array_length(images, 1) > 0;

-- ============================================
-- AHORA TIENES 2 OPCIONES:
-- ============================================

-- OPCIÓN A: Guardar imágenes en metadata (actual)
-- INSERT INTO posts (author_id, type, title, content, metadata)
-- VALUES (
--     'user-uuid',
--     'product',
--     'iPhone 15',
--     'Descripción',
--     '{
--         "price": 1200,
--         "currency": "USD",
--         "stock": 5,
--         "condition": "nuevo",
--         "images": ["url1.jpg", "url2.jpg"]  ← dentro de metadata
--     }'::jsonb
-- );

-- OPCIÓN B: Guardar imágenes en columna images[] (recomendado)
-- INSERT INTO posts (author_id, type, title, content, metadata, images)
-- VALUES (
--     'user-uuid',
--     'product',
--     'iPhone 15',
--     'Descripción',
--     '{
--         "price": 1200,
--         "currency": "USD",
--         "stock": 5,
--         "condition": "nuevo"
--     }'::jsonb,
--     ARRAY['url1.jpg', 'url2.jpg', 'url3.jpg']  ← columna separada
-- );

-- ============================================
-- NOTA: El código Flutter ya espera images en metadata
-- Si usas OPCIÓN B, necesitas actualizar el repository
-- ============================================
