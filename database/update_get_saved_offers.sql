-- Actualizar función get_saved_offers para incluir service_id
-- Esto permite saber directamente si una oferta guardada tiene sistema de reservas

-- IMPORTANTE: Primero eliminar la función existente porque cambiamos el RETURN TYPE
DROP FUNCTION IF EXISTS get_saved_offers(uuid);

CREATE OR REPLACE FUNCTION get_saved_offers(user_id_param uuid)
RETURNS TABLE (
  post_id uuid,
  service_name text,
  service_id uuid,
  title text,
  content text,
  pricing_from numeric,
  pricing_to numeric,
  pricing_unit text,
  availability text,
  author_id uuid,
  author_name text,
  author_username text,
  likes_count bigint,
  saved_at timestamptz
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id as post_id,
    p.service_name,
    p.service_id,
    p.title,
    p.content,
    p.pricing_from,
    p.pricing_to,
    p.pricing_unit,
    p.availability,
    u.id as author_id,
    u.name as author_name,
    u.username as author_username,
    COALESCE((SELECT COUNT(*) FROM post_likes pl WHERE pl.post_id = p.id), 0) as likes_count,
    so.saved_at
  FROM saved_offers so
  JOIN posts p ON p.id = so.post_id
  JOIN users u ON u.id = p.author_id
  WHERE so.user_id = user_id_param
  ORDER BY so.saved_at DESC;
END;
$$;

-- Dar permisos
GRANT EXECUTE ON FUNCTION get_saved_offers(uuid) TO authenticated;

-- Test
SELECT * FROM get_saved_offers('5f4fb2fa-c52a-4aa7-949a-5ff1caa61dd0') LIMIT 5;
