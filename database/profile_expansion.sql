-- Expansión del esquema de perfil de usuario
-- Agrega campos profesionales y de contacto adicionales

-- Agregar nuevos campos a la tabla users
ALTER TABLE users
ADD COLUMN IF NOT EXISTS phone VARCHAR(50),
ADD COLUMN IF NOT EXISTS profession VARCHAR(200),
ADD COLUMN IF NOT EXISTS company VARCHAR(200),
ADD COLUMN IF NOT EXISTS job_title VARCHAR(200),
ADD COLUMN IF NOT EXISTS website VARCHAR(500),
ADD COLUMN IF NOT EXISTS location JSONB DEFAULT '{}',
ADD COLUMN IF NOT EXISTS birth_date DATE,
ADD COLUMN IF NOT EXISTS experience_level VARCHAR(50) DEFAULT 'beginner',
ADD COLUMN IF NOT EXISTS specializations TEXT[] DEFAULT '{}',
ADD COLUMN IF NOT EXISTS interests TEXT[] DEFAULT '{}';

-- Comentarios para documentar los campos
COMMENT ON COLUMN users.phone IS 'Número de teléfono de contacto';
COMMENT ON COLUMN users.profession IS 'Profesión o título profesional (ej. Ingeniero de Minas)';
COMMENT ON COLUMN users.company IS 'Nombre de la empresa donde trabaja';
COMMENT ON COLUMN users.job_title IS 'Cargo o puesto actual';
COMMENT ON COLUMN users.website IS 'Sitio web personal o de empresa';
COMMENT ON COLUMN users.location IS 'Ubicación en formato JSON: {city, state, country, address}';
COMMENT ON COLUMN users.birth_date IS 'Fecha de nacimiento';
COMMENT ON COLUMN users.experience_level IS 'Nivel de experiencia: beginner, intermediate, advanced, expert';
COMMENT ON COLUMN users.specializations IS 'Lista de especializaciones en minería';
COMMENT ON COLUMN users.interests IS 'Lista de intereses o áreas de interés';

-- Índices para mejorar las búsquedas
CREATE INDEX IF NOT EXISTS idx_users_profession ON users(profession);
CREATE INDEX IF NOT EXISTS idx_users_company ON users(company);
CREATE INDEX IF NOT EXISTS idx_users_experience_level ON users(experience_level);

-- Índice GIN para búsquedas en arrays
CREATE INDEX IF NOT EXISTS idx_users_specializations ON users USING GIN(specializations);
CREATE INDEX IF NOT EXISTS idx_users_interests ON users USING GIN(interests);
