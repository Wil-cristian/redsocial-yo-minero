-- ============================================
-- ESQUEMA DE BASE DE DATOS PARA YOMINERO
-- Copiar y pegar en Supabase SQL Editor
-- ============================================

-- Habilitar extensión para UUIDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLA: users
-- Usuario principal del sistema (individual, empresa, trabajador)
-- ============================================
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  username TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  account_type TEXT NOT NULL CHECK (account_type IN ('individual', 'company', 'worker')),
  
  -- Información de organización (para companies y workers)
  organization_info JSONB DEFAULT '{}'::jsonb,
  
  -- Seguridad
  must_change_password BOOLEAN DEFAULT false,
  
  -- Perfil
  bio TEXT DEFAULT '',
  profile_image_url TEXT,
  is_verified BOOLEAN DEFAULT false,
  
  -- Métricas sociales
  followers_count INTEGER DEFAULT 0,
  following_count INTEGER DEFAULT 0,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para búsquedas rápidas
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_account_type ON users(account_type);

-- ============================================
-- TABLA: employee_roles
-- Roles predefinidos para empleados
-- ============================================
CREATE TABLE employee_roles (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  permissions TEXT[] NOT NULL DEFAULT '{}',
  color TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insertar los 8 roles predefinidos
INSERT INTO employee_roles (id, name, description, permissions, color) VALUES
('ceo', 'CEO / Director General', 'Acceso completo a todas las funciones', 
 ARRAY['view_all', 'edit_all', 'manage_employees', 'manage_projects', 'view_metrics', 'manage_resources', 'approve_purchases', 'manage_finances'], 
 '#1E3A8A'),
 
('operations', 'Gerente de Operaciones', 'Gestión de proyectos y recursos',
 ARRAY['manage_projects', 'manage_resources', 'view_metrics', 'assign_tasks'],
 '#7C3AED'),
 
('finance', 'Contador / Finanzas', 'Gestión financiera y reportes',
 ARRAY['view_metrics', 'manage_finances', 'approve_purchases', 'view_projects'],
 '#059669'),
 
('hr', 'Recursos Humanos', 'Gestión de personal',
 ARRAY['manage_employees', 'view_metrics'],
 '#DC2626'),
 
('sales', 'Gerente de Ventas', 'Gestión de ventas y clientes',
 ARRAY['manage_products', 'manage_services', 'view_metrics'],
 '#EA580C'),
 
('supervisor', 'Supervisor de Proyecto', 'Supervisión de proyectos específicos',
 ARRAY['view_projects', 'assign_tasks', 'manage_resources'],
 '#0891B2'),
 
('technician', 'Técnico / Operario', 'Ejecución de tareas asignadas',
 ARRAY['view_own_tasks', 'report_progress'],
 '#4B5563'),
 
('administrative', 'Administrativo', 'Soporte administrativo general',
 ARRAY['view_projects', 'manage_documents'],
 '#8B5CF6');

-- ============================================
-- TABLA: posts
-- Publicaciones (comunidad, solicitudes, ofertas)
-- ============================================
CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  author_id UUID REFERENCES users(id) ON DELETE CASCADE,
  
  -- Tipo de post
  type TEXT NOT NULL DEFAULT 'community' CHECK (type IN ('community', 'request', 'offer')),
  
  -- Contenido
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  tags TEXT[] DEFAULT '{}',
  categories TEXT[] DEFAULT '{}',
  
  -- Para solicitudes (requests)
  required_tags TEXT[] DEFAULT '{}',
  budget_amount DECIMAL(10, 2),
  budget_currency TEXT DEFAULT 'USD',
  deadline TIMESTAMP WITH TIME ZONE,
  
  -- Para ofertas (offers)
  service_name TEXT,
  service_tags TEXT[] DEFAULT '{}',
  pricing_from DECIMAL(10, 2),
  pricing_to DECIMAL(10, 2),
  pricing_unit TEXT,
  availability TEXT,
  
  -- Métricas
  likes INTEGER DEFAULT 0,
  comments_count INTEGER DEFAULT 0,
  views_count INTEGER DEFAULT 0,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_posts_author ON posts(author_id);
CREATE INDEX idx_posts_type ON posts(type);
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);
CREATE INDEX idx_posts_tags ON posts USING GIN(tags);

-- ============================================
-- TABLA: post_likes
-- Registro de likes en posts
-- ============================================
CREATE TABLE post_likes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  UNIQUE(post_id, user_id) -- Un usuario solo puede dar like una vez por post
);

