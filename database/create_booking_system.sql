-- 🎯 SISTEMA DE BOOKING/RESERVAS PARA SERVICIOS
-- Ejecutar este SQL en Supabase SQL Editor

-- ============================================
-- TABLA: service_bookings
-- Gestión de reservas de servicios
-- ============================================
CREATE TABLE IF NOT EXISTS service_bookings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  -- Referencias
  service_id UUID REFERENCES services(id) ON DELETE CASCADE NOT NULL,
  provider_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  client_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  
  -- Información de la reserva
  booking_date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  duration_hours DECIMAL(4,2) NOT NULL,
  
  -- Estado de la reserva
  status TEXT NOT NULL DEFAULT 'pending',
  -- Estados: pending, confirmed, cancelled, completed, rejected
  
  -- Detalles del cliente
  client_notes TEXT,
  location TEXT,
  
  -- Pricing
  total_price DECIMAL(10,2),
  currency TEXT DEFAULT 'USD',
  
  -- Confirmación del proveedor
  provider_notes TEXT,
  confirmed_at TIMESTAMP WITH TIME ZONE,
  cancelled_at TIMESTAMP WITH TIME ZONE,
  cancellation_reason TEXT,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Constraints
  CONSTRAINT valid_status CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed', 'rejected')),
  CONSTRAINT valid_time_range CHECK (end_time > start_time)
);

-- Índices para búsquedas eficientes
CREATE INDEX IF NOT EXISTS idx_bookings_service ON service_bookings(service_id, booking_date);
CREATE INDEX IF NOT EXISTS idx_bookings_provider ON service_bookings(provider_id, status);
CREATE INDEX IF NOT EXISTS idx_bookings_client ON service_bookings(client_id, status);
CREATE INDEX IF NOT EXISTS idx_bookings_date ON service_bookings(booking_date, status);

-- ============================================
-- TABLA: service_availability
-- Disponibilidad y horarios de servicios
-- ============================================
CREATE TABLE IF NOT EXISTS service_availability (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  service_id UUID REFERENCES services(id) ON DELETE CASCADE NOT NULL,
  
  -- Día de la semana (1=Lunes, 7=Domingo)
  day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 1 AND 7),
  
  -- Horarios disponibles
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  
  -- Activo/Inactivo
  is_active BOOLEAN DEFAULT true,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  CONSTRAINT valid_availability_time CHECK (end_time > start_time)
);

CREATE INDEX IF NOT EXISTS idx_availability_service ON service_availability(service_id, day_of_week);

-- ============================================
-- TABLA: service_blocked_dates
-- Fechas bloqueadas (vacaciones, días festivos)
-- ============================================
CREATE TABLE IF NOT EXISTS service_blocked_dates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  service_id UUID REFERENCES services(id) ON DELETE CASCADE NOT NULL,
  
  blocked_date DATE NOT NULL,
  reason TEXT,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  UNIQUE(service_id, blocked_date)
);

CREATE INDEX IF NOT EXISTS idx_blocked_dates_service ON service_blocked_dates(service_id, blocked_date);

