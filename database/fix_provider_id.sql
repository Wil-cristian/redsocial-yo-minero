-- ============================================
-- 🔧 Actualizar provider_id de TODOS los servicios
-- ============================================

-- Actualizar servicios para que coincidan con el author_id de sus posts
UPDATE services s
SET provider_id = p.author_id
FROM posts p
WHERE p.service_id = s.id
AND s.provider_id IS NULL;

-- Verificar todos los servicios actualizados
SELECT s.id, s.name, s.provider_id, u.name as provider_name, p.id as post_id
FROM services s
LEFT JOIN users u ON u.id = s.provider_id
LEFT JOIN posts p ON p.service_id = s.id
ORDER BY s.created_at DESC;

-- Si algún servicio aún no tiene provider_id, asignar usuarios disponibles alternadamente
DO $$
DECLARE
  service_record RECORD;
  user_ids UUID[];
  user_index INTEGER := 0;
BEGIN
  -- Obtener lista de usuarios
  SELECT ARRAY_AGG(id) INTO user_ids FROM users;
  
  -- Actualizar servicios sin provider_id
  FOR service_record IN 
    SELECT id FROM services WHERE provider_id IS NULL
  LOOP
    UPDATE services 
    SET provider_id = user_ids[(user_index % array_length(user_ids, 1)) + 1]
    WHERE id = service_record.id;
    
    user_index := user_index + 1;
  END LOOP;
END $$;

-- Verificación final
SELECT id, name, provider_id FROM services;
