package com.horarios.generador.service;

import com.horarios.generador.model.Aula;
import com.horarios.generador.model.Horario;
import com.horarios.generador.model.Materia;
import com.horarios.generador.model.Profesor;
import com.horarios.generador.model.AsignacionHoraria;
import com.horarios.generador.model.DisponibilidadHoraria;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.ArrayList;

import org.springframework.web.client.RestClientException;

@Service
public class SupabaseService {

    private static final Logger log = LoggerFactory.getLogger(SupabaseService.class);

    @Value("${supabase.url}")
    private String supabaseUrl;

    @Value("${supabase.service-role}")
    private String supabaseKey;

    private final RestTemplate restTemplate = new RestTemplate();
    private final com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();

    private HttpHeaders buildHeaders() {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        // Autorización correcta para Supabase REST
        headers.set("apikey", supabaseKey);
        headers.set("Authorization", "Bearer " + supabaseKey);
        headers.set("Prefer", "return=representation");

        return headers;
    }

    private String tableUrl(String table) {
        return supabaseUrl + "/rest/v1/" + table;
    }

    // -----------------------------
    // Helpers for type conversions
    // -----------------------------
    private Long asLong(Object v) {
        if (v == null) return null;
        if (v instanceof Number) return ((Number) v).longValue();
        try { return Long.parseLong(v.toString()); } catch (Exception e) { return null; }
    }

    private Integer asInteger(Object v) {
        if (v == null) return null;
        if (v instanceof Number) return ((Number) v).intValue();
        try { return Integer.parseInt(v.toString()); } catch (Exception e) { return null; }
    }

    private Boolean asBoolean(Object v) {
        if (v == null) return null;
        if (v instanceof Boolean) return (Boolean) v;
        if (v instanceof Number) return ((Number) v).intValue() != 0;
        String s = v.toString().trim();
        if ("true".equalsIgnoreCase(s) || "t".equalsIgnoreCase(s) || "1".equals(s)) return true;
        if ("false".equalsIgnoreCase(s) || "f".equalsIgnoreCase(s) || "0".equals(s)) return false;
        return null;
    }

