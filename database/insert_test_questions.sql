-- ============================================
-- INSERTAR PREGUNTAS DE PRUEBA
-- Para ver los CTA interactivos en la página de Preguntas
-- ============================================

-- Primero, obtener el ID de un usuario existente
-- (Reemplaza este ID con el ID de tu usuario en Supabase)
DO $$
DECLARE
  test_user_id UUID;
BEGIN
  -- Obtener el primer usuario que exista
  SELECT id INTO test_user_id FROM users LIMIT 1;
  
  -- Si no hay usuarios, crear uno de prueba
  IF test_user_id IS NULL THEN
    INSERT INTO users (email, username, name, account_type)
    VALUES ('test@yominero.com', 'test_user', 'Usuario de Prueba', 'individual')
    RETURNING id INTO test_user_id;
  END IF;
  
  -- Insertar 5 preguntas de prueba
  INSERT INTO posts (author_id, type, title, content, tags, categories, required_tags, budget_amount, budget_currency, deadline) VALUES
  
  -- Pregunta 1: Técnica urgente
  (test_user_id, 
   'request', 
   '¿Cuál es el mejor equipo para minería a pequeña escala?',
   'Estoy iniciando operaciones mineras en una concesión pequeña. Necesito asesoría sobre qué equipos básicos adquirir. Presupuesto limitado pero quiero calidad. ¿Alguien con experiencia que pueda orientarme?',
   ARRAY['mineria', 'equipos', 'pequeña-escala', 'asesoría'],
   ARRAY['Equipos', 'Técnico', 'Urgente'],
   ARRAY['experiencia-minera', 'conocimiento-equipos'],
   5000.00,
   'USD',
   NOW() + INTERVAL '7 days'
  ),
  
  -- Pregunta 2: Legal
  (test_user_id,
   'request',
   'Documentación para permisos ambientales en minería',
   'Necesito conocer qué documentos exactos se requieren para tramitar permisos ambientales en Perú. He leído varias fuentes pero necesito confirmación de alguien que haya pasado por el proceso recientemente.',
   ARRAY['legal', 'permisos', 'medio-ambiente', 'documentación'],
   ARRAY['Legal', 'Medio Ambiente', 'Importante'],
   ARRAY['experiencia-legal', 'permisos-recientes'],
   800.00,
   'USD',
   NOW() + INTERVAL '14 days'
  ),
  
  -- Pregunta 3: Seguridad
  (test_user_id,
   'request',
   '¿Qué protocolos de seguridad son esenciales en minas subterráneas?',
   'Vamos a profundizar nuestra operación y necesito implementar protocolos de seguridad adecuados. ¿Cuáles son los más críticos? ¿Experiencias reales de accidentes que se pudieron prevenir?',
   ARRAY['seguridad', 'minas-subterraneas', 'protocolos', 'prevención'],
   ARRAY['Seguridad', 'Técnico', 'Urgente'],
   ARRAY['experiencia-seguridad', 'minas-profundas'],
   1200.00,
   'USD',
   NOW() + INTERVAL '5 days'
  ),
  
  -- Pregunta 4: Geología
  (test_user_id,
   'request',
   'Interpretación de muestras de exploración - ¿Ven potencial aquí?',
   'Tengo resultados de análisis de muestras con 3.2 g/t Au y 45 g/t Ag en vetas de cuarzo. La zona tiene alteración hidrotermal visible. ¿Vale la pena continuar la exploración? Busco opinión de geólogos experimentados.',
   ARRAY['geología', 'exploración', 'muestras', 'oro', 'plata'],
   ARRAY['Geología', 'Exploración', 'Consulta'],
   ARRAY['geólogo-certificado', 'experiencia-exploración'],
   2500.00,
   'USD',
   NOW() + INTERVAL '10 days'
  ),
  
  -- Pregunta 5: Procesamiento
  (test_user_id,
   'request',
   '¿Flotación o cianuración para mineral polimetálico?',
   'Tenemos mineral con Cu, Pb, Zn y valores de Au. ¿Qué proceso recomiendan? Nuestra planta actual es pequeña (50 ton/día). ¿Experiencias con minerales similares? ¿Costos aproximados?',
   ARRAY['procesamiento', 'metalurgia', 'flotación', 'cianuración', 'polimetálico'],
   ARRAY['Procesamiento', 'Metalurgia', 'Técnico'],
   ARRAY['experiencia-procesamiento', 'metalurgista'],
   3500.00,
   'USD',
   NOW() + INTERVAL '12 days'
  );
  
  RAISE NOTICE 'Se insertaron 5 preguntas de prueba correctamente';
  
END $$;
