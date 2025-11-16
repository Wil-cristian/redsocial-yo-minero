-- ============================================
-- ⚡ OPTIMIZACIÓN: Función get_available_slots ultra-rápida
-- Usa generate_series con TIMESTAMP para máxima velocidad
-- ============================================

DROP FUNCTION IF EXISTS get_available_slots(uuid, date, numeric);

CREATE OR REPLACE FUNCTION get_available_slots(
  p_service_id UUID,
  p_booking_date DATE,
  p_slot_duration_hours DECIMAL DEFAULT 1.0
)
RETURNS TABLE (
  start_time TIME,
  end_time TIME,
  is_available BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE
  v_day_of_week INTEGER;
  v_min_time TIME;
  v_max_time TIME;
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
  
  -- ⚡ Generación optimizada usando generate_series con TIMESTAMP
  RETURN QUERY
  SELECT 
    slot_start::TIME as start_time,
    slot_end::TIME as end_time,
    NOT EXISTS (
      SELECT 1 FROM service_bookings sb
      WHERE sb.service_id = p_service_id
      AND sb.booking_date = p_booking_date
      AND sb.status IN ('pending', 'confirmed')
      AND (sb.start_time::TIME, sb.end_time::TIME) OVERLAPS (slot_start::TIME, slot_end::TIME)
    ) as is_available
  FROM (
    SELECT 
      ts as slot_start,
      ts + (p_slot_duration_hours || ' hours')::INTERVAL as slot_end
    FROM generate_series(
      (p_booking_date || ' ' || v_min_time)::TIMESTAMP,
      (p_booking_date || ' ' || v_max_time)::TIMESTAMP - (p_slot_duration_hours || ' hours')::INTERVAL,
      (p_slot_duration_hours || ' hours')::INTERVAL
    ) as ts
  ) slots
  WHERE slot_end::TIME <= v_max_time;
END;
$$;

-- ============================================
-- ✅ VERIFICAR: Probar la función optimizada
-- ============================================
SELECT * FROM get_available_slots(
  '12345678-1234-1234-1234-123456789abc'::UUID,
  '2025-11-28'::DATE,
  8.0  -- 8 horas - ahora debería ser rápido
);
