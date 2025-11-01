-- ============================================
-- GRANT PERMISSIONS - Dar permisos directos a las tablas
-- Este es el problema real: falta GRANT a nivel de PostgreSQL
-- ============================================

-- Dar todos los permisos al rol 'authenticated' (usuarios logueados)
GRANT ALL ON TABLE posts TO authenticated;
GRANT ALL ON TABLE post_likes TO authenticated;
GRANT ALL ON TABLE users TO authenticated;
GRANT ALL ON TABLE products TO authenticated;
GRANT ALL ON TABLE services TO authenticated;
GRANT ALL ON TABLE groups TO authenticated;
GRANT ALL ON TABLE group_members TO authenticated;
GRANT ALL ON TABLE employee_roles TO authenticated;

-- Dar permisos al rol 'anon' (usuarios no autenticados) para leer
GRANT SELECT ON TABLE posts TO anon;
GRANT SELECT ON TABLE users TO anon;
GRANT SELECT ON TABLE products TO anon;
GRANT SELECT ON TABLE services TO anon;

-- Dar permisos a las SEQUENCES (para auto-increment si existen)
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon;

-- Verificar permisos
SELECT 
    grantee, 
    table_name, 
    privilege_type
FROM information_schema.role_table_grants 
WHERE table_schema = 'public' 
AND table_name IN ('posts', 'users', 'products')
AND grantee IN ('authenticated', 'anon')
ORDER BY table_name, grantee;
