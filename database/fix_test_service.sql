-- ============================================
-- 🔧 Crear el servicio de prueba en la tabla services
-- ============================================

-- Primero, obtener el author_id del post
DO $$
DECLARE
  v_author_id UUID;
BEGIN
  SELECT author_id INTO v_author_id
  FROM posts
  WHERE id = 'a1234567-1234-1234-1234-123456789abc';

  -- Insertar el servicio de prueba en la tabla services
  INSERT INTO services (
    id,
    provider_id,
    name,
    description,
    category,
    tags,
    pricing_from,
    pricing_to,
    pricing_unit,
    availability,
    is_available,
    created_at,
    updated_at
  ) VALUES (
    '12345678-1234-1234-1234-123456789abc'::UUID,
    v_author_id,
    'Servicio de Prueba - Sistema Booking',
    'Servicio de prueba con horario de 08:00 a 18:00 de Lunes a Sábado',
    'Servicios Técnicos',
    ARRAY['prueba', 'booking', 'test'],
    25.00,
    50.00,
    'hora',
    'Lunes a Sábado: 08:00 - 18:00',
    true,
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    updated_at = NOW();
END $$;

-- Verificar que el servicio existe
SELECT id, name, provider_id, pricing_from, pricing_to 
FROM services 
WHERE id = '12345678-1234-1234-1234-123456789abc';
