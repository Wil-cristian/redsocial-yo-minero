-- ============================================
-- 🔧 Agregar service_id a la tabla posts
-- ============================================

-- Agregar columna service_id
ALTER TABLE posts 
ADD COLUMN IF NOT EXISTS service_id UUID REFERENCES services(id);

-- Crear índice para mejorar las consultas
CREATE INDEX IF NOT EXISTS idx_posts_service_id ON posts(service_id);

-- Actualizar el post de prueba con el service_id correcto
UPDATE posts 
SET service_id = '12345678-1234-1234-1234-123456789abc'::UUID
WHERE id = 'a1234567-1234-1234-1234-123456789abc';

-- ============================================
-- 📋 Ver qué servicios existen en la tabla services
-- ============================================
SELECT id, name FROM services;

-- ============================================
-- 🔧 Crear servicios para los demás posts (si no existen)
-- ============================================
-- Nota: Ejecuta esto después de ver qué servicios ya existen
-- Para cada post de servicio, necesitas crear un registro en services
-- y luego hacer UPDATE posts SET service_id = '<uuid>' WHERE id = '<post_id>';

-- ============================================
-- 🚀 AUTOMATIZAR: Crear servicios para todos los posts tipo 'service' que no tienen service_id
-- ============================================

DO $$
DECLARE
  post_record RECORD;
  new_service_id UUID;
BEGIN
  -- Iterar sobre todos los posts de tipo 'service' sin service_id
  FOR post_record IN 
    SELECT id, author_id, service_name, title, content, service_tags, tags,
           pricing_from, pricing_to, pricing_unit, availability
    FROM posts 
    WHERE type = 'service' AND service_id IS NULL
  LOOP
    -- Generar nuevo UUID para el servicio
    new_service_id := gen_random_uuid();
    
    -- Insertar servicio en la tabla services
    INSERT INTO services (
      id, provider_id, name, description, category, tags,
      pricing_from, pricing_to, pricing_unit, availability,
      is_available, created_at, updated_at
    ) VALUES (
      new_service_id,
      post_record.author_id,
      COALESCE(post_record.service_name, post_record.title),
      post_record.content,
      'General', -- Categoría por defecto
      COALESCE(post_record.service_tags, post_record.tags, ARRAY[]::TEXT[]),
      post_record.pricing_from,
      post_record.pricing_to,
      COALESCE(post_record.pricing_unit, 'hora'),
      COALESCE(post_record.availability, 'Disponible'),
      true,
      NOW(),
      NOW()
    );
    
    -- Crear disponibilidad por defecto (Lunes a Viernes, 9:00-18:00)
    INSERT INTO service_availability (service_id, day_of_week, start_time, end_time, is_active)
    VALUES 
      (new_service_id, 1, '09:00', '18:00', true), -- Lunes
      (new_service_id, 2, '09:00', '18:00', true), -- Martes
      (new_service_id, 3, '09:00', '18:00', true), -- Miércoles
      (new_service_id, 4, '09:00', '18:00', true), -- Jueves
      (new_service_id, 5, '09:00', '18:00', true); -- Viernes
    
    -- Actualizar el post con el service_id
    UPDATE posts 
    SET service_id = new_service_id 
    WHERE id = post_record.id;
    
    RAISE NOTICE 'Servicio creado para post: % -> service_id: %', post_record.title, new_service_id;
  END LOOP;
END $$;

-- Verificar posts de servicio y sus service_ids
SELECT id, title, type, service_id FROM posts WHERE type = 'service';
