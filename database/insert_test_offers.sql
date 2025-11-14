-- ══════════════════════════════════════════════════════════════
-- Script: Insertar ofertas de prueba para YoMinero
-- Propósito: Ofertas de servicios mineros con precios
-- Ejecutar en: Dashboard de Supabase → SQL Editor
-- ══════════════════════════════════════════════════════════════

-- Oferta 1: Mantenimiento de equipos pesados
INSERT INTO posts (
  id,
  author_id,
  title,
  content,
  type,
  tags,
  categories,
  metadata,
  likes_count,
  created_at
) VALUES (
  gen_random_uuid(),
  (SELECT id FROM users LIMIT 1),
  'Mantenimiento Preventivo y Correctivo de Equipos Pesados',
  'Ofrecemos servicios especializados de mantenimiento para maquinaria minera: excavadoras, camiones de alto tonelaje, cargadores frontales y perforadoras. Equipo certificado con más de 15 años de experiencia. Garantía de 6 meses en todas las reparaciones.',
  'offer',
  ARRAY['mantenimiento', 'equipos pesados', 'maquinaria'],
  ARRAY['servicios', 'mantenimiento'],
  jsonb_build_object(
    'service_name', 'Mantenimiento de Maquinaria Pesada',
    'service_tags', ARRAY['certificado', 'garantía', 'urgencias 24/7'],
    'pricing_from', 1500,
    'pricing_to', 5000,
    'pricing_unit', 'USD/servicio',
    'availability', 'Disponible'
  ),
  45,
  NOW() - INTERVAL '2 days'
);

-- Oferta 2: Análisis geológico
INSERT INTO posts (
  id,
  author_id,
  title,
  content,
  type,
  tags,
  categories,
  metadata,
  likes_count,
  created_at
) VALUES (
  gen_random_uuid(),
  (SELECT id FROM users LIMIT 1),
  'Estudios Geológicos y Análisis de Muestras',
  'Laboratorio certificado ISO 9001 ofrece análisis completo de muestras minerales: composición química, ley de mineral, estudios de viabilidad. Resultados en 48-72 horas. Incluye informe técnico detallado.',
  'offer',
  ARRAY['geología', 'análisis', 'laboratorio'],
  ARRAY['servicios', 'geología'],
  jsonb_build_object(
    'service_name', 'Análisis Geológico Profesional',
    'service_tags', ARRAY['ISO 9001', 'resultados rápidos', 'informe técnico'],
    'pricing_from', 200,
    'pricing_to', 800,
    'pricing_unit', 'USD/muestra',
    'availability', 'Disponible'
  ),
  67,
  NOW() - INTERVAL '5 hours'
);

-- Oferta 3: Consultoría en seguridad minera
INSERT INTO posts (
  id,
  author_id,
  title,
  content,
  type,
  tags,
  categories,
  metadata,
  likes_count,
  created_at
) VALUES (
  gen_random_uuid(),
  (SELECT id FROM users LIMIT 1),
  'Asesoría en Seguridad y Prevención de Riesgos Mineros',
  'Consultores especializados en seguridad minera ofrecen: auditorías de seguridad, capacitación de personal, elaboración de protocolos, cumplimiento normativo. Más de 100 faenas asesoradas exitosamente.',
  'offer',
  ARRAY['seguridad', 'prevención', 'capacitación'],
  ARRAY['servicios', 'seguridad'],
  jsonb_build_object(
    'service_name', 'Consultoría en Seguridad Minera',
    'service_tags', ARRAY['certificados', 'experiencia comprobada', 'cumplimiento normativo'],
    'pricing_from', 3000,
    'pricing_to', 15000,
    'pricing_unit', 'USD/proyecto',
    'availability', 'Consultar disponibilidad'
  ),
  89,
  NOW() - INTERVAL '1 day'
);