CREATE INDEX idx_post_likes_post ON post_likes(post_id);
CREATE INDEX idx_post_likes_user ON post_likes(user_id);

-- ============================================
-- TABLA: products
-- Productos en venta
-- ============================================
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  seller_id UUID REFERENCES users(id) ON DELETE CASCADE,
  
  -- Información del producto
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  category TEXT NOT NULL,
  
  -- Precio
  price DECIMAL(10, 2) NOT NULL,
  currency TEXT DEFAULT 'USD',
  
  -- Inventario
  stock INTEGER DEFAULT 0,
  is_available BOOLEAN DEFAULT true,
  
  -- Imágenes
  image_urls TEXT[] DEFAULT '{}',
  
  -- Métricas
  views_count INTEGER DEFAULT 0,
  favorites_count INTEGER DEFAULT 0,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_products_seller ON products(seller_id);
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_is_available ON products(is_available);

-- ============================================
-- TABLA: services
-- Servicios ofrecidos
-- ============================================
CREATE TABLE services (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  provider_id UUID REFERENCES users(id) ON DELETE CASCADE,
  
  -- Información del servicio
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  category TEXT NOT NULL,
  tags TEXT[] DEFAULT '{}',
  
  -- Pricing
  pricing_from DECIMAL(10, 2),
  pricing_to DECIMAL(10, 2),
  pricing_unit TEXT,
  
  -- Disponibilidad
  availability TEXT,
  is_available BOOLEAN DEFAULT true,
  
  -- Imágenes
  image_urls TEXT[] DEFAULT '{}',
  
  -- Métricas
  views_count INTEGER DEFAULT 0,
  requests_count INTEGER DEFAULT 0,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_services_provider ON services(provider_id);
CREATE INDEX idx_services_category ON services(category);
CREATE INDEX idx_services_tags ON services USING GIN(tags);

-- ============================================
-- TABLA: groups
-- Grupos de usuarios con intereses comunes
-- ============================================
CREATE TABLE groups (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  creator_id UUID REFERENCES users(id) ON DELETE SET NULL,
  
  -- Información del grupo
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  keywords TEXT[] DEFAULT '{}',
  interests TEXT[] DEFAULT '{}',
  
  -- Configuración
  is_private BOOLEAN DEFAULT false,
  max_members INTEGER,
  
  -- Métricas
  members_count INTEGER DEFAULT 0,
  posts_count INTEGER DEFAULT 0,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_groups_creator ON groups(creator_id);
CREATE INDEX idx_groups_keywords ON groups USING GIN(keywords);

-- ============================================
-- TABLA: group_members
-- Relación muchos-a-muchos entre usuarios y grupos
-- ============================================
CREATE TABLE group_members (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  group_id UUID REFERENCES groups(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  role TEXT DEFAULT 'member' CHECK (role IN ('admin', 'moderator', 'member')),
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  UNIQUE(group_id, user_id)
);

CREATE INDEX idx_group_members_group ON group_members(group_id);
CREATE INDEX idx_group_members_user ON group_members(user_id);

-- ============================================
-- FUNCIONES Y TRIGGERS
-- ============================================

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger a todas las tablas con updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_posts_updated_at BEFORE UPDATE ON posts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_services_updated_at BEFORE UPDATE ON services
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_groups_updated_at BEFORE UPDATE ON groups
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Función para incrementar likes count en posts
CREATE OR REPLACE FUNCTION increment_post_likes()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE posts SET likes = likes + 1 WHERE id = NEW.post_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER post_liked AFTER INSERT ON post_likes
  FOR EACH ROW EXECUTE FUNCTION increment_post_likes();

-- Función para decrementar likes count en posts
CREATE OR REPLACE FUNCTION decrement_post_likes()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE posts SET likes = likes - 1 WHERE id = OLD.post_id;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER post_unliked AFTER DELETE ON post_likes
  FOR EACH ROW EXECUTE FUNCTION decrement_post_likes();

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

-- Habilitar RLS en todas las tablas
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE services ENABLE ROW LEVEL SECURITY;
ALTER TABLE groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE group_members ENABLE ROW LEVEL SECURITY;

-- Políticas para USERS
-- Los usuarios pueden ver todos los perfiles públicos
CREATE POLICY "Public profiles are viewable by everyone" ON users
  FOR SELECT USING (true);

-- Los usuarios pueden crear su propio perfil durante el registro
CREATE POLICY "Users can insert their own profile" ON users
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Los usuarios pueden actualizar su propio perfil
CREATE POLICY "Users can update their own profile" ON users
  FOR UPDATE USING (auth.uid() = id);

-- Políticas para POSTS
-- Todos pueden ver posts públicos
CREATE POLICY "Posts are viewable by everyone" ON posts
  FOR SELECT USING (true);

-- Usuarios autenticados pueden crear posts
CREATE POLICY "Authenticated users can create posts" ON posts
  FOR INSERT WITH CHECK (auth.uid() = author_id);

-- Los autores pueden actualizar sus propios posts
CREATE POLICY "Authors can update their own posts" ON posts
  FOR UPDATE USING (auth.uid() = author_id);

-- Los autores pueden eliminar sus propios posts
CREATE POLICY "Authors can delete their own posts" ON posts
  FOR DELETE USING (auth.uid() = author_id);

-- Políticas para POST_LIKES
CREATE POLICY "Anyone can view likes" ON post_likes
  FOR SELECT USING (true);

CREATE POLICY "Users can like posts" ON post_likes
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can unlike posts" ON post_likes
  FOR DELETE USING (auth.uid() = user_id);

-- Políticas para PRODUCTS
CREATE POLICY "Products are viewable by everyone" ON products
  FOR SELECT USING (true);

CREATE POLICY "Sellers can create products" ON products
  FOR INSERT WITH CHECK (auth.uid() = seller_id);

CREATE POLICY "Sellers can update their products" ON products
  FOR UPDATE USING (auth.uid() = seller_id);

CREATE POLICY "Sellers can delete their products" ON products
  FOR DELETE USING (auth.uid() = seller_id);

-- Políticas para SERVICES
CREATE POLICY "Services are viewable by everyone" ON services
  FOR SELECT USING (true);

CREATE POLICY "Providers can create services" ON services
  FOR INSERT WITH CHECK (auth.uid() = provider_id);

CREATE POLICY "Providers can update their services" ON services
  FOR UPDATE USING (auth.uid() = provider_id);

CREATE POLICY "Providers can delete their services" ON services
  FOR DELETE USING (auth.uid() = provider_id);

-- Políticas para GROUPS
CREATE POLICY "Public groups are viewable by everyone" ON groups
  FOR SELECT USING (NOT is_private OR creator_id = auth.uid());

CREATE POLICY "Authenticated users can create groups" ON groups
  FOR INSERT WITH CHECK (auth.uid() = creator_id);

CREATE POLICY "Creators can update their groups" ON groups
  FOR UPDATE USING (auth.uid() = creator_id);

CREATE POLICY "Creators can delete their groups" ON groups
  FOR DELETE USING (auth.uid() = creator_id);

-- Políticas para GROUP_MEMBERS
CREATE POLICY "Group members are viewable by everyone" ON group_members
  FOR SELECT USING (true);

CREATE POLICY "Users can join groups" ON group_members
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can leave groups" ON group_members
  FOR DELETE USING (auth.uid() = user_id);

-- ============================================
-- DATOS DE PRUEBA (OPCIONAL)
-- Descomenta para insertar usuarios de prueba
-- ============================================

-- Nota: Las contraseñas se manejarán con Supabase Auth
-- Estos son solo registros en la tabla users

/*
INSERT INTO users (id, email, username, name, account_type, organization_info, is_verified) VALUES
('00000000-0000-0000-0000-000000000001', 'empresa@test.com', 'minera_test', 'Minera Test S.A.', 'company', 
 '{"companyName": "Minera Test S.A.", "companyRole": "owner"}'::jsonb, true),

('00000000-0000-0000-0000-000000000002', 'maria.gerente@test.com', 'maria_gerente', 'María Gerente', 'worker',
 '{"companyId": "00000000-0000-0000-0000-000000000001", "companyName": "Minera Test S.A.", "roleId": "ceo", "department": "Gerencia General", "companyRole": "employee"}'::jsonb, true),

('00000000-0000-0000-0000-000000000003', 'carlos.tecnico@test.com', 'carlos_tecnico', 'Carlos Técnico', 'worker',
 '{"companyId": "00000000-0000-0000-0000-000000000001", "companyName": "Minera Test S.A.", "roleId": "technician", "department": "Operaciones - Zona Norte", "companyRole": "employee"}'::jsonb, false),

('00000000-0000-0000-0000-000000000004', 'juan@test.com', 'juan_minero', 'Juan Minero', 'individual',
 '{}'::jsonb, false);
*/

-- ============================================
-- FIN DEL ESQUEMA
-- ============================================
