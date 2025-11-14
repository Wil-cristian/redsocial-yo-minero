-- ══════════════════════════════════════════════════════════════
-- Script: Insertar noticias de prueba para YoMinero
-- Propósito: Datos realistas del sector minero para testing
-- Ejecutar en: Dashboard de Supabase → SQL Editor
-- ══════════════════════════════════════════════════════════════

-- Verificar posts existentes de tipo 'news'
SELECT COUNT(*) as total_noticias FROM posts WHERE type = 'news';

-- ══════════════════════════════════════════════════════════════
-- INSERTAR 6 NOTICIAS DEL SECTOR MINERO
-- ══════════════════════════════════════════════════════════════

-- Noticia 1: Precio del cobre alcanza máximos históricos
INSERT INTO posts (
  id,
  author_id,
  title,
  content,
  type,
  tags,
  categories,
  news_source,
  news_author,
  news_cover_image,
  likes,
  comments,
  created_at
) VALUES (
  gen_random_uuid(),
  (SELECT id FROM users LIMIT 1), -- Usuario existente de tabla users
  'Precio del cobre supera los $4.50 por libra: máximo en 2 años',
  'El precio del cobre en la Bolsa de Metales de Londres (LME) alcanzó los $4.52 por libra, el nivel más alto desde marzo de 2022. Los analistas atribuyen este incremento a la fuerte demanda de China y la reducción de inventarios globales. Las principales mineras chilenas y peruanas proyectan incrementos en su producción para aprovechar los buenos precios.

Los expertos predicen que los precios se mantendrán por encima de $4.20 durante el próximo trimestre, lo que representa una excelente oportunidad para los productores medianos y pequeños que han invertido en mejorar sus operaciones.',
  'news',
  ARRAY['cobre', 'precios', 'mercados', 'exportación'],
  ARRAY['economía', 'mercados'],
  'Mining News International',
  'Carlos Mendoza',
  'https://images.unsplash.com/photo-1611273426858-450d8e3c9fce',
  47,
  12,
  NOW() - INTERVAL '2 hours'
);

-- Noticia 2: Nueva tecnología de extracción sustentable
INSERT INTO posts (
  id,
  author_id,
  title,
  content,
  type,
  tags,
  categories,
  news_source,
  news_author,
  news_cover_image,
  likes,
  comments,
  created_at
) VALUES (
  gen_random_uuid(),
  (SELECT id FROM users LIMIT 1),
  'Startup chilena desarrolla tecnología para reducir 60% el consumo de agua en minería',
  'La empresa chilena AquaMining presentó su nueva tecnología de recirculación de agua que promete revolucionar la industria minera. El sistema, probado exitosamente en 3 operaciones piloto, reduce el consumo de agua dulce en un 60% mediante un proceso de filtración avanzada y reutilización inteligente.

La tecnología ha captado la atención de grandes mineras que buscan cumplir con estándares ambientales cada vez más estrictos. El sistema es modular y puede adaptarse tanto a operaciones grandes como medianas, con un retorno de inversión estimado de 18 meses.',
  'news',
  ARRAY['innovación', 'sustentabilidad', 'agua', 'tecnología'],
  ARRAY['tecnología', 'medio ambiente'],
  'Innovación Minera',
  'María González',
  'https://images.unsplash.com/photo-1581092918056-0c4c3acd3789',
  89,
  23,
  NOW() - INTERVAL '5 hours'
);

-- Noticia 3: Regulaciones ambientales más estrictas
INSERT INTO posts (
  id,
  author_id,
  title,
  content,
  type,
  tags,
  categories,
  news_source,
  news_author,
  news_cover_image,
  likes,
  comments,
  created_at
) VALUES (
  gen_random_uuid(),
  (SELECT id FROM users LIMIT 1),
  'Nuevas regulaciones ambientales entran en vigor en enero 2026',
  'El Ministerio de Medio Ambiente anunció que a partir de enero de 2026 entrarán en vigor nuevas regulaciones para el sector minero. Los principales cambios incluyen:

• Reducción obligatoria del 40% en emisiones de material particulado
• Monitoreo en tiempo real de calidad del agua en zonas aledañas
• Planes de cierre de faena con garantías financieras ampliadas
• Auditorías ambientales trimestrales independientes

Las empresas tendrán 6 meses para adecuar sus operaciones. Se ofrecerán subsidios del 30% para inversiones en tecnología limpia que faciliten el cumplimiento.',
  'news',
  ARRAY['regulaciones', 'medio ambiente', 'cumplimiento', 'legal'],
  ARRAY['normativa', 'medio ambiente'],
  'Diario Minero',
  'Roberto Fuentes',
  'https://images.unsplash.com/photo-1589939705384-5185137a7f0f',
  134,
  45,
  NOW() - INTERVAL '1 day'
);