-- ============================================
-- FUNCIÓN: Verificar disponibilidad
-- ============================================
CREATE OR REPLACE FUNCTION check_service_availability(
  p_service_id UUID,
  p_booking_date DATE,
  p_start_time TIME,
  p_end_time TIME
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
  v_day_of_week INTEGER;
  v_is_blocked BOOLEAN;
  v_has_conflict BOOLEAN;
  v_has_availability BOOLEAN;
BEGIN
  -- Obtener día de la semana (0=Domingo)
  v_day_of_week := EXTRACT(DOW FROM p_booking_date);
  
  -- Verificar si la fecha está bloqueada
  SELECT EXISTS(
    SELECT 1 FROM service_blocked_dates
    WHERE service_id = p_service_id
    AND blocked_date = p_booking_date
  ) INTO v_is_blocked;
  
  IF v_is_blocked THEN
    RETURN FALSE;
  END IF;
  
  -- Verificar si hay disponibilidad configurada para ese día
  SELECT EXISTS(
    SELECT 1 FROM service_availability
    WHERE service_id = p_service_id
    AND day_of_week = v_day_of_week
    AND is_active = true
    AND p_start_time >= start_time
    AND p_end_time <= end_time
  ) INTO v_has_availability;
  
  IF NOT v_has_availability THEN
    RETURN FALSE;
  END IF;
  
  -- Verificar conflictos con otras reservas
  SELECT EXISTS(
    SELECT 1 FROM service_bookings
    WHERE service_id = p_service_id
    AND booking_date = p_booking_date
    AND status IN ('confirmed', 'pending')
    AND (
      (p_start_time >= start_time AND p_start_time < end_time)
      OR (p_end_time > start_time AND p_end_time <= end_time)
      OR (p_start_time <= start_time AND p_end_time >= end_time)
    )
  ) INTO v_has_conflict;
  
  RETURN NOT v_has_conflict;
END;
$$;

-- ============================================
-- FUNCIÓN: Obtener slots disponibles por día
-- ============================================
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
BEGIN
  v_day_of_week := EXTRACT(DOW FROM p_booking_date);
  
  RETURN QUERY
  SELECT 
    CAST(gs AS TIME) as start_time,
    CAST(gs + (p_slot_duration_hours || ' hours')::INTERVAL AS TIME) as end_time,
    check_service_availability(
      p_service_id,
      p_booking_date,
      CAST(gs AS TIME),
      CAST(gs + (p_slot_duration_hours || ' hours')::INTERVAL AS TIME)
    ) as is_available
  FROM (
    SELECT generate_series(
      (SELECT MIN(start_time) FROM service_availability 
       WHERE service_id = p_service_id AND day_of_week = v_day_of_week),
      (SELECT MAX(end_time) FROM service_availability 
       WHERE service_id = p_service_id AND day_of_week = v_day_of_week) - (p_slot_duration_hours || ' hours')::INTERVAL,
      (p_slot_duration_hours || ' hours')::INTERVAL
    ) as gs
  ) slots;
END;
$$;

-- ============================================
-- FUNCIÓN: Crear booking
-- ============================================
CREATE OR REPLACE FUNCTION create_service_booking(
  p_service_id UUID,
  p_booking_date DATE,
  p_start_time TIME,
  p_end_time TIME,
  p_duration_hours DECIMAL,
  p_client_notes TEXT DEFAULT NULL,
  p_location TEXT DEFAULT NULL,
  p_total_price DECIMAL DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_booking_id UUID;
  v_provider_id UUID;
  v_is_available BOOLEAN;
BEGIN
  -- Obtener provider_id del servicio
  SELECT provider_id INTO v_provider_id
  FROM services
  WHERE id = p_service_id;
  
  IF v_provider_id IS NULL THEN
    RAISE EXCEPTION 'Service not found';
  END IF;
  
  -- Verificar disponibilidad
  SELECT check_service_availability(
    p_service_id,
    p_booking_date,
    p_start_time,
    p_end_time
  ) INTO v_is_available;
  
  IF NOT v_is_available THEN
    RAISE EXCEPTION 'Time slot not available';
  END IF;
  
  -- Crear booking
  INSERT INTO service_bookings (
    service_id,
    provider_id,
    client_id,
    booking_date,
    start_time,
    end_time,
    duration_hours,
    client_notes,
    location,
    total_price,
    status
  ) VALUES (
    p_service_id,
    v_provider_id,
    auth.uid(),
    p_booking_date,
    p_start_time,
    p_end_time,
    p_duration_hours,
    p_client_notes,
    p_location,
    p_total_price,
    'pending'
  )
  RETURNING id INTO v_booking_id;
  
  RETURN v_booking_id;
END;
$$;

-- ============================================
-- FUNCIÓN: Obtener bookings con detalles
-- ============================================
CREATE OR REPLACE FUNCTION get_service_bookings(p_service_id UUID DEFAULT NULL)
RETURNS TABLE (
  id UUID,
  service_id UUID,
  service_name TEXT,
  provider_id UUID,
  provider_name TEXT,
  client_id UUID,
  client_name TEXT,
  client_username TEXT,
  client_profile_image TEXT,
  booking_date DATE,
  start_time TIME,
  end_time TIME,
  duration_hours DECIMAL,
  status TEXT,
  client_notes TEXT,
  location TEXT,
  total_price DECIMAL,
  currency TEXT,
  provider_notes TEXT,
  confirmed_at TIMESTAMP WITH TIME ZONE,
  cancelled_at TIMESTAMP WITH TIME ZONE,
  cancellation_reason TEXT,
  created_at TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    b.id,
    b.service_id,
    s.name as service_name,
    b.provider_id,
    provider.name as provider_name,
    b.client_id,
    client.name as client_name,
    client.username as client_username,
    client.profile_image_url as client_profile_image,
    b.booking_date,
    b.start_time,
    b.end_time,
    b.duration_hours,
    b.status,
    b.client_notes,
    b.location,
    b.total_price,
    b.currency,
    b.provider_notes,
    b.confirmed_at,
    b.cancelled_at,
    b.cancellation_reason,
    b.created_at
  FROM service_bookings b
  LEFT JOIN services s ON b.service_id = s.id
  LEFT JOIN users provider ON b.provider_id = provider.id
  LEFT JOIN users client ON b.client_id = client.id
  WHERE (p_service_id IS NULL OR b.service_id = p_service_id)
  AND (b.provider_id = auth.uid() OR b.client_id = auth.uid())
  ORDER BY b.booking_date DESC, b.start_time DESC;
END;
$$;

-- ============================================
-- Otorgar permisos
-- ============================================
GRANT EXECUTE ON FUNCTION check_service_availability(UUID, DATE, TIME, TIME) TO authenticated;
GRANT EXECUTE ON FUNCTION get_available_slots(UUID, DATE, DECIMAL) TO authenticated;
GRANT EXECUTE ON FUNCTION create_service_booking(UUID, DATE, TIME, TIME, DECIMAL, TEXT, TEXT, DECIMAL) TO authenticated;
GRANT EXECUTE ON FUNCTION get_service_bookings(UUID) TO authenticated;

-- ============================================
-- Trigger para actualizar updated_at
-- ============================================
CREATE OR REPLACE FUNCTION update_booking_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_booking_timestamp_trigger ON service_bookings;

CREATE TRIGGER update_booking_timestamp_trigger
BEFORE UPDATE ON service_bookings
FOR EACH ROW
EXECUTE FUNCTION update_booking_timestamp();

-- ✅ Sistema de Booking completo creado!
-- Ahora puedes gestionar reservas, verificar disponibilidad y más.

-- ============================================
-- EJEMPLO: Configurar disponibilidad
-- ============================================
-- Para agregar horarios disponibles a un servicio, primero obtén el service_id:
-- SELECT id, name FROM services WHERE provider_id = auth.uid();

-- Luego inserta la disponibilidad (ejemplo para Lunes 09:00-18:00):
/*
INSERT INTO service_availability (service_id, day_of_week, start_time, end_time)
SELECT 
  id,
  1, -- Lunes (1=Lunes, 7=Domingo)
  '09:00'::TIME,
  '18:00'::TIME
FROM services
WHERE name = 'Nombre de tu servicio' -- Cambia esto por el nombre real
LIMIT 1;
*/

-- Para agregar disponibilidad a todos los días laborables (Lunes-Viernes):
/*
INSERT INTO service_availability (service_id, day_of_week, start_time, end_time)
SELECT 
  s.id,
  d.day_num,
  '09:00'::TIME,
  '18:00'::TIME
FROM services s
CROSS JOIN (VALUES (1), (2), (3), (4), (5)) AS d(day_num)
WHERE s.provider_id = auth.uid()
AND NOT EXISTS (
  SELECT 1 FROM service_availability sa 
  WHERE sa.service_id = s.id AND sa.day_of_week = d.day_num
);
*/

