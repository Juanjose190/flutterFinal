CREATE TABLE IF NOT EXISTS materias (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    horas_semanales INTEGER NOT NULL,
    descripcion TEXT,
    requiere_aula_especial BOOLEAN DEFAULT FALSE,
    tipo_aula_especial VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS profesores (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    horas_disponibles INTEGER
);

CREATE TABLE IF NOT EXISTS aulas (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    capacidad INTEGER,
    es_especial BOOLEAN DEFAULT FALSE,
    tipo_aula VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS profesor_materia (
    profesor_id BIGINT NOT NULL,
    materia_id BIGINT NOT NULL,
    PRIMARY KEY (profesor_id, materia_id),
    FOREIGN KEY (profesor_id) REFERENCES profesores(id) ON DELETE CASCADE,
    FOREIGN KEY (materia_id) REFERENCES materias(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS disponibilidad_profesor (
    id SERIAL PRIMARY KEY,
    profesor_id BIGINT NOT NULL,
    dia VARCHAR(20) NOT NULL,
    hora_inicio VARCHAR(10) NOT NULL,
    hora_fin VARCHAR(10) NOT NULL,
    FOREIGN KEY (profesor_id) REFERENCES profesores(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS horarios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS asignaciones_horarias (
    id SERIAL PRIMARY KEY,
    horario_id BIGINT NOT NULL,
    materia_id BIGINT NOT NULL,
    profesor_id BIGINT NOT NULL,
    aula_id BIGINT NOT NULL,
    dia VARCHAR(20) NOT NULL,
    hora_inicio VARCHAR(10) NOT NULL,
    hora_fin VARCHAR(10) NOT NULL,
    FOREIGN KEY (horario_id) REFERENCES horarios(id) ON DELETE CASCADE,
    FOREIGN KEY (materia_id) REFERENCES materias(id),
    FOREIGN KEY (profesor_id) REFERENCES profesores(id),
    FOREIGN KEY (aula_id) REFERENCES aulas(id)
);
