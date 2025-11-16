-- ============================================
-- 🔧 FIX: Corregir función get_available_slots
-- Soluciona el error "column reference start_time is ambiguous"
-- ============================================

-- Eliminar función anterior
DROP FUNCTION IF EXISTS get_available_slots(uuid, date, numeric);

CREATE OR REPLACE FUNCTION get_available_slots(
  p_service_id UUID,
  p_booking_date DATE,
  p_slot_duration_hours DECIMAL DEFAULT 1.0
)
RETURNS TABLE (
  start_time TIME,        -- ✅ Cambio: sin prefijo slot_
  end_time TIME,          -- ✅ Cambio: sin prefijo slot_
  is_available BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE
  v_day_of_week INTEGER;
  v_min_time TIME;
  v_max_time TIME;
  v_current_time TIME;
BEGIN
  -- Obtener día de la semana (0=Domingo, 1=Lunes, etc.)
  v_day_of_week := EXTRACT(DOW FROM p_booking_date);
  
  -- Obtener rango de horarios del servicio para ese día
  SELECT 
    MIN(sa.start_time),
    MAX(sa.end_time)
  INTO v_min_time, v_max_time
  FROM service_availability sa
  WHERE sa.service_id = p_service_id 
  AND sa.day_of_week = v_day_of_week
  AND sa.is_active = true;
  
  -- Si no hay disponibilidad configurada para ese día, retornar vacío
  IF v_min_time IS NULL OR v_max_time IS NULL THEN
    RETURN;
  END IF;
  
  -- Generar slots manualmente
  v_current_time := v_min_time;
  
  WHILE v_current_time + (p_slot_duration_hours || ' hours')::INTERVAL <= v_max_time LOOP
    start_time := v_current_time;  -- ✅ Sin prefijo slot_
    end_time := v_current_time + (p_slot_duration_hours || ' hours')::INTERVAL;  -- ✅ Sin prefijo slot_
    is_available := check_service_availability(
      p_service_id,
      p_booking_date,
      start_time,
      end_time
    );
    
    RETURN NEXT;
    
    v_current_time := v_current_time + (p_slot_duration_hours || ' hours')::INTERVAL;
  END LOOP;
  
  RETURN;
END;
$$;

-- ============================================
-- ✅ VERIFICAR: Probar la función
-- ============================================
-- Probar con el servicio de prueba
SELECT * FROM get_available_slots(
  '12345678-1234-1234-1234-123456789abc'::UUID,
  '2025-11-18'::DATE,  -- Lunes
  1.0  -- 1 hora de duración
);

-- Debería mostrar slots de 08:00 a 17:00 (último slot empieza a las 17:00 y termina a las 18:00)