    private LocalDateTime parseDateTime(Object v) {
        if (v == null) return null;
        String s = v.toString();
        try {
            // Try ISO first (default from Spring serialization)
            return LocalDateTime.parse(s);
        } catch (Exception ignore) {}
        try {
            // Fallback to space-separated format used when inserting into Supabase
            return LocalDateTime.parse(s, DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        } catch (Exception ignore) {}
        return null;
    }

    // -----------------------------
    // Mapping helpers from Supabase rows
    // -----------------------------
    private Materia mapMateria(Map<String, Object> row) {
        Materia m = new Materia();
        m.setId(asLong(row.get("id")));
        m.setNombre((String) row.get("nombre"));
        m.setHorasSemanales(asInteger(row.get("horas_semanales")));
        m.setDescripcion((String) row.get("descripcion"));
        m.setRequiereAulaEspecial(asBoolean(row.get("requiere_aula_especial")));
        m.setTipoAulaEspecial((String) row.get("tipo_aula_especial"));
        return m;
    }

    private Aula mapAula(Map<String, Object> row) {
        Aula a = new Aula();
        a.setId(asLong(row.get("id")));
        a.setNombre((String) row.get("nombre"));
        a.setCapacidad(asInteger(row.get("capacidad")));
        a.setEsEspecial(asBoolean(row.get("es_especial")));
        a.setTipoAula((String) row.get("tipo_aula"));
        return a;
    }

    private Profesor mapProfesor(Map<String, Object> row) {
        Profesor p = new Profesor();
        p.setId(asLong(row.get("id")));
        p.setNombre((String) row.get("nombre"));
        p.setApellido((String) row.get("apellido"));
        p.setEmail((String) row.get("email"));
        p.setHorasDisponibles(asInteger(row.get("horas_disponibles")));
        // Relaciones (materias, disponibilidad) no se incluyen por ahora
        return p;
    }

    private Horario mapHorario(Map<String, Object> row) {
        Horario h = new Horario();
        h.setId(asLong(row.get("id")));
        h.setNombre((String) row.get("nombre"));
        h.setDescripcion((String) row.get("descripcion"));
        h.setFechaCreacion(parseDateTime(row.get("fecha_creacion")));
        // Asignaciones no se incluyen en esta versión
        return h;
    }

    private <T> List<T> parseList(String body, java.util.function.Function<Map<String, Object>, T> mapperFn) {
        try {
            if (body == null || body.isEmpty()) return List.of();
            List<Map<String, Object>> list = mapper.readValue(body, new com.fasterxml.jackson.core.type.TypeReference<List<Map<String, Object>>>() {});
            List<T> out = new ArrayList<>();
            for (Map<String, Object> row : list) {
                out.add(mapperFn.apply(row));
            }
            return out;
        } catch (Exception e) {
            log.error("Error parsing Supabase response: {}", e.getMessage());
            return List.of();
        }
    }

    private <T> T parseSingle(String body, java.util.function.Function<Map<String, Object>, T> mapperFn) {
        try {
            if (body == null || body.isEmpty()) return null;
            List<Map<String, Object>> list = mapper.readValue(body, new com.fasterxml.jackson.core.type.TypeReference<List<Map<String, Object>>>() {});
            if (list.isEmpty()) return null;
            return mapperFn.apply(list.get(0));
        } catch (Exception e) {
            log.error("Error parsing Supabase single response: {}", e.getMessage());
            return null;
        }
    }

    // -----------------------------
    // Mapping: Asignaciones Horarias
    // -----------------------------
    private AsignacionHoraria mapAsignacion(Map<String, Object> row) {
        AsignacionHoraria a = new AsignacionHoraria();
        a.setId(asLong(row.get("id")));

        Materia m = new Materia();
        m.setId(asLong(row.get("materia_id")));
        a.setMateria(m);

        Profesor p = new Profesor();
        p.setId(asLong(row.get("profesor_id")));
        a.setProfesor(p);

        Aula au = new Aula();
        au.setId(asLong(row.get("aula_id")));
        a.setAula(au);

        a.setDia((String) row.get("dia"));
        a.setHoraInicio((String) row.get("hora_inicio"));
        a.setHoraFin((String) row.get("hora_fin"));
        return a;
    }

    private Map<String, Object> asignacionToRow(Long horarioId, AsignacionHoraria a) {
        Map<String, Object> row = new HashMap<>();
        row.put("horario_id", horarioId);
        if (a.getMateria() != null) row.put("materia_id", a.getMateria().getId());
        if (a.getProfesor() != null) row.put("profesor_id", a.getProfesor().getId());
        if (a.getAula() != null) row.put("aula_id", a.getAula().getId());
        row.put("dia", a.getDia());
        row.put("hora_inicio", a.getHoraInicio());
        row.put("hora_fin", a.getHoraFin());
        return row;
    }

    // -----------------------------
    // Helpers: relaciones Profesor
    // -----------------------------
    private Map<String, Object> linkProfesorMateriaRow(Long profesorId, Long materiaId) {
        Map<String, Object> row = new HashMap<>();
        row.put("profesor_id", profesorId);
        row.put("materia_id", materiaId);
        return row;
    }

    private Map<String, Object> disponibilidadToRow(Long profesorId, DisponibilidadHoraria d) {
        Map<String, Object> row = new HashMap<>();
        row.put("profesor_id", profesorId);
        row.put("dia", d.getDia());
        row.put("hora_inicio", d.getHoraInicio());
        row.put("hora_fin", d.getHoraFin());
        return row;
    }

    // -----------------------------
    // GET asignaciones por horario
    // -----------------------------
    public List<AsignacionHoraria> getAsignacionesByHorarioId(Long horarioId) {
        try {
            HttpEntity<Void> entity = new HttpEntity<>(buildHeaders());
            ResponseEntity<String> resp = restTemplate.exchange(
                tableUrl("asignaciones_horarias") + "?horario_id=eq." + horarioId,
                HttpMethod.GET,
                entity,
                String.class
            );
            log.info("✅ Supabase → Get asignaciones by horario | Status: {}", resp.getStatusCode());
            return parseList(resp.getBody(), this::mapAsignacion);
        } catch (RestClientException e) {
            log.error("❌ Error al obtener asignaciones por horario en Supabase: {}", e.getMessage());
            throw e;
        }
    }

    // -----------------------------
    // INSERT asignaciones (batch)
    // -----------------------------
    public List<AsignacionHoraria> insertAsignaciones(Long horarioId, List<AsignacionHoraria> asignaciones) {
        if (asignaciones == null || asignaciones.isEmpty()) return List.of();
        try {
            List<Map<String, Object>> rows = new ArrayList<>();
            for (AsignacionHoraria a : asignaciones) {
                rows.add(asignacionToRow(horarioId, a));
            }
            HttpEntity<List<Map<String, Object>>> entity = new HttpEntity<>(rows, buildHeaders());
            ResponseEntity<String> resp = restTemplate.postForEntity(tableUrl("asignaciones_horarias"), entity, String.class);
            log.info("✅ Supabase → Insert asignaciones (batch) | Status: {}", resp.getStatusCode());
            // Devolver las asignaciones con IDs asignados por Supabase
            List<AsignacionHoraria> inserted = parseList(resp.getBody(), this::mapAsignacion);
            // Sincronizar los IDs recién creados (por posición) si tamaños coinciden
            if (inserted.size() == asignaciones.size()) {
                for (int i = 0; i < inserted.size(); i++) {
                    AsignacionHoraria src = asignaciones.get(i);
                    AsignacionHoraria ret = inserted.get(i);
                    src.setId(ret.getId());
                }
            }
            return inserted;
        } catch (RestClientException e) {
            log.error("❌ Error al insertar asignaciones en Supabase: {}", e.getMessage());
            throw e;
        }
    }

    // -----------------------------
    // GET: Materia IDs por profesor
    // -----------------------------
    public List<Long> getMateriaIdsByProfesorId(Long profesorId) {
        try {
            HttpEntity<Void> entity = new HttpEntity<>(buildHeaders());
            ResponseEntity<String> resp = restTemplate.exchange(
                tableUrl("profesor_materia") + "?profesor_id=eq." + profesorId,
                HttpMethod.GET,
                entity,
                String.class
            );
            log.info("✅ Supabase → Get profesor_materia by profesor | Status: {}", resp.getStatusCode());
            List<Map<String, Object>> rows = parseList(resp.getBody(), x -> x);
            List<Long> ids = new ArrayList<>();
            for (Map<String, Object> r : rows) {
                Long mid = asLong(r.get("materia_id"));
                if (mid != null) ids.add(mid);
            }
            return ids;
        } catch (RestClientException e) {
            log.error("❌ Error al obtener profesor_materia en Supabase: {}", e.getMessage());
            throw e;
        }
    }

    // Reemplaza vínculos profesor_materia de un profesor
    public void replaceProfesorMaterias(Long profesorId, List<Long> materiaIds) {
        if (profesorId == null) return;
        try {
            // 1) Eliminar existentes
            HttpEntity<Void> delEntity = new HttpEntity<>(buildHeaders());
            ResponseEntity<String> delResp = restTemplate.exchange(
                tableUrl("profesor_materia") + "?profesor_id=eq." + profesorId,
                HttpMethod.DELETE,
                delEntity,
                String.class
            );
            log.info("✅ Supabase → Delete profesor_materia (profesor={}) | Status: {}", profesorId, delResp.getStatusCode());

            // 2) Insertar nuevos (si hay)
            if (materiaIds != null && !materiaIds.isEmpty()) {
                List<Map<String, Object>> rows = new ArrayList<>();
                for (Long mid : materiaIds) {
                    rows.add(linkProfesorMateriaRow(profesorId, mid));
                }
                HttpEntity<List<Map<String, Object>>> insEntity = new HttpEntity<>(rows, buildHeaders());
                ResponseEntity<String> insResp = restTemplate.postForEntity(
                    tableUrl("profesor_materia"), insEntity, String.class
                );
                log.info("✅ Supabase → Insert profesor_materia ({} filas) | Status: {}", rows.size(), insResp.getStatusCode());
            }
        } catch (RestClientException e) {
            log.error("❌ Error al reemplazar profesor_materia en Supabase: {}", e.getMessage());
            throw e;
        }
    }

    // -----------------------------
    // GET: Disponibilidad por profesor
    // -----------------------------
    public List<DisponibilidadHoraria> getDisponibilidadByProfesorId(Long profesorId) {
        try {
            HttpEntity<Void> entity = new HttpEntity<>(buildHeaders());
            ResponseEntity<String> resp = restTemplate.exchange(
                tableUrl("disponibilidad_profesor") + "?profesor_id=eq." + profesorId,
                HttpMethod.GET,
                entity,
                String.class
            );
            log.info("✅ Supabase → Get disponibilidad_profesor by profesor | Status: {}", resp.getStatusCode());
            return parseList(resp.getBody(), row -> {
                DisponibilidadHoraria d = new DisponibilidadHoraria();
                d.setDia((String) row.get("dia"));
                d.setHoraInicio((String) row.get("hora_inicio"));
                d.setHoraFin((String) row.get("hora_fin"));
                return d;
            });
        } catch (RestClientException e) {
            log.error("❌ Error al obtener disponibilidad_profesor en Supabase: {}", e.getMessage());
            throw e;
        }
    }

    // Reemplaza disponibilidad de un profesor
    public void replaceDisponibilidadProfesor(Long profesorId, List<DisponibilidadHoraria> disponibilidad) {
        if (profesorId == null) return;
        try {
            // 1) Eliminar existentes
            HttpEntity<Void> delEntity = new HttpEntity<>(buildHeaders());
            ResponseEntity<String> delResp = restTemplate.exchange(
                tableUrl("disponibilidad_profesor") + "?profesor_id=eq." + profesorId,
                HttpMethod.DELETE,
                delEntity,
                String.class
            );
            log.info("✅ Supabase → Delete disponibilidad_profesor (profesor={}) | Status: {}", profesorId, delResp.getStatusCode());

            // 2) Insertar nuevos (si hay)
            if (disponibilidad != null && !disponibilidad.isEmpty()) {
                List<Map<String, Object>> rows = new ArrayList<>();
                for (DisponibilidadHoraria d : disponibilidad) {
                    rows.add(disponibilidadToRow(profesorId, d));
                }
                HttpEntity<List<Map<String, Object>>> insEntity = new HttpEntity<>(rows, buildHeaders());
                ResponseEntity<String> insResp = restTemplate.postForEntity(
                    tableUrl("disponibilidad_profesor"), insEntity, String.class
                );
                log.info("✅ Supabase → Insert disponibilidad_profesor ({} filas) | Status: {}", rows.size(), insResp.getStatusCode());
            }
        } catch (RestClientException e) {
            log.error("❌ Error al reemplazar disponibilidad_profesor en Supabase: {}", e.getMessage());
            throw e;
        }
    }

    // -----------------------------
    // GET: Materias
    // -----------------------------
    public List<Materia> getAllMaterias() {
        try {
            HttpEntity<Void> entity = new HttpEntity<>(buildHeaders());
            ResponseEntity<String> resp = restTemplate.exchange(tableUrl("materias"), HttpMethod.GET, entity, String.class);
            log.info("✅ Supabase → Get all materias | Status: {}", resp.getStatusCode());
            return parseList(resp.getBody(), this::mapMateria);
        } catch (RestClientException e) {
            log.error("❌ Error al obtener materias de Supabase: {}", e.getMessage());
            throw e;
        }
    }

    public Materia getMateriaById(Long id) {
        try {
            HttpEntity<Void> entity = new HttpEntity<>(buildHeaders());
            ResponseEntity<String> resp = restTemplate.exchange(tableUrl("materias") + "?id=eq." + id, HttpMethod.GET, entity, String.class);
            log.info("✅ Supabase → Get materia by id | Status: {}", resp.getStatusCode());
            return parseSingle(resp.getBody(), this::mapMateria);
        } catch (RestClientException e) {
            log.error("❌ Error al obtener materia por id en Supabase: {}", e.getMessage());
            throw e;
        }
    }

    // -----------------------------
    // GET: Aulas
    // -----------------------------
    public List<Aula> getAllAulas() {
        try {
            HttpEntity<Void> entity = new HttpEntity<>(buildHeaders());
            ResponseEntity<String> resp = restTemplate.exchange(tableUrl("aulas"), HttpMethod.GET, entity, String.class);
            log.info("✅ Supabase → Get all aulas | Status: {}", resp.getStatusCode());
            return parseList(resp.getBody(), this::mapAula);
        } catch (RestClientException e) {
            log.error("❌ Error al obtener aulas de Supabase: {}", e.getMessage());
            throw e;
        }
    }

    public Aula getAulaById(Long id) {
        try {
            HttpEntity<Void> entity = new HttpEntity<>(buildHeaders());
            ResponseEntity<String> resp = restTemplate.exchange(tableUrl("aulas") + "?id=eq." + id, HttpMethod.GET, entity, String.class);
            log.info("✅ Supabase → Get aula by id | Status: {}", resp.getStatusCode());
            return parseSingle(resp.getBody(), this::mapAula);
        } catch (RestClientException e) {
            log.error("❌ Error al obtener aula por id en Supabase: {}", e.getMessage());
            throw e;
        }
    }

    // -----------------------------
    // GET: Profesores
    // -----------------------------
    public List<Profesor> getAllProfesores() {
        try {
            HttpEntity<Void> entity = new HttpEntity<>(buildHeaders());
            ResponseEntity<String> resp = restTemplate.exchange(tableUrl("profesores"), HttpMethod.GET, entity, String.class);
            log.info("✅ Supabase → Get all profesores | Status: {}", resp.getStatusCode());
            return parseList(resp.getBody(), this::mapProfesor);
        } catch (RestClientException e) {
            log.error("❌ Error al obtener profesores de Supabase: {}", e.getMessage());
            throw e;
        }
    }

    public Profesor getProfesorById(Long id) {
        try {
            HttpEntity<Void> entity = new HttpEntity<>(buildHeaders());
            ResponseEntity<String> resp = restTemplate.exchange(tableUrl("profesores") + "?id=eq." + id, HttpMethod.GET, entity, String.class);
            log.info("✅ Supabase → Get profesor by id | Status: {}", resp.getStatusCode());
            return parseSingle(resp.getBody(), this::mapProfesor);
        } catch (RestClientException e) {
            log.error("❌ Error al obtener profesor por id en Supabase: {}", e.getMessage());
            throw e;
        }
    }

    // -----------------------------
    // GET: Horarios
    // -----------------------------
    public List<Horario> getAllHorarios() {
        try {
            HttpEntity<Void> entity = new HttpEntity<>(buildHeaders());
            ResponseEntity<String> resp = restTemplate.exchange(tableUrl("horarios"), HttpMethod.GET, entity, String.class);
            log.info("✅ Supabase → Get all horarios | Status: {}", resp.getStatusCode());
            return parseList(resp.getBody(), this::mapHorario);
        } catch (RestClientException e) {
            log.error("❌ Error al obtener horarios de Supabase: {}", e.getMessage());
            throw e;
        }
    }

    public Horario getHorarioById(Long id) {
        try {
            HttpEntity<Void> entity = new HttpEntity<>(buildHeaders());
            ResponseEntity<String> resp = restTemplate.exchange(tableUrl("horarios") + "?id=eq." + id, HttpMethod.GET, entity, String.class);
            log.info("✅ Supabase → Get horario by id | Status: {}", resp.getStatusCode());
            Horario h = parseSingle(resp.getBody(), this::mapHorario);
            if (h != null) {
                // Cargar asignaciones asociadas desde Supabase
                List<AsignacionHoraria> asign = getAsignacionesByHorarioId(id);
                h.setAsignaciones(asign);
            }
            return h;
        } catch (RestClientException e) {
            log.error("❌ Error al obtener horario por id en Supabase: {}", e.getMessage());
            throw e;
        }
    }

    public Materia insertMateria(Materia m) {
        try {
            Map<String, Object> body = new HashMap<>();
            body.put("nombre", m.getNombre());
            body.put("horas_semanales", m.getHorasSemanales());
            body.put("descripcion", m.getDescripcion());
            body.put("requiere_aula_especial", m.getRequiereAulaEspecial());
            body.put("tipo_aula_especial", m.getTipoAulaEspecial());

            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, buildHeaders());
            ResponseEntity<String> resp = restTemplate.postForEntity(tableUrl("materias"), entity, String.class);
            log.info("✅ Supabase → Insert materia | Status: {}", resp.getStatusCode());
            if (!resp.getStatusCode().is2xxSuccessful()) {
                throw new RestClientException("Supabase insert materia failed: " + resp.getStatusCode());
            }
            Long id = extractId(resp.getBody());
            m.setId(id);
            return m;
        } catch (RestClientException e) {
            log.error("❌ Error al insertar materia en Supabase: {}", e.getMessage());
            throw e;
        }
    }