-- Oferta 4: Alquiler de equipos
INSERT INTO posts (
  id,
  author_id,
  title,
  content,
  type,
  tags,
  categories,
  metadata,
  likes_count,
  created_at
) VALUES (
  gen_random_uuid(),
  (SELECT id FROM users LIMIT 1),
  'Arriendo de Maquinaria Pesada con Operador',
  'Flota completa de equipos pesados disponibles: excavadoras, bulldozers, cargadores, camiones tolva. Incluye operador certificado, combustible y mantenimiento. Contratos flexibles desde 1 semana.',
  'offer',
  ARRAY['arriendo', 'equipos', 'operador incluido'],
  ARRAY['servicios', 'arriendo'],
  jsonb_build_object(
    'service_name', 'Arriendo de Maquinaria con Operador',
    'service_tags', ARRAY['operador certificado', 'combustible incluido', 'contratos flexibles'],
    'pricing_from', 800,
    'pricing_to', 2500,
    'pricing_unit', 'USD/día',
    'availability', 'Disponible'
  ),
  123,
  NOW() - INTERVAL '8 hours'
);

-- Oferta 5: Topografía con drones
INSERT INTO posts (
  id,
  author_id,
  title,
  content,
  type,
  tags,
  categories,
  metadata,
  likes_count,
  created_at
) VALUES (
  gen_random_uuid(),
  (SELECT id FROM users LIMIT 1),
  'Levantamiento Topográfico con Tecnología Drone',
  'Servicios de topografía usando drones de última generación. Mapeo 3D, cálculo de volúmenes, monitoreo de taludes. Entrega de planos georeferenciados y modelos digitales. Precisión submétrica.',
  'offer',
  ARRAY['topografía', 'drones', 'mapeo 3D'],
  ARRAY['servicios', 'tecnología'],
  jsonb_build_object(
    'service_name', 'Topografía con Drones',
    'service_tags', ARRAY['tecnología avanzada', 'precisión submétrica', 'entrega rápida'],
    'pricing_from', 500,
    'pricing_to', 3000,
    'pricing_unit', 'USD/hectárea',
    'availability', 'Disponible'
  ),
  156,
  NOW() - INTERVAL '3 days'
);

-- Oferta 6: Suministro de EPP
INSERT INTO posts (
  id,
  author_id,
  title,
  content,
  type,
  tags,
  categories,
  metadata,
  likes_count,
  created_at
) VALUES (
  gen_random_uuid(),
  (SELECT id FROM users LIMIT 1),
  'Venta de Equipos de Protección Personal (EPP) Certificados',
  'Distribuidores oficiales de EPP de las mejores marcas. Cascos, arneses, guantes, protección respiratoria, calzado de seguridad. Todos los productos certificados. Descuentos por volumen. Despacho a faena.',
  'offer',
  ARRAY['EPP', 'seguridad', 'equipos certificados'],
  ARRAY['productos', 'seguridad'],
  jsonb_build_object(
    'service_name', 'Suministro de EPP Certificado',
    'service_tags', ARRAY['marcas reconocidas', 'certificación vigente', 'descuentos por volumen'],
    'pricing_from', 50,
    'pricing_to', 500,
    'pricing_unit', 'USD/unidad',
    'availability', 'Disponible'
  ),
  201,
  NOW() - INTERVAL '12 hours'
);

-- ══════════════════════════════════════════════════════════════
-- VERIFICACIÓN
-- ══════════════════════════════════════════════════════════════

SELECT 
  COUNT(*) as total_ofertas,
  ROUND(AVG(likes_count), 0) as promedio_likes
FROM posts 
WHERE type = 'offer';

-- Listar ofertas con precios
SELECT 
  title,
  metadata->>'service_name' as servicio,
  metadata->>'pricing_from' as precio_desde,
  metadata->>'pricing_to' as precio_hasta,
  metadata->>'pricing_unit' as unidad,
  metadata->>'availability' as disponibilidad,
  likes_count,
  created_at
FROM posts 
WHERE type = 'offer'
ORDER BY created_at DESC;