-- Noticia 4: Descubrimiento de yacimiento de litio
INSERT INTO posts (
  id,
  author_id,
  title,
  content,
  type,
  tags,
  categories,
  news_source,
  news_author,
  news_cover_image,
  likes,
  comments,
  created_at
) VALUES (
  gen_random_uuid(),
  (SELECT id FROM users LIMIT 1),
  'Descubren yacimiento de litio de alta ley en región de Atacama',
  'Un equipo de geólogos de la empresa Lithium Explorers confirmó el hallazgo de un depósito de litio con concentraciones superiores a 1,200 ppm en la región de Atacama. Las estimaciones preliminares sugieren reservas de más de 2 millones de toneladas métricas.

Este descubrimiento es especialmente relevante en el contexto de la creciente demanda global de litio para baterías de vehículos eléctricos. La empresa planea iniciar estudios de factibilidad económica en el segundo trimestre de 2025, con potencial inicio de operaciones en 2027.

El proyecto generaría aproximadamente 800 empleos directos durante la fase de construcción y 300 permanentes durante la operación.',
  'news',
  ARRAY['litio', 'exploración', 'yacimiento', 'atacama'],
  ARRAY['exploración', 'economía'],
  'Minería y Energía',
  'Andrea Soto',
  'https://images.unsplash.com/photo-1559827260-dc66d52bef19',
  201,
  67,
  NOW() - INTERVAL '3 days'
);

-- Noticia 5: Inversión en capacitación de personal
INSERT INTO posts (
  id,
  author_id,
  title,
  content,
  type,
  tags,
  categories,
  news_source,
  news_author,
  news_cover_image,
  likes,
  comments,
  created_at
) VALUES (
  gen_random_uuid(),
  (SELECT id FROM users LIMIT 1),
  'Sector minero anuncia programa de capacitación en minería 4.0',
  'La Asociación de Empresas Mineras lanzó un programa nacional de capacitación en tecnologías de minería 4.0, con una inversión de $15 millones. El programa incluye:

📚 Cursos en automatización y robótica aplicada
🤖 Capacitación en análisis de datos y machine learning
🚁 Certificación en operación de drones para prospección
💻 Formación en gemelos digitales y simulación de procesos

El programa está dirigido a trabajadores activos del sector que deseen actualizar sus competencias. Se ofrecerán 5,000 cupos con prioridad para técnicos y operadores de equipos. Las inscripciones abren el 1 de diciembre.',
  'news',
  ARRAY['capacitación', 'tecnología', 'empleos', 'minería 4.0'],
  ARRAY['educación', 'tecnología'],
  'Formación Minera',
  'Luis Ramírez',
  'https://images.unsplash.com/photo-1552664730-d307ca884978',
  156,
  38,
  NOW() - INTERVAL '12 hours'
);

-- Noticia 6: Acuerdo comercial beneficia exportaciones
INSERT INTO posts (
  id,
  author_id,
  title,
  content,
  type,
  tags,
  categories,
  news_source,
  news_author,
  news_cover_image,
  likes,
  comments,
  created_at
) VALUES (
  gen_random_uuid(),
  (SELECT id FROM users LIMIT 1),
  'Nuevo acuerdo comercial con Asia reduce aranceles en 35% para minerales',
  'Los gobiernos de Chile, Perú y Bolivia firmaron un acuerdo comercial conjunto con países del sudeste asiático que reducirá los aranceles de exportación de minerales estratégicos en un 35%. El acuerdo beneficia principalmente a:

✓ Cobre y concentrados de cobre (-40% aranceles)
✓ Litio y sales de litio (-35% aranceles)
✓ Oro y plata refinados (-30% aranceles)
✓ Zinc y plomo (-35% aranceles)

El acuerdo entrará en vigor gradualmente a partir de abril 2025. Los analistas estiman que esto aumentará las exportaciones regionales en un 22% durante el primer año, beneficiando especialmente a productores medianos que podrán competir mejor en mercados asiáticos.

Las cámaras mineras regionales celebraron el acuerdo como un hito histórico para la integración comercial del sector.',
  'news',
  ARRAY['comercio', 'exportaciones', 'aranceles', 'asia'],
  ARRAY['economía', 'internacional'],
  'Comercio Exterior Minero',
  'Patricia Morales',
  'https://images.unsplash.com/photo-1526304640581-d334cdbbf45e',
  243,
  78,
  NOW() - INTERVAL '6 hours'
);

-- ══════════════════════════════════════════════════════════════
-- VERIFICACIÓN: Contar noticias insertadas
-- ══════════════════════════════════════════════════════════════

SELECT 
  COUNT(*) as total_noticias,
  ROUND(AVG(likes), 0) as promedio_likes,
  ROUND(AVG(comments), 0) as promedio_comentarios
FROM posts 
WHERE type = 'news';

-- Listar las noticias con su información básica
SELECT 
  title,
  news_source,
  news_author,
  likes,
  comments,
  created_at
FROM posts 
WHERE type = 'news'
ORDER BY created_at DESC;
