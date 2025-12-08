-- =====================================================
-- Script de migración para el módulo de Contabilidad
-- Red Social Yo Minero
-- =====================================================

-- Tabla principal de transacciones financieras
CREATE TABLE IF NOT EXISTS financial_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    
    -- Tipo de transacción
    type VARCHAR(20) NOT NULL CHECK (type IN ('income', 'expense', 'transfer')),
    
    -- Categorías específicas para minería
    income_category VARCHAR(50),
    expense_category VARCHAR(50),
    expense_group VARCHAR(50),
    
    -- Detalles financieros
    amount DECIMAL(20,2) NOT NULL CHECK (amount >= 0),
    currency VARCHAR(3) DEFAULT 'USD',
    description TEXT NOT NULL,
    reference_number VARCHAR(100),
    
    -- Fechas
    date DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Relacionado a proyectos (opcional)
    project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
    
    -- Archivos adjuntos (facturas, recibos, etc.)
    attachments JSONB DEFAULT '[]',
    
    -- Metadatos adicionales
    metadata JSONB DEFAULT '{}',
    
    -- Estado de la transacción
    status VARCHAR(20) DEFAULT 'completed' CHECK (status IN ('pending', 'completed', 'cancelled', 'reconciled')),
    
    -- Para transferencias
    transfer_to_account VARCHAR(100),
    transfer_from_account VARCHAR(100),
    
    -- Quién creó/modificó
    created_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    updated_by UUID REFERENCES profiles(id) ON DELETE SET NULL
);

-- Índices para búsquedas comunes
CREATE INDEX IF NOT EXISTS idx_financial_entries_company ON financial_entries(company_id);
CREATE INDEX IF NOT EXISTS idx_financial_entries_type ON financial_entries(type);
CREATE INDEX IF NOT EXISTS idx_financial_entries_date ON financial_entries(date DESC);
CREATE INDEX IF NOT EXISTS idx_financial_entries_category ON financial_entries(income_category, expense_category);
CREATE INDEX IF NOT EXISTS idx_financial_entries_project ON financial_entries(project_id);
CREATE INDEX IF NOT EXISTS idx_financial_entries_status ON financial_entries(status);

-- Trigger para actualizar updated_at
CREATE OR REPLACE FUNCTION update_financial_entries_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_financial_entries_updated_at ON financial_entries;
CREATE TRIGGER trigger_financial_entries_updated_at
    BEFORE UPDATE ON financial_entries
    FOR EACH ROW
    EXECUTE FUNCTION update_financial_entries_updated_at();

-- Tabla para cuentas bancarias/cajas
CREATE TABLE IF NOT EXISTS financial_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    
    name VARCHAR(100) NOT NULL,
    account_type VARCHAR(30) NOT NULL CHECK (account_type IN ('bank', 'cash', 'credit_card', 'other')),
    account_number VARCHAR(100),
    bank_name VARCHAR(100),
    
    initial_balance DECIMAL(20,2) DEFAULT 0,
    current_balance DECIMAL(20,2) DEFAULT 0,
    currency VARCHAR(3) DEFAULT 'USD',
    
    is_active BOOLEAN DEFAULT true,
    is_default BOOLEAN DEFAULT false,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(company_id, name)
);

CREATE INDEX IF NOT EXISTS idx_financial_accounts_company ON financial_accounts(company_id);

-- Tabla para presupuestos (futuro)
CREATE TABLE IF NOT EXISTS financial_budgets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    budget_type VARCHAR(20) DEFAULT 'expense' CHECK (budget_type IN ('income', 'expense')),
    
    -- Período del presupuesto
    period_type VARCHAR(20) DEFAULT 'monthly' CHECK (period_type IN ('daily', 'weekly', 'monthly', 'quarterly', 'yearly')),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    
    -- Montos
    planned_amount DECIMAL(15,2) NOT NULL,
    actual_amount DECIMAL(15,2) DEFAULT 0,
    
    -- Alertas
    alert_threshold DECIMAL(5,2) DEFAULT 80.00, -- Porcentaje
    alert_enabled BOOLEAN DEFAULT true,
    
    notes TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_financial_budgets_company ON financial_budgets(company_id);
CREATE INDEX IF NOT EXISTS idx_financial_budgets_dates ON financial_budgets(start_date, end_date);

-- Tabla para conciliaciones bancarias (futuro)
CREATE TABLE IF NOT EXISTS bank_reconciliations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES financial_accounts(id) ON DELETE CASCADE,
    company_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    
    reconciliation_date DATE NOT NULL,
    statement_balance DECIMAL(15,2) NOT NULL,
    system_balance DECIMAL(15,2) NOT NULL,
    difference DECIMAL(15,2) GENERATED ALWAYS AS (statement_balance - system_balance) STORED,
    
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'discrepancy')),
    
    notes TEXT,
    reconciled_by UUID REFERENCES profiles(id),
    reconciled_at TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla para categorías personalizadas (futuro)
CREATE TABLE IF NOT EXISTS custom_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    
    category_type VARCHAR(20) NOT NULL CHECK (category_type IN ('income', 'expense')),
    name VARCHAR(100) NOT NULL,
    parent_id UUID REFERENCES custom_categories(id) ON DELETE SET NULL,
    
    icon VARCHAR(50),
    color VARCHAR(10),
    
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(company_id, category_type, name)
);

