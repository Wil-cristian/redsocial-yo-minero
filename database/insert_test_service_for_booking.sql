-- 🧪 INSERTAR SERVICIO DE PRUEBA PARA SISTEMA DE BOOKING
-- Ejecutar en Supabase SQL Editor

-- ============================================
-- 1. Insertar servicio de prueba
-- ============================================
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
  image_urls,
  created_at
)
VALUES (
  '12345678-1234-1234-1234-123456789abc'::UUID, -- ID fijo para pruebas
  '5f4fb2fa-54b6-4a2d-a426-80e7284db393'::UUID, -- will.dj1923@gmail.com
  'Servicio de Prueba - Booking',
  'Este es un servicio de prueba configurado con disponibilidad completa para hacer reservas. Puedes reservar de Lunes a Viernes de 8:00 AM a 6:00 PM.',
  'Tecnología',
  ARRAY['prueba', 'booking', 'test', 'desarrollo'],
  25.00, -- $25 por hora
  50.00,
  'hora',
  'Lunes a Viernes, 8:00 AM - 6:00 PM',
  true,
  ARRAY[]::TEXT[],
  NOW()
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  availability = EXCLUDED.availability,
  is_available = true;

-- ============================================
-- 2. Configurar disponibilidad (Lunes a Viernes)
-- ============================================
-- Eliminar disponibilidades anteriores para este servicio
DELETE FROM service_availability 
WHERE service_id = '12345678-1234-1234-1234-123456789abc'::UUID;

-- Insertar disponibilidad para días laborables (Lunes=1 a Viernes=5)
INSERT INTO service_availability (service_id, day_of_week, start_time, end_time, is_active)
VALUES 
  ('12345678-1234-1234-1234-123456789abc'::UUID, 1, '08:00'::TIME, '18:00'::TIME, true), -- Lunes
  ('12345678-1234-1234-1234-123456789abc'::UUID, 2, '08:00'::TIME, '18:00'::TIME, true), -- Martes
  ('12345678-1234-1234-1234-123456789abc'::UUID, 3, '08:00'::TIME, '18:00'::TIME, true), -- Miércoles
  ('12345678-1234-1234-1234-123456789abc'::UUID, 4, '08:00'::TIME, '18:00'::TIME, true), -- Jueves
  ('12345678-1234-1234-1234-123456789abc'::UUID, 5, '08:00'::TIME, '18:00'::TIME, true); -- Viernes

-- ============================================
-- 3. Opcional: Configurar también Sábado (medio día)
-- ============================================
INSERT INTO service_availability (service_id, day_of_week, start_time, end_time, is_active)
VALUES 
  ('12345678-1234-1234-1234-123456789abc'::UUID, 6, '09:00'::TIME, '14:00'::TIME, true); -- Sábado

-- ============================================
-- 4. Crear un POST en comunidad para mostrar este servicio
-- ============================================
INSERT INTO posts (
  id,
  type,
  author_id,
  title,
  content,
  categories,
  tags,
  service_name,
  service_tags,
  pricing_from,
  pricing_to,
  pricing_unit,
  availability,
  likes,
  comments,
  created_at
)
VALUES (
  'a1234567-1234-1234-1234-123456789abc',
  'service',
  '5f4fb2fa-54b6-4a2d-a426-80e7284db393'::UUID,
  'Servicio de Prueba - Sistema Booking',
  'Servicio configurado especialmente para probar el sistema de reservas. Disponible de Lunes a Viernes de 8:00 AM a 6:00 PM y Sábados de 9:00 AM a 2:00 PM. ¡Haz tu reserva ahora!',
  ARRAY['Servicios', 'Tecnología', 'Desarrollo'],
  ARRAY['booking', 'prueba', 'test', 'reservas'],
  'Servicio de Prueba - Booking',
  ARRAY['prueba', 'booking', 'test'],
  25.00,
  50.00,
  'hora',
  'Lun-Vie: 8AM-6PM, Sáb: 9AM-2PM',
  0,
  0,
  NOW()
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  content = EXCLUDED.content,
  availability = EXCLUDED.availability;

-- ============================================
-- ✅ VERIFICACIÓN
-- ============================================
-- Verificar que el servicio fue creado
SELECT 
  id,
  name,
  pricing_from,
  pricing_unit,
  availability,
  is_available
FROM services 
WHERE id = '12345678-1234-1234-1234-123456789abc'::UUID;

-- Verificar disponibilidad configurada
SELECT 
  day_of_week,
  CASE day_of_week
    WHEN 1 THEN 'Lunes'
    WHEN 2 THEN 'Martes'
    WHEN 3 THEN 'Miércoles'
    WHEN 4 THEN 'Jueves'
    WHEN 5 THEN 'Viernes'
    WHEN 6 THEN 'Sábado'
    WHEN 7 THEN 'Domingo'
  END as dia_nombre,
  start_time,
  end_time,
  is_active
FROM service_availability
WHERE service_id = '12345678-1234-1234-1234-123456789abc'::UUID
ORDER BY day_of_week;

-- Verificar post creado
SELECT 
  id,
  title,
  type,
  author_id,
  pricing_from,
  availability
FROM posts
WHERE id = 'a1234567-1234-1234-1234-123456789abc';

-- ============================================
-- 📊 DATOS DE PRUEBA
-- ============================================
/*
🎯 SERVICIO CREADO:
- Nombre: Servicio de Prueba - Booking
- Precio: $25 - $50 por hora
- Disponibilidad: 
  * Lunes a Viernes: 8:00 AM - 6:00 PM (10 horas diarias)
  * Sábado: 9:00 AM - 2:00 PM (5 horas)
- Slots disponibles: Cada 1 hora (configurable en la app)

🔍 CÓMO PROBARLO:
1. Ejecuta este SQL en Supabase
2. Ve a la sección "Comunidad" en tu app
3. Filtra por "Servicios"
4. Busca "Servicio de Prueba - Booking"
5. Presiona el botón "Reservar"
6. Selecciona un día de Lunes a Sábado
7. Verás todos los horarios disponibles
8. Completa la reserva

📅 EJEMPLO DE SLOTS:
- Para 1 hora de duración:
  * 08:00, 09:00, 10:00, 11:00, 12:00, 13:00, 14:00, 15:00, 16:00, 17:00
- Para 2 horas de duración:
  * 08:00, 10:00, 12:00, 14:00, 16:00
*/

-- ============================================
-- 🧹 OPCIONAL: Eliminar servicio de prueba
-- ============================================
/*
-- Descomentar para eliminar el servicio de prueba:

DELETE FROM service_availability WHERE service_id = '12345678-1234-1234-1234-123456789abc'::UUID;
DELETE FROM service_bookings WHERE service_id = '12345678-1234-1234-1234-123456789abc'::UUID;
DELETE FROM posts WHERE id = 'a1234567-1234-1234-1234-123456789abc';
DELETE FROM services WHERE id = '12345678-1234-1234-1234-123456789abc'::UUID;
*/
