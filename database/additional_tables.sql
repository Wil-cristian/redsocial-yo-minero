-- ============================================
-- TABLAS ADICIONALES PARA YOMINERO
-- Copiar y pegar en Supabase SQL Editor
-- ============================================

-- ============================================
-- TABLA: favorites
-- Sistema de favoritos para productos y servicios
-- ============================================
CREATE TABLE favorites (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  
  -- Puede ser favorito de producto O servicio
  product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  service_id UUID REFERENCES services(id) ON DELETE CASCADE,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Un usuario solo puede marcar un item una vez como favorito
  UNIQUE(user_id, product_id),
  UNIQUE(user_id, service_id),
  
  -- Debe tener product_id O service_id, pero no ambos
  CHECK (
    (product_id IS NOT NULL AND service_id IS NULL) OR
    (service_id IS NOT NULL AND product_id IS NULL)
  )
);

CREATE INDEX idx_favorites_user ON favorites(user_id);
CREATE INDEX idx_favorites_product ON favorites(product_id);
CREATE INDEX idx_favorites_service ON favorites(service_id);

-- ============================================
-- TABLA: conversations
-- Conversaciones entre usuarios
-- ============================================
CREATE TABLE conversations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  -- Participantes (2 usuarios en conversación directa)
  user1_id UUID REFERENCES users(id) ON DELETE CASCADE,
  user2_id UUID REFERENCES users(id) ON DELETE CASCADE,
  
  -- Metadatos
  last_message_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  unread_count_user1 INTEGER DEFAULT 0,
  unread_count_user2 INTEGER DEFAULT 0,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Una conversación única entre dos usuarios
  UNIQUE(user1_id, user2_id),
  
  -- user1_id debe ser menor que user2_id para evitar duplicados
  CHECK (user1_id < user2_id)
);

CREATE INDEX idx_conversations_user1 ON conversations(user1_id);
CREATE INDEX idx_conversations_user2 ON conversations(user2_id);
CREATE INDEX idx_conversations_last_message ON conversations(last_message_at DESC);

-- ============================================
-- TABLA: messages
-- Mensajes dentro de conversaciones
-- ============================================
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
  sender_id UUID REFERENCES users(id) ON DELETE CASCADE,
  
  -- Contenido
  content TEXT NOT NULL,
  message_type TEXT DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'file')),
  
  -- Metadatos
  is_read BOOLEAN DEFAULT false,
  read_at TIMESTAMP WITH TIME ZONE,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_messages_conversation ON messages(conversation_id);
CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_messages_created_at ON messages(created_at DESC);

-- ============================================
-- TABLA: projects
-- Proyectos de empresas (para métricas)
-- ============================================
CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_id UUID REFERENCES users(id) ON DELETE CASCADE,
  
  -- Información del proyecto
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  status TEXT DEFAULT 'in_progress' CHECK (status IN ('planning', 'in_progress', 'on_hold', 'completed', 'cancelled')),
  
  -- Progreso
  progress DECIMAL(5, 2) DEFAULT 0 CHECK (progress >= 0 AND progress <= 100),
  
  -- Presupuesto
  budget_amount DECIMAL(12, 2),
  budget_currency TEXT DEFAULT 'USD',
  
  -- Fechas
  start_date DATE,
  end_date DATE,
  deadline DATE,
  
  -- Asignación
  manager_id UUID REFERENCES users(id) ON DELETE SET NULL,
  team_members UUID[] DEFAULT '{}',
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_projects_company ON projects(company_id);
CREATE INDEX idx_projects_status ON projects(status);
CREATE INDEX idx_projects_manager ON projects(manager_id);

-- ============================================
-- TABLA: transactions
-- Transacciones financieras (ingresos y gastos)
-- ============================================
CREATE TABLE transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_id UUID REFERENCES users(id) ON DELETE CASCADE,
  
  -- Tipo de transacción
  type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
  category TEXT NOT NULL,
  
  -- Monto
  amount DECIMAL(12, 2) NOT NULL,
  currency TEXT DEFAULT 'USD',
  
  -- Descripción
  description TEXT NOT NULL,
  notes TEXT,
  
  -- Relación con proyecto (opcional)
  project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
  
  -- Fecha de la transacción
  transaction_date DATE NOT NULL,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_transactions_company ON transactions(company_id);
CREATE INDEX idx_transactions_type ON transactions(type);
CREATE INDEX idx_transactions_project ON transactions(project_id);
CREATE INDEX idx_transactions_date ON transactions(transaction_date DESC);

-- ============================================
-- TRIGGERS PARA UPDATED_AT
-- ============================================
CREATE TRIGGER update_conversations_updated_at BEFORE UPDATE ON conversations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_messages_updated_at BEFORE UPDATE ON messages
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_transactions_updated_at BEFORE UPDATE ON transactions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- TRIGGERS PARA FAVORITOS (incrementar/decrementar contadores)
-- ============================================
CREATE OR REPLACE FUNCTION increment_favorites_count()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.product_id IS NOT NULL THEN
    UPDATE products SET favorites_count = favorites_count + 1 WHERE id = NEW.product_id;
  ELSIF NEW.service_id IS NOT NULL THEN
    -- Nota: services no tiene favorites_count en el esquema actual
    -- Si se necesita, agregar columna favorites_count a services
    NULL;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER favorite_added AFTER INSERT ON favorites
  FOR EACH ROW EXECUTE FUNCTION increment_favorites_count();

