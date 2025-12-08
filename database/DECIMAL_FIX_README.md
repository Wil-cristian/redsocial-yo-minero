# Fix para Decimal Overflow - Aumentar precisión

## Problema
Al intentar crear una entrada financiera, se obtiene el error:
```
PostgrestException: numeric field overflow
A field with precision 15, scale 2 must round to an absolute value less than 10^13.
```

## Causa
Los campos DECIMAL en las tablas de contabilidad tienen precisión `DECIMAL(15,2)`, lo que permite solo valores hasta 9,999,999,999,999.99 (13 dígitos enteros).

Para operaciones mineras con valores altos, esto es insuficiente.

## Solución
Cambiar todos los campos DECIMAL(15,2) a DECIMAL(20,2), permitiendo valores hasta 99,999,999,999,999,999.99 (18 dígitos enteros).

## Tablas Afectadas
1. **financial_entries** - amount
2. **financial_accounts** - initial_balance, current_balance  
3. **financial_budgets** - planned_amount, actual_amount
4. **bank_reconciliations** - statement_balance, system_balance, difference
5. **financial_alert_settings** - low_cash_threshold, high_expense_threshold, daily_expense_limit

## Pasos para aplicar en Supabase

### Opción 1: Usar SQL Editor (Recomendado)
1. Ir a Supabase Dashboard → SQL Editor
2. Abrir archivo: `database/fix_decimal_precision.sql`
3. Ejecutar el script

### Opción 2: Usando CLI
```bash
supabase db push
```

### Opción 3: Manual (si las opciones anteriores fallan)
Ejecutar estos comandos en orden:

```sql
-- 1. Recrear financial_entries
DROP TABLE financial_entries CASCADE;

CREATE TABLE financial_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    type VARCHAR(20) NOT NULL CHECK (type IN ('income', 'expense', 'transfer')),
    income_category VARCHAR(50),
    expense_category VARCHAR(50),
    expense_group VARCHAR(50),
    amount DECIMAL(20,2) NOT NULL CHECK (amount >= 0),
    currency VARCHAR(3) DEFAULT 'USD',
    description TEXT NOT NULL,
    reference_number VARCHAR(100),
    date DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
    attachments JSONB DEFAULT '[]',
    metadata JSONB DEFAULT '{}',
    status VARCHAR(20) DEFAULT 'completed' CHECK (status IN ('pending', 'completed', 'cancelled', 'reconciled')),
    transfer_to_account VARCHAR(100),
    transfer_from_account VARCHAR(100),
    created_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    updated_by UUID REFERENCES profiles(id) ON DELETE SET NULL
);

-- 2. Actualizar financial_accounts
ALTER TABLE financial_accounts
DROP COLUMN IF EXISTS initial_balance,
DROP COLUMN IF EXISTS current_balance;
ALTER TABLE financial_accounts
ADD COLUMN initial_balance DECIMAL(20,2) DEFAULT 0,
ADD COLUMN current_balance DECIMAL(20,2) DEFAULT 0;

-- 3. Actualizar financial_budgets
ALTER TABLE financial_budgets
DROP COLUMN IF EXISTS planned_amount,
DROP COLUMN IF EXISTS actual_amount;
ALTER TABLE financial_budgets
ADD COLUMN planned_amount DECIMAL(20,2) NOT NULL DEFAULT 0,
ADD COLUMN actual_amount DECIMAL(20,2) DEFAULT 0;

-- 4. Actualizar bank_reconciliations
ALTER TABLE bank_reconciliations
DROP COLUMN IF EXISTS statement_balance,
DROP COLUMN IF EXISTS system_balance,
DROP COLUMN IF EXISTS difference;
ALTER TABLE bank_reconciliations
ADD COLUMN statement_balance DECIMAL(20,2) NOT NULL DEFAULT 0,
ADD COLUMN system_balance DECIMAL(20,2) NOT NULL DEFAULT 0,
ADD COLUMN difference DECIMAL(20,2) GENERATED ALWAYS AS (statement_balance - system_balance) STORED;

-- 5. Actualizar financial_alert_settings
ALTER TABLE financial_alert_settings
DROP COLUMN IF EXISTS low_cash_threshold,
DROP COLUMN IF EXISTS high_expense_threshold,
DROP COLUMN IF EXISTS daily_expense_limit;
ALTER TABLE financial_alert_settings
ADD COLUMN low_cash_threshold DECIMAL(20,2) DEFAULT 5000,
ADD COLUMN high_expense_threshold DECIMAL(20,2) DEFAULT 10000,
ADD COLUMN daily_expense_limit DECIMAL(20,2);
```

## Verificación
Después de aplicar el fix, verificar que los campos tienen la precisión correcta:

```sql
SELECT column_name, data_type, numeric_precision, numeric_scale
FROM information_schema.columns
WHERE table_name IN ('financial_entries', 'financial_accounts', 'financial_budgets')
AND data_type = 'numeric'
ORDER BY table_name, column_name;
```

Debería mostrar `numeric_precision = 20` para todos los campos afectados.

## Archivos modificados
- `database/accounting_tables.sql` - Actualizado con DECIMAL(20,2)
- `database/fix_decimal_precision.sql` - Script de migración
