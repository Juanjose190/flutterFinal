# Ejemplos POST (raw JSON) para Postman

Base URL: `http://localhost:8080/api`

Contenido preparado para usar en Postman con Body `raw` → `JSON` y header `Content-Type: application/json`.

---

Endpoint: `POST /materias`

Body JSON:

```
{
  "nombre": "Matemáticas I",
  "horasSemanales": 4,
  "descripcion": "Cálculo diferencial básico",
  "requiereAulaEspecial": false,
  "tipoAulaEspecial": null
}
```

---

Endpoint: `POST /profesores`

Body JSON (admite materias como lista de IDs y disponibilidad opcional):

```
{
  "nombre": "Ana",
  "apellido": "Pérez",
  "email": "ana.perez@colegio.edu",
  "horasDisponibles": 20,
  "materias": [1, 2],
  "disponibilidad": [
    { "dia": "Lunes", "horaInicio": "08:00", "horaFin": "12:00" },
    { "dia": "Miércoles", "horaInicio": "10:00", "horaFin": "14:00" }
  ]
}
```

Notas:
- Puedes omitir `materias` y `disponibilidad` si aún no tienes IDs creados.
- Los IDs referenciados deben existir previamente.

---

Endpoint: `POST /aulas`

Body JSON:

```
{
  "nombre": "Aula 101",
  "capacidad": 30,
  "esEspecial": false,
  "tipoAula": null
}
```

---

Endpoint: `POST /horarios`

Body JSON (con asignaciones que referencian IDs existentes):

```
{
  "nombre": "Horario Semana 1",
  "descripcion": "Prueba de asignaciones",
  "asignaciones": [
    {
      "materia": { "id": 1 },
      "profesor": { "id": 1 },
      "aula": { "id": 1 },
      "dia": "Lunes",
      "horaInicio": "08:00",
      "horaFin": "09:00"
    },
    {
      "materia": { "id": 2 },
      "profesor": { "id": 1 },
      "aula": { "id": 1 },
      "dia": "Miércoles",
      "horaInicio": "10:00",
      "horaFin": "11:00"
    }
  ]
}
```

---

Consultas rápidas (GET):
- `GET /materias`
- `GET /profesores`
- `GET /aulas`
- `GET /horarios`

---

Notas de entorno:
- Perfil `dev`: guarda en H2 en memoria. Para Supabase/PostgreSQL, iniciar el backend con el perfil por defecto (sin `SPRING_PROFILES_ACTIVE=dev`).
- Asegúrate de usar `http://localhost:8080/api` como base en Postman.
