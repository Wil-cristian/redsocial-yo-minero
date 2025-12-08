-- =====================================================
-- Fix para aumentar precisión de campos DECIMAL
-- Cambia DECIMAL(15,2) a DECIMAL(20,2)
-- =====================================================

-- 1. Recrear tabla financial_entries con campos ampliados
CREATE TABLE IF NOT EXISTS financial_entries_new AS
SELECT * FROM financial_entries;

ALTER TABLE financial_entries_new DROP COLUMN amount;
ALTER TABLE financial_entries_new ADD COLUMN amount DECIMAL(20,2) NOT NULL DEFAULT 0;

-- 2. Recrear tabla financial_accounts
ALTER TABLE financial_accounts 
DROP COLUMN initial_balance,
DROP COLUMN current_balance,
ADD COLUMN initial_balance DECIMAL(20,2) DEFAULT 0,
ADD COLUMN current_balance DECIMAL(20,2) DEFAULT 0;

-- 3. Recrear tabla financial_budgets
ALTER TABLE financial_budgets
DROP COLUMN planned_amount,
DROP COLUMN actual_amount,
ADD COLUMN planned_amount DECIMAL(20,2) NOT NULL DEFAULT 0,
ADD COLUMN actual_amount DECIMAL(20,2) DEFAULT 0;

-- 4. Recrear tabla bank_reconciliations
ALTER TABLE bank_reconciliations
DROP COLUMN statement_balance,
DROP COLUMN system_balance,
DROP COLUMN difference,
ADD COLUMN statement_balance DECIMAL(20,2) NOT NULL DEFAULT 0,
ADD COLUMN system_balance DECIMAL(20,2) NOT NULL DEFAULT 0,
ADD COLUMN difference DECIMAL(20,2) GENERATED ALWAYS AS (statement_balance - system_balance) STORED;

-- 5. Recrear tabla financial_alert_settings
ALTER TABLE financial_alert_settings
DROP COLUMN low_cash_threshold,
DROP COLUMN high_expense_threshold,
DROP COLUMN daily_expense_limit,
ADD COLUMN low_cash_threshold DECIMAL(20,2) DEFAULT 5000,
ADD COLUMN high_expense_threshold DECIMAL(20,2) DEFAULT 10000,
ADD COLUMN daily_expense_limit DECIMAL(20,2);

-- Cleanup
DROP TABLE IF EXISTS financial_entries_new;

-- Verificación
SELECT column_name, data_type, numeric_precision, numeric_scale
FROM information_schema.columns
WHERE table_name IN ('financial_entries', 'financial_accounts', 'financial_budgets', 'bank_reconciliations', 'financial_alert_settings')
AND data_type = 'numeric'
ORDER BY table_name, column_name;