CREATE OR REPLACE FUNCTION decrement_favorites_count()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.product_id IS NOT NULL THEN
    UPDATE products SET favorites_count = favorites_count - 1 WHERE id = OLD.product_id;
  ELSIF OLD.service_id IS NOT NULL THEN
    NULL;
  END IF;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER favorite_removed AFTER DELETE ON favorites
  FOR EACH ROW EXECUTE FUNCTION decrement_favorites_count();

-- ============================================
-- TRIGGERS PARA MENSAJERÍA
-- ============================================
-- Actualizar last_message_at y unread_count al enviar mensaje
CREATE OR REPLACE FUNCTION update_conversation_on_message()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE conversations
  SET 
    last_message_at = NOW(),
    unread_count_user1 = CASE 
      WHEN NEW.sender_id = user2_id THEN unread_count_user1 + 1 
      ELSE unread_count_user1 
    END,
    unread_count_user2 = CASE 
      WHEN NEW.sender_id = user1_id THEN unread_count_user2 + 1 
      ELSE unread_count_user2 
    END
  WHERE id = NEW.conversation_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER message_sent AFTER INSERT ON messages
  FOR EACH ROW EXECUTE FUNCTION update_conversation_on_message();

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

-- Habilitar RLS
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

-- Políticas para FAVORITES
CREATE POLICY "Users can view all favorites" ON favorites
  FOR SELECT USING (true);

CREATE POLICY "Users can add favorites" ON favorites
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can remove their favorites" ON favorites
  FOR DELETE USING (auth.uid() = user_id);

-- Políticas para CONVERSATIONS
-- Los usuarios solo pueden ver conversaciones donde participan
CREATE POLICY "Users can view their conversations" ON conversations
  FOR SELECT USING (auth.uid() = user1_id OR auth.uid() = user2_id);

CREATE POLICY "Users can create conversations" ON conversations
  FOR INSERT WITH CHECK (auth.uid() = user1_id OR auth.uid() = user2_id);

CREATE POLICY "Users can update their conversations" ON conversations
  FOR UPDATE USING (auth.uid() = user1_id OR auth.uid() = user2_id);

-- Políticas para MESSAGES
-- Los usuarios solo pueden ver mensajes de sus conversaciones
CREATE POLICY "Users can view messages from their conversations" ON messages
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM conversations 
      WHERE id = messages.conversation_id 
      AND (user1_id = auth.uid() OR user2_id = auth.uid())
    )
  );

CREATE POLICY "Users can send messages" ON messages
  FOR INSERT WITH CHECK (
    auth.uid() = sender_id AND
    EXISTS (
      SELECT 1 FROM conversations 
      WHERE id = conversation_id 
      AND (user1_id = auth.uid() OR user2_id = auth.uid())
    )
  );

CREATE POLICY "Users can update their messages" ON messages
  FOR UPDATE USING (auth.uid() = sender_id);

-- Políticas para PROJECTS
-- Solo la empresa y sus empleados pueden ver/editar proyectos
CREATE POLICY "Companies can view their projects" ON projects
  FOR SELECT USING (
    auth.uid() = company_id OR
    -- También empleados de la empresa pueden ver
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() 
      AND (organization_info->>'companyId')::uuid = projects.company_id
    )
  );

CREATE POLICY "Companies can create projects" ON projects
  FOR INSERT WITH CHECK (auth.uid() = company_id);

CREATE POLICY "Companies can update their projects" ON projects
  FOR UPDATE USING (auth.uid() = company_id);

CREATE POLICY "Companies can delete their projects" ON projects
  FOR DELETE USING (auth.uid() = company_id);

-- Políticas para TRANSACTIONS
-- Solo la empresa y ciertos empleados pueden ver/editar transacciones
CREATE POLICY "Companies can view their transactions" ON transactions
  FOR SELECT USING (
    auth.uid() = company_id OR
    -- Solo empleados con permiso de finanzas
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() 
      AND (organization_info->>'companyId')::uuid = transactions.company_id
      AND (
        (organization_info->>'roleId') IN ('ceo', 'finance', 'operations')
      )
    )
  );

CREATE POLICY "Companies can create transactions" ON transactions
  FOR INSERT WITH CHECK (auth.uid() = company_id);

CREATE POLICY "Companies can update their transactions" ON transactions
  FOR UPDATE USING (auth.uid() = company_id);

CREATE POLICY "Companies can delete their transactions" ON transactions
  FOR DELETE USING (auth.uid() = company_id);

-- ============================================
-- FIN DE TABLAS ADICIONALES
-- ============================================
