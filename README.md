# Generador de Horarios Académicos con IA (Gemini)

Aplicación para gestionar entidades académicas (materias, profesores, aulas) y generar horarios académicos completos de forma optimizada.

El sistema utiliza la inteligencia artificial de Gemini para proponer horarios válidos en formato JSON, resolviendo el complejo problema de la asignación de recursos y tiempos en función de las restricciones registradas.

## Índice

- [Visión General](#visión-general)
- [Arquitectura del Proyecto](#arquitectura-del-proyecto)
- [Backend (Spring Boot)](#backend-spring-boot)
- [Frontend (Flutter Web)](#frontend-flutter-web)
- [Flujo de IA (Gemini)](#flujo-de-ia-gemini)
- [Endpoints Clave](#endpoints-clave)
- [Modelos de Datos Principales](#modelos-de-datos-principales)
- [Puesta en Marcha](#puesta-en-marcha)
- [Pruebas Rápidas](#pruebas-rápidas)
- [Solución de Problemas](#solución-de-problemas)
- [Hoja de Ruta](#hoja-de-ruta)

## Visión General

El **Generador de Horarios** es un sistema CRUD con capacidades de planificación asistida por IA.

### Funcionalidades Principales

- **Gestión de Recursos**: CRUD completo para Materias, Profesores y Aulas.
- **Restricciones**: Registro de la disponibilidad horaria específica de cada profesor.
- **Relaciones**: Asignación de una o más Materias a cada Profesor.
- **Generación**: Creación de Horarios académicos que incluyen asignaciones específicas de Aula, Materia, Profesor, Día y Bloque Horario.
- **Asistencia IA**: Uso de la API de Gemini para recibir una propuesta de asignación horaria válida.

### Tecnologías Base

| Componente | Tecnología | Rol |
|------------|------------|-----|
| Base de Datos | Supabase (PostgreSQL) | Persistencia y API REST/PostgREST. |
| Backend | Spring Boot 3 (Java 21) | Lógica de negocio, integración con Supabase y orquestación de la IA. |
| Frontend | Flutter Web | Interfaz de usuario rica y responsiva. |
| Inteligencia Artificial | Gemini API | Motor de planificación de horarios. |

### Cambios Recientes (v0.2.0)

- Persistencia real de las relaciones muchos a muchos: `profesor_materia` y `disponibilidad_profesor`.
- Endpoints dedicados GET/PUT para manejar estas relaciones de manera aislada.
- Componentes UI mejorados para edición de disponibilidad y selección múltiple de materias.
- Inserción transaccional de un Horario junto con sus `asignaciones_horarias` asociadas.

## Arquitectura del Proyecto

El proyecto sigue una arquitectura de Monorepo estructurado en dos carpetas principales, conectadas por la capa REST:
```
Generador-Horarios-Repo/
├── Backend/
│   ├── src/main/java/... (Spring Boot)
│   └── pom.xml
└── Frontend/
    ├── lib/src/... (Flutter Web)
    └── pubspec.yaml
```

### Integraciones Clave

| Componente | Flujo de Datos | Comunicación | Protocolo/Formato |
|------------|----------------|--------------|-------------------|
| Backend ↔ Supabase | CRUD de datos | RESTful | JSON (con header `Authorization: Bearer Service-Role`) |
| Frontend ↔ Backend | Acciones de usuario / Respuestas | Cliente-Servidor | JSON |
| Backend ↔ Gemini | Contexto / Propuesta horaria | API Externa | Prompt de texto + Respuesta JSON pura |

## Backend (Spring Boot)

El paquete raíz de la aplicación es `com.horarios.generador`.

### Capas Principales

- **Controladores (Controllers)**: Exponen los endpoints REST (`/api/materias`, `/api/profesores`, etc.).
- **Servicios (Services)**: Contienen la lógica de negocio y orquestan la comunicación.
  - **SupabaseService**: Encargado de todas las interacciones con la base de datos Supabase (CRUD genérico y manejo de relaciones complejas).
  - **GeminiService**: Encargado de construir el prompt y llamar a la API de Gemini para la generación de horarios.
- **Modelos (Models/DTOs)**: Representación de las entidades de datos (e.g., `Materia.java`, `Horario.java`, `DisponibilidadHoraria.java`).

### Cambios Clave en SupabaseService

Se añadieron métodos específicos para manejar las relaciones a nivel de servicio, facilitando la lógica del controlador:

| Funcionalidad | Método |
|---------------|--------|
| Obtener Materias asignadas | `getMateriaIdsByProfesorId(Long id)` |
| Reemplazar Materias asignadas | `replaceProfesorMaterias(Long id, List<Long> materiaIds)` |
| Obtener Disponibilidad | `getDisponibilidadByProfesorId(Long id)` |
| Reemplazar Disponibilidad | `replaceDisponibilidadProfesor(Long id, List<DisponibilidadHoraria> disponibilidad)` |
| Inserción de Horario con Asignaciones | `insertHorario(Horario h)` (Operación batch/transaccional) |

### Nuevos Endpoints

Los nuevos endpoints para manejo de relaciones se detallan en la [Sección 6](#endpoints-clave).

## Frontend (Flutter Web)

La interfaz de usuario se construye en Flutter Web, proporcionando una experiencia de usuario única y adaptable.

### Servicios de Frontend

- **ApiService**: Cliente REST genérico para el backend de Spring Boot.
- **ProfesorService**: Lógica específica para cargar y manipular la disponibilidad y materias asignadas de los profesores.
- **GeminiService**: Encargado de la llamada al endpoint `/horarios/generar` y de manejar los estados de carga y error.

### Pantallas Principales

- **Materias, Aulas, Profesores**: Vistas de gestión y edición (CRUD).
- **Horarios**: Listado de horarios generados y vista de detalle (tabla).
- **Generación con IA**: Vista de configuración y ejecución del proceso de IA, mostrando el JSON resultante.

### Cambios Recientes de UI

- Implementación de un `MultiSelectDropdown` para asignar materias a profesores.
- Creación de un widget de **Editor de Disponibilidad** dinámico (Grid de días y horas).

## Flujo de IA (Gemini)

La generación de horarios es el corazón del sistema. El `GeminiService` en el backend construye un prompt detallado que incluye todas las restricciones y entidades.

### Entrada a Gemini (Prompt)

- Lista completa de todas las **Materias** (con `horasSemanales`).
- Lista de todas las **Aulas** (con `capacidad` y `tipoAula`).
- Lista de todos los **Profesores** (con sus materias asignadas y su disponibilidad horaria).
- **Instrucción Clave**: "Genera un horario completo intentando usar el menor número de profesores posible, sin solapamientos, respetando las horas semanales de la materia y la disponibilidad del profesor. La respuesta debe ser SOLO un objeto JSON que siga el esquema provisto."

### Salida Requerida de Gemini

La IA debe devolver solo JSON con la estructura del modelo `Horario` y sus asignaciones.
```json
{
  "nombre": "Horario Propuesto (IA)",
  "descripcion": "Propuesta generada por Gemini basada en las restricciones actuales.",
  "fechaCreacion": "2025-10-28T10:00:00Z",
  "asignaciones": [
    {
      "materiaId": 1,
      "profesorId": 2,
      "aulaId": 3,
      "dia": "Lunes",
      "horaInicio": "08:00",
      "horaFin": "10:00"
    },
    {
      "materiaId": 4,
      "profesorId": 1,
      "aulaId": 1,
      "dia": "Martes",
      "horaInicio": "14:00",
      "horaFin": "16:00"
    }
  ]
}
```

## Endpoints Clave

**Base URL**: `http://localhost:8081/api`

| Recurso | Método | Endpoint | Descripción |
|---------|--------|----------|-------------|
| Materias | GET/POST/PUT/DELETE | `/materias` | Gestión de materias. |
| Profesores | GET/POST/PUT/DELETE | `/profesores` | Gestión de profesores. |
| Aulas | GET/POST/PUT/DELETE | `/aulas` | Gestión de aulas. |
| Horarios | GET/POST/PUT/DELETE | `/horarios` | Gestión de horarios generados. |
| IA Generación | POST | `/horarios/generar` | Llama a Gemini para generar la propuesta horaria. |
| Materias de Profesor | GET/PUT | `/profesores/{id}/materias` | Obtener/Reemplazar IDs de materias asignadas. |
| Disponibilidad de Profesor | GET/PUT | `/profesores/{id}/disponibilidad` | Obtener/Reemplazar disponibilidad horaria. |

## Modelos de Datos Principales

### Profesor

- `id` (Long)
- `nombre` (String)
- `apellido` (String)
- `email` (String)
- `horasDisponibles` (Integer)
- `materias` (Lista de IDs/Objetos Materia - via `profesor_materia`)
- `disponibilidad` (Lista de `DisponibilidadHoraria` - via `disponibilidad_profesor`)

### Materia

- `id` (Long)
- `nombre` (String)
- `horasSemanales` (Integer)
- `descripcion` (String)
- `tipoAulaEspecial` (String, opcional)

### Aula

- `id` (Long)
- `nombre` (String)
- `capacidad` (Integer)
- `esEspecial` (Boolean)
- `tipoAula` (String, e.g., 'Laboratorio', 'Aula Magna')

### Horario

- `id` (Long)
- `nombre` (String)
- `descripcion` (String)
- `fechaCreacion` (OffsetDateTime)
- `asignaciones` (Lista de `AsignacionHoraria` - via `asignaciones_horarias`)

## Puesta en Marcha

### Backend (Spring Boot)

1. Asegurar que las variables de entorno para Supabase URL y Service Role Key estén configuradas.

2. Compilar el proyecto:
```bash
mvn -q -DskipTests package
```

3. Ejecutar el JAR resultante:
```bash
java -jar Backend/target/generador-0.0.1-SNAPSHOT.jar
```

### Frontend (Flutter Web)

1. Asegurar que el backend esté corriendo en `http://localhost:8081`.

2. Ejecutar la aplicación web:
```bash
flutter run -d web-server --web-port 5230 --web-hostname 127.0.0.1
```

3. La aplicación estará accesible en `http://127.0.0.1:5230`.

## Pruebas Rápidas

Asumiendo que existe un profesor con `id=1`.

### Obtener materias asignadas a un profesor
```bash
curl http://localhost:8081/api/profesores/1/materias
```

### Obtener disponibilidad horaria de un profesor
```bash
curl http://localhost:8081/api/profesores/1/disponibilidad
```

### Generar un horario (Ejemplo)
```bash
curl -X POST http://localhost:8081/api/horarios/generar \
-H "Content-Type: application/json" \
-d "{}"
# Respuesta esperada: Objeto JSON de Horario generado por Gemini.
```

## Solución de Problemas

| Problema | Causa más Común | Solución Sugerida |
|----------|-----------------|-------------------|
| 401/403 con Supabase | Error en la Service Role Key o URL. | Verificar las variables de entorno del backend (Spring Boot). |
| JSON inválido desde IA | El prompt no es lo suficientemente estricto con el formato de salida. | Revisar la instrucción `systemInstruction` en el `GeminiService` para forzar la respuesta JSON. |
| 404 en endpoints de relaciones | ID de profesor no existe o error en la URL del endpoint. | Verificar el ID y asegurar que el endpoint sea `/profesores/{id}/....` |
| No se guardan asignaciones | Los ID de `materiaId`, `profesorId` o `aulaId` en el JSON de la IA no son válidos. | Implementar validación de IDs en el backend antes de la inserción. |

## Hoja de Ruta

- **Prioridad Alta**: Validar rangos de disponibilidad y la lógica horaria en la UI (Flutter) para evitar envíos de datos inconsistentes.
- **Prioridad Media**: Crear una vista detallada del profesor que consolide toda su información (materias, disponibilidad, horarios asignados).
- **Prioridad Media**: Implementación de métricas y detección de conflictos en el Horario generado antes de la persistencia final (p. ej., un profesor en dos aulas al mismo tiempo).
- **Prioridad Baja**: Cobertura de Tests automatizados (Unitarias y de Integración).