    public Profesor insertProfesor(Profesor p) {
        try {
            Map<String, Object> body = new HashMap<>();
            body.put("nombre", p.getNombre());
            body.put("apellido", p.getApellido());
            body.put("email", p.getEmail());
            body.put("horas_disponibles", p.getHorasDisponibles());

            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, buildHeaders());
            ResponseEntity<String> resp = restTemplate.postForEntity(tableUrl("profesores"), entity, String.class);
            log.info("✅ Supabase → Insert profesor | Status: {}", resp.getStatusCode());
            if (!resp.getStatusCode().is2xxSuccessful()) {
                throw new RestClientException("Supabase insert profesor failed: " + resp.getStatusCode());
            }
            Long id = extractId(resp.getBody());
            p.setId(id);
            return p;
        } catch (RestClientException e) {
            log.error("❌ Error al insertar profesor en Supabase: {}", e.getMessage());
            throw e;
        }
    }

    public Aula insertAula(Aula a) {
        try {
            Map<String, Object> body = new HashMap<>();
            body.put("nombre", a.getNombre());
            body.put("capacidad", a.getCapacidad());
            body.put("es_especial", a.getEsEspecial());
            body.put("tipo_aula", a.getTipoAula());

            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, buildHeaders());
            ResponseEntity<String> resp = restTemplate.postForEntity(tableUrl("aulas"), entity, String.class);
            log.info("✅ Supabase → Insert aula | Status: {}", resp.getStatusCode());
            if (!resp.getStatusCode().is2xxSuccessful()) {
                throw new RestClientException("Supabase insert aula failed: " + resp.getStatusCode());
            }
            Long id = extractId(resp.getBody());
            a.setId(id);
            return a;
        } catch (RestClientException e) {
            log.error("❌ Error al insertar aula en Supabase: {}", e.getMessage());
            throw e;
        }
    }

    public Horario insertHorario(Horario h) {
        try {
            Map<String, Object> body = new HashMap<>();
            body.put("nombre", h.getNombre());
            body.put("descripcion", h.getDescripcion());

            LocalDateTime fecha = h.getFechaCreacion();
            if (fecha != null) {
                body.put("fecha_creacion", fecha.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
            }

            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, buildHeaders());
            ResponseEntity<String> resp = restTemplate.postForEntity(tableUrl("horarios"), entity, String.class);
            log.info("✅ Supabase → Insert horario | Status: {}", resp.getStatusCode());
            if (!resp.getStatusCode().is2xxSuccessful()) {
                throw new RestClientException("Supabase insert horario failed: " + resp.getStatusCode());
            }
            Long id = extractId(resp.getBody());
            h.setId(id);
            // Insertar asignaciones si existen
            if (h.getAsignaciones() != null && !h.getAsignaciones().isEmpty()) {
                insertAsignaciones(id, h.getAsignaciones());
            }
            return h;
        } catch (RestClientException e) {
            log.error("❌ Error al insertar horario en Supabase: {}", e.getMessage());
            throw e;
        }
    }

    public Materia updateMateria(Long id, Materia m) {
        try {
            Map<String, Object> body = new HashMap<>();
            body.put("nombre", m.getNombre());
            body.put("horas_semanales", m.getHorasSemanales());
            body.put("descripcion", m.getDescripcion());
            body.put("requiere_aula_especial", m.getRequiereAulaEspecial());
            body.put("tipo_aula_especial", m.getTipoAulaEspecial());
            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, buildHeaders());
            ResponseEntity<String> resp = restTemplate.exchange(tableUrl("materias") + "?id=eq." + id, HttpMethod.PATCH, entity, String.class);
            log.info("✅ Supabase → Update materia | Status: {}", resp.getStatusCode());
            m.setId(id);
            return m;
        } catch (RestClientException e) {
            log.error("❌ Error al actualizar materia en Supabase: {}", e.getMessage());
            throw e;
        }
    }

    public void deleteMateria(Long id) {
        try {
            HttpEntity<Void> entity = new HttpEntity<>(buildHeaders());
            ResponseEntity<String> resp = restTemplate.exchange(tableUrl("materias") + "?id=eq." + id, HttpMethod.DELETE, entity, String.class);
            log.info("✅ Supabase → Delete materia | Status: {}", resp.getStatusCode());
        } catch (RestClientException e) {
            log.error("❌ Error al eliminar materia en Supabase: {}", e.getMessage());
            throw e;
        }
    }

    public Aula updateAula(Long id, Aula a) {
        try {
            Map<String, Object> body = new HashMap<>();
            body.put("nombre", a.getNombre());
            body.put("capacidad", a.getCapacidad());
            body.put("es_especial", a.getEsEspecial());
            body.put("tipo_aula", a.getTipoAula());
            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, buildHeaders());
            ResponseEntity<String> resp = restTemplate.exchange(tableUrl("aulas") + "?id=eq." + id, HttpMethod.PATCH, entity, String.class);
            log.info("✅ Supabase → Update aula | Status: {}", resp.getStatusCode());
            a.setId(id);
            return a;
        } catch (RestClientException e) {
            log.error("❌ Error al actualizar aula en Supabase: {}", e.getMessage());
            throw e;
        }
    }

    public void deleteAula(Long id) {
        try {
            HttpEntity<Void> entity = new HttpEntity<>(buildHeaders());
            ResponseEntity<String> resp = restTemplate.exchange(tableUrl("aulas") + "?id=eq." + id, HttpMethod.DELETE, entity, String.class);
            log.info("✅ Supabase → Delete aula | Status: {}", resp.getStatusCode());
        } catch (RestClientException e) {
            log.error("❌ Error al eliminar aula en Supabase: {}", e.getMessage());
            throw e;
        }
    }

    public Profesor updateProfesor(Long id, Profesor p) {
        try {
            Map<String, Object> body = new HashMap<>();
            body.put("nombre", p.getNombre());
            body.put("apellido", p.getApellido());
            body.put("email", p.getEmail());
            body.put("horas_disponibles", p.getHorasDisponibles());
            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, buildHeaders());
            ResponseEntity<String> resp = restTemplate.exchange(tableUrl("profesores") + "?id=eq." + id, HttpMethod.PATCH, entity, String.class);
            log.info("✅ Supabase → Update profesor | Status: {}", resp.getStatusCode());
            p.setId(id);
            return p;
        } catch (RestClientException e) {
            log.error("❌ Error al actualizar profesor en Supabase: {}", e.getMessage());
            throw e;
        }
    }

    public void deleteProfesor(Long id) {
        try {
            HttpEntity<Void> entity = new HttpEntity<>(buildHeaders());
            ResponseEntity<String> resp = restTemplate.exchange(tableUrl("profesores") + "?id=eq." + id, HttpMethod.DELETE, entity, String.class);
            log.info("✅ Supabase → Delete profesor | Status: {}", resp.getStatusCode());
        } catch (RestClientException e) {
            log.error("❌ Error al eliminar profesor en Supabase: {}", e.getMessage());
            throw e;
        }
    }

    public Horario updateHorario(Long id, Horario h) {
        try {
            Map<String, Object> body = new HashMap<>();
            body.put("nombre", h.getNombre());
            body.put("descripcion", h.getDescripcion());
            if (h.getFechaCreacion() != null) {
                body.put("fecha_creacion", h.getFechaCreacion().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
            }
            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, buildHeaders());
            ResponseEntity<String> resp = restTemplate.exchange(tableUrl("horarios") + "?id=eq." + id, HttpMethod.PATCH, entity, String.class);
            log.info("✅ Supabase → Update horario | Status: {}", resp.getStatusCode());
            h.setId(id);
            // Estrategia simple: (opcional) podría actualizar asignaciones aquí
            return h;
        } catch (RestClientException e) {
            log.error("❌ Error al actualizar horario en Supabase: {}", e.getMessage());
            throw e;
        }
    }

    public void deleteHorario(Long id) {
        try {
            HttpEntity<Void> entity = new HttpEntity<>(buildHeaders());
            ResponseEntity<String> resp = restTemplate.exchange(tableUrl("horarios") + "?id=eq." + id, HttpMethod.DELETE, entity, String.class);
            log.info("✅ Supabase → Delete horario | Status: {}", resp.getStatusCode());
        } catch (RestClientException e) {
            log.error("❌ Error al eliminar horario en Supabase: {}", e.getMessage());
            throw e;
        }
    }

    private Long extractId(String body) {
        try {
            if (body == null || body.isEmpty()) return null;
            List<Map<String, Object>> list = mapper.readValue(body, new com.fasterxml.jackson.core.type.TypeReference<List<Map<String, Object>>>() {});
            if (list.isEmpty()) return null;
            Object idVal = list.get(0).get("id");
            if (idVal == null) return null;
            if (idVal instanceof Number) return ((Number) idVal).longValue();
            return Long.parseLong(idVal.toString());
        } catch (Exception e) {
            log.warn("No se pudo extraer ID del response de Supabase: {}", e.getMessage());
            return null;
        }
    }
}
