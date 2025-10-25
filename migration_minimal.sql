-- ============================================
-- MIGRACIÓN MÍNIMA - SOLO LO ESENCIAL
-- ============================================

-- PASO 1: Agregar columna metadata JSONB
ALTER TABLE posts 
ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}'::jsonb;

-- PASO 2: Agregar columnas para referencias opcionales
ALTER TABLE posts
ADD COLUMN IF NOT EXISTS product_id UUID REFERENCES products(id) ON DELETE SET NULL;

ALTER TABLE posts
ADD COLUMN IF NOT EXISTS service_id UUID REFERENCES services(id) ON DELETE SET NULL;

-- PASO 3: Agregar columna para búsqueda full-text
ALTER TABLE posts
ADD COLUMN IF NOT EXISTS search_vector tsvector 
GENERATED ALWAYS AS (
    setweight(to_tsvector('spanish', coalesce(title, '')), 'A') ||
    setweight(to_tsvector('spanish', coalesce(content, '')), 'B')
) STORED;

-- PASO 4: Crear índices
CREATE INDEX IF NOT EXISTS idx_posts_metadata_gin ON posts USING GIN (metadata);
CREATE INDEX IF NOT EXISTS idx_posts_search_vector ON posts USING GIN (search_vector);
CREATE INDEX IF NOT EXISTS idx_posts_type_created ON posts(type, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_posts_author_created ON posts(author_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_posts_product_id ON posts(product_id) WHERE product_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_posts_service_id ON posts(service_id) WHERE service_id IS NOT NULL;

-- PASO 5: Crear función para likes_count
CREATE OR REPLACE FUNCTION update_post_likes_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE posts 
        SET likes_count = likes_count + 1
        WHERE id = NEW.post_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE posts 
        SET likes_count = GREATEST(likes_count - 1, 0)
        WHERE id = OLD.post_id;
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- PASO 6: Crear trigger
DROP TRIGGER IF EXISTS trigger_update_likes_count ON post_likes;
CREATE TRIGGER trigger_update_likes_count
    AFTER INSERT OR DELETE ON post_likes
    FOR EACH ROW
    EXECUTE FUNCTION update_post_likes_count();

-- PASO 7: Agregar columna likes_count si no existe
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'posts' AND column_name = 'likes_count'
    ) THEN
        ALTER TABLE posts ADD COLUMN likes_count INTEGER DEFAULT 0;
        
        UPDATE posts p
        SET likes_count = (
            SELECT COUNT(*) FROM post_likes pl WHERE pl.post_id = p.id
        );
    END IF;
END $$;

-- ============================================
-- ¡LISTO! Ahora puedes crear posts con metadata
-- ============================================