CREATE INDEX IF NOT EXISTS idx_custom_categories_company ON custom_categories(company_id);

-- Tabla para configuración de alertas financieras
CREATE TABLE IF NOT EXISTS financial_alert_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    
    -- Tipos de alertas
    low_cash_threshold DECIMAL(15,2) DEFAULT 5000,
    high_expense_threshold DECIMAL(15,2) DEFAULT 10000,
    daily_expense_limit DECIMAL(15,2),
    
    -- Notificaciones
    email_alerts BOOLEAN DEFAULT true,
    push_alerts BOOLEAN DEFAULT true,
    
    -- Configuración
    settings JSONB DEFAULT '{}',
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(company_id)
);

-- Vista para resumen financiero por mes
CREATE OR REPLACE VIEW financial_monthly_summary AS
SELECT 
    company_id,
    DATE_TRUNC('month', date)::DATE as month,
    SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END) as total_income,
    SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) as total_expense,
    SUM(CASE WHEN type = 'income' THEN amount ELSE -amount END) as net_balance,
    COUNT(*) as transaction_count
FROM financial_entries
WHERE status != 'cancelled'
GROUP BY company_id, DATE_TRUNC('month', date)
ORDER BY month DESC;

-- Vista para desglose por categoría
CREATE OR REPLACE VIEW financial_category_breakdown AS
SELECT 
    company_id,
    type,
    COALESCE(income_category, expense_category) as category,
    expense_group,
    DATE_TRUNC('month', date)::DATE as month,
    SUM(amount) as total_amount,
    COUNT(*) as transaction_count
FROM financial_entries
WHERE status != 'cancelled'
GROUP BY company_id, type, income_category, expense_category, expense_group, DATE_TRUNC('month', date)
ORDER BY total_amount DESC;

-- RLS Policies
ALTER TABLE financial_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE financial_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE financial_budgets ENABLE ROW LEVEL SECURITY;
ALTER TABLE bank_reconciliations ENABLE ROW LEVEL SECURITY;
ALTER TABLE custom_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE financial_alert_settings ENABLE ROW LEVEL SECURITY;

-- Política: Los usuarios solo pueden ver sus propias transacciones
CREATE POLICY financial_entries_select ON financial_entries
    FOR SELECT USING (company_id = auth.uid());

CREATE POLICY financial_entries_insert ON financial_entries
    FOR INSERT WITH CHECK (company_id = auth.uid());

CREATE POLICY financial_entries_update ON financial_entries
    FOR UPDATE USING (company_id = auth.uid());

CREATE POLICY financial_entries_delete ON financial_entries
    FOR DELETE USING (company_id = auth.uid());

-- Políticas similares para otras tablas
CREATE POLICY financial_accounts_all ON financial_accounts
    FOR ALL USING (company_id = auth.uid());

CREATE POLICY financial_budgets_all ON financial_budgets
    FOR ALL USING (company_id = auth.uid());

CREATE POLICY bank_reconciliations_all ON bank_reconciliations
    FOR ALL USING (company_id = auth.uid());

CREATE POLICY custom_categories_all ON custom_categories
    FOR ALL USING (company_id = auth.uid());

CREATE POLICY financial_alert_settings_all ON financial_alert_settings
    FOR ALL USING (company_id = auth.uid());

-- Función para calcular balance acumulado
CREATE OR REPLACE FUNCTION calculate_running_balance(p_company_id UUID, p_account_id UUID DEFAULT NULL)
RETURNS TABLE (
    entry_id UUID,
    entry_date DATE,
    amount DECIMAL,
    type VARCHAR,
    running_balance DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        fe.id,
        fe.date,
        fe.amount,
        fe.type,
        SUM(
            CASE WHEN fe.type = 'income' THEN fe.amount ELSE -fe.amount END
        ) OVER (ORDER BY fe.date, fe.created_at)::DECIMAL as running_balance
    FROM financial_entries fe
    WHERE fe.company_id = p_company_id
      AND fe.status != 'cancelled'
    ORDER BY fe.date, fe.created_at;
END;
$$ LANGUAGE plpgsql;

-- Insertar datos de ejemplo (opcional - comentar en producción)
/*
INSERT INTO financial_entries (company_id, type, income_category, amount, description, date)
VALUES 
    ('your-company-id', 'income', 'gold_sale', 150000.00, 'Venta de oro - Lote #001', '2025-01-15'),
    ('your-company-id', 'income', 'silver_sale', 25000.00, 'Venta de plata - Lote #002', '2025-01-16'),
    ('your-company-id', 'expense', 'fuel', 8500.00, 'Combustible para maquinaria', '2025-01-14'),
    ('your-company-id', 'expense', 'salaries', 45000.00, 'Nómina quincenal', '2025-01-15'),
    ('your-company-id', 'expense', 'equipment_maintenance', 12000.00, 'Mantenimiento excavadora', '2025-01-17');
*/

-- Mensaje de confirmación
DO $$
BEGIN
    RAISE NOTICE 'Tablas de contabilidad creadas exitosamente';
END $$;
