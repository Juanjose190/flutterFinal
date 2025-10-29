# Generador de Horarios

Aplicación para gestionar materias, profesores, aulas y generar horarios académicos completos.  
La aplicación utiliza IA (Gemini) para proponer horarios válidos en función de las entidades registradas y sus restricciones.

---

## Índice
1. Visión General
2. Arquitectura
3. Backend (Spring Boot)
4. Frontend (Flutter Web)
5. Flujo de IA (Gemini)
6. Endpoints Clave
7. Modelos de Datos
8. Puesta en Marcha
9. Pruebas Rápidas
10. Solución de Problemas
11. Hoja de Ruta

---

## 1. Visión General

La aplicación permite:

- Registrar Materias, Profesores y Aulas.
- Registrar la disponibilidad horaria de los profesores.
- Relacionar profesores con materias.
- Generar horarios académicos basados en estas entidades.
- Utilizar una IA (Gemini) para sugerir asignaciones horarias válidas en formato JSON.

Base de datos: **Supabase (PostgreSQL + PostgREST)**  
Persistencia accesible desde backend y frontend.

### Cambios recientes:
- Persistencia real de relaciones `profesor_materia` y `disponibilidad_profesor`.
- Endpoints GET/PUT para manejar estas relaciones.
- UI mejorada para seleccionar materias y editar disponibilidad.
- Inserción de datos en `asignaciones_horarias` al crear horarios.

---

## 2. Arquitectura

Monorepo:
