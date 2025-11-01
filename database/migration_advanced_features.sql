-- ============================================
-- CARACTERÍSTICAS AVANZADAS - PARTE 2
-- Ejecutar DESPUÉS de migration_minimal.sql
-- ============================================

-- PASO 1: Mejorar search_vector para incluir metadata
-- Primero eliminar la columna existente
ALTER TABLE posts DROP COLUMN IF EXISTS search_vector;

-- Recrear con búsqueda en metadata también
ALTER TABLE posts
ADD COLUMN search_vector tsvector 
GENERATED ALWAYS AS (
    setweight(to_tsvector('spanish', coalesce(title, '')), 'A') ||
    setweight(to_tsvector('spanish', coalesce(content, '')), 'B') ||
    setweight(to_tsvector('spanish', coalesce(metadata->>'description', '')), 'C') ||
    setweight(to_tsvector('spanish', coalesce(metadata->>'condition', '')), 'D')
) STORED;

-- Recrear índice
CREATE INDEX idx_posts_search_vector ON posts USING GIN (search_vector);

-- PASO 2: Índices adicionales para products y services
CREATE INDEX IF NOT EXISTS idx_products_seller_created ON products(seller_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_services_provider_created ON services(provider_id, created_at DESC);
-- Índices para búsqueda por precio (comentado - las tablas products/services pueden no tener price)
-- CREATE INDEX IF NOT EXISTS idx_products_price ON products(price);
-- CREATE INDEX IF NOT EXISTS idx_services_price ON services(price);

-- PASO 3: Crear vista materializada para feed optimizado
DROP MATERIALIZED VIEW IF EXISTS feed_optimized CASCADE;

CREATE MATERIALIZED VIEW feed_optimized AS
SELECT 
    p.id,
    p.type,
    p.title,
    p.content,
    p.metadata,
    p.images,  -- ← Columna images[] incluida
    p.created_at,
    p.likes_count,
    p.author_id,
    u.username,
    u.name as display_name,
    u.profile_image_url as avatar_url,
    u.account_type,
    -- Extraer campos comunes de metadata para búsquedas rápidas
    (metadata->>'price')::numeric as meta_price,
    metadata->>'currency' as meta_currency,
    metadata->>'condition' as meta_condition,
    (metadata->>'stock')::integer as meta_stock
    -- Datos de producto/servicio si están referenciados (comentado - ajustar según tu esquema)
    -- prod.name as product_name,
    -- prod.price as product_price,
    -- serv.name as service_name,
    -- serv.price as service_price
FROM posts p
JOIN users u ON p.author_id = u.id
LEFT JOIN products prod ON p.product_id = prod.id
LEFT JOIN services serv ON p.service_id = serv.id
ORDER BY p.created_at DESC;

-- Índices en la vista materializada
CREATE UNIQUE INDEX idx_feed_optimized_id ON feed_optimized(id);
CREATE INDEX idx_feed_optimized_type_created ON feed_optimized(type, created_at DESC);
CREATE INDEX idx_feed_optimized_author ON feed_optimized(author_id);
CREATE INDEX idx_feed_optimized_price ON feed_optimized(meta_price) WHERE meta_price IS NOT NULL;

-- PASO 4: Función para refrescar feed automáticamente
CREATE OR REPLACE FUNCTION refresh_feed()
RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY feed_optimized;
END;
$$ LANGUAGE plpgsql;

-- PASO 5: Trigger para auto-refrescar feed cuando hay cambios
-- (Opcional: puede ser costoso en alta concurrencia)
CREATE OR REPLACE FUNCTION auto_refresh_feed()
RETURNS TRIGGER AS $$
BEGIN
    -- Refrescar feed de forma asíncrona
    PERFORM refresh_feed();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Descomentar si quieres auto-refresh (puede ser lento)
-- CREATE TRIGGER trigger_auto_refresh_feed
--     AFTER INSERT OR UPDATE OR DELETE ON posts
--     FOR EACH STATEMENT
--     EXECUTE FUNCTION auto_refresh_feed();

-- PASO 6: Constraints de validación para garantizar data correcta
-- Product posts deben tener precio válido
ALTER TABLE posts
ADD CONSTRAINT check_product_metadata
CHECK (
    type != 'product' OR (
        metadata ? 'price' AND 
        metadata ? 'currency' AND
        (metadata->>'price')::numeric > 0
    )
);

-- Poll posts deben tener al menos 2 opciones
ALTER TABLE posts
ADD CONSTRAINT check_poll_metadata
CHECK (
    type != 'poll' OR (
        metadata ? 'options' AND
        jsonb_array_length(metadata->'options') >= 2
    )
);

-- News posts deben tener source
ALTER TABLE posts
ADD CONSTRAINT check_news_metadata
CHECK (
    type != 'news' OR (
        metadata ? 'source'
    )
);

-- PASO 7: Función helper para buscar productos por rango de precio
CREATE OR REPLACE FUNCTION search_products_by_price(
    min_price NUMERIC DEFAULT 0,
    max_price NUMERIC DEFAULT 999999999,
    limit_results INTEGER DEFAULT 50
)
RETURNS TABLE (
    post_id UUID,
    title TEXT,
    price NUMERIC,
    currency TEXT,
    condition TEXT,
    stock INTEGER,
    author_username TEXT,
    created_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id as post_id,
        p.title,
        (p.metadata->>'price')::numeric as price,
        p.metadata->>'currency' as currency,
        p.metadata->>'condition' as condition,
        (p.metadata->>'stock')::integer as stock,
        u.username as author_username,
        p.created_at
    FROM posts p
    JOIN users u ON p.author_id = u.id
    WHERE p.type = 'product'
    AND (p.metadata->>'price')::numeric BETWEEN min_price AND max_price
    ORDER BY p.created_at DESC
    LIMIT limit_results;
END;
$$ LANGUAGE plpgsql;

-- PASO 8: Función para buscar polls activos
CREATE OR REPLACE FUNCTION get_active_polls(limit_results INTEGER DEFAULT 20)
RETURNS TABLE (
    post_id UUID,
    title TEXT,
    options JSONB,
    votes JSONB,
    ends_at TIMESTAMPTZ,
    allow_multiple BOOLEAN,
    author_username TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id as post_id,
        p.title,
        p.metadata->'options' as options,
        p.metadata->'votes' as votes,
        (p.metadata->>'ends_at')::timestamptz as ends_at,
        (p.metadata->>'allow_multiple')::boolean as allow_multiple,
        u.username as author_username
    FROM posts p
    JOIN users u ON p.author_id = u.id
    WHERE p.type = 'poll'
    AND (p.metadata->>'ends_at')::timestamptz > NOW()
    ORDER BY p.created_at DESC
    LIMIT limit_results;
END;
$$ LANGUAGE plpgsql;

-- PASO 9: Función para actualizar votos de poll
CREATE OR REPLACE FUNCTION vote_on_poll(
    poll_id UUID,
    option_text TEXT,
    user_id UUID
)
RETURNS BOOLEAN AS $$
DECLARE
    current_votes JSONB;
    current_count INTEGER;
BEGIN
    -- Obtener votos actuales
    SELECT metadata->'votes' INTO current_votes
    FROM posts
    WHERE id = poll_id AND type = 'poll';
    
    IF current_votes IS NULL THEN
        RAISE EXCEPTION 'Poll not found';
    END IF;
    
    -- Incrementar contador
    current_count := COALESCE((current_votes->>option_text)::integer, 0);
    current_votes := jsonb_set(
        current_votes,
        ARRAY[option_text],
        to_jsonb(current_count + 1)
    );
    
    -- Actualizar post
    UPDATE posts
    SET metadata = jsonb_set(metadata, '{votes}', current_votes)
    WHERE id = poll_id;
    
    -- TODO: Guardar registro de quien votó para evitar duplicados
    -- Necesitarías una tabla poll_votes(poll_id, user_id, option, created_at)
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- PASO 10: Índices parciales para queries específicas
-- Índice para productos disponibles (stock > 0)
CREATE INDEX idx_posts_available_products 
ON posts(type, created_at) 
WHERE type = 'product' AND (metadata->>'stock')::integer > 0;

-- Índice para productos por condición
CREATE INDEX idx_posts_product_condition 
ON posts(type, (metadata->>'condition')) 
WHERE type = 'product';

-- Índice para posts con metadata no vacío
CREATE INDEX idx_posts_with_metadata 
ON posts(type, created_at) 
WHERE metadata IS NOT NULL AND metadata != '{}'::jsonb;

-- PASO 11: Estadísticas y analytics
CREATE OR REPLACE FUNCTION get_post_stats()
RETURNS TABLE (
    post_type TEXT,
    total_posts BIGINT,
    total_likes BIGINT,
    avg_likes NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        type::TEXT as post_type,
        COUNT(*)::BIGINT as total_posts,
        SUM(likes_count)::BIGINT as total_likes,
        ROUND(AVG(likes_count), 2) as avg_likes
    FROM posts
    GROUP BY type
    ORDER BY total_posts DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- EJEMPLOS DE USO AVANZADO
-- ============================================

-- 1. Buscar productos entre $100 y $500
-- SELECT * FROM search_products_by_price(100, 500, 20);

-- 2. Obtener polls activos
-- SELECT * FROM get_active_polls(10);

-- 3. Votar en una encuesta
-- SELECT vote_on_poll('poll-uuid-here', 'Opción 1', 'user-uuid-here');

-- 4. Full-text search en español
-- SELECT id, title, content, ts_rank(search_vector, query) as rank
-- FROM posts, to_tsquery('spanish', 'iPhone | Apple | teléfono') query
-- WHERE search_vector @@ query
-- ORDER BY rank DESC;

-- 5. Refrescar feed manualmente
-- SELECT refresh_feed();

-- 6. Ver estadísticas de posts
-- SELECT * FROM get_post_stats();

-- 7. Buscar productos nuevos con stock
-- SELECT * FROM posts
-- WHERE type = 'product'
-- AND metadata->>'condition' = 'nuevo'
-- AND (metadata->>'stock')::integer > 0
-- ORDER BY created_at DESC;

-- 8. Buscar posts más populares (más likes)
-- SELECT * FROM feed_optimized
-- ORDER BY likes_count DESC
-- LIMIT 10;

-- ============================================
-- NOTAS FINALES
-- ============================================
-- ✅ Vista materializada: Refresca con SELECT refresh_feed();
-- ✅ Constraints activos: Validación automática en INSERT/UPDATE
-- ✅ Índices parciales: Queries súper rápidas para casos específicos
-- ✅ Funciones helper: Simplifica queries complejas
-- ✅ Full-text search: Busca en español con stemming
-- ✅ Analytics: Estadísticas listas para dashboard
