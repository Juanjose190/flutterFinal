package com.flutterfinal.demo.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.*;
import java.util.Map;
import java.util.List;

@Service
public class GeminiService {

    @Value("${gemini.api.key}")
    private String apiKey;  // ← SIN static

    // Gemini Flash es gratuito y rápido
    private final String API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-thinking-exp:generateContent";

    public String generarHorario(String prompt) {
        RestTemplate restTemplate = new RestTemplate();

        String urlWithKey = API_URL + "?key=" + apiKey;

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        Map<String, Object> part = Map.of("text", prompt);
        Map<String, Object> content = Map.of("parts", List.of(part));
        Map<String, Object> requestBody = Map.of("contents", List.of(content));

        HttpEntity<Map<String, Object>> request = new HttpEntity<>(requestBody, headers);

        try {
            ResponseEntity<Map> response = restTemplate.exchange(
                    urlWithKey,
                    HttpMethod.POST,
                    request,
                    Map.class
            );

            Map<String, Object> responseBody = response.getBody();

            List<Map<String, Object>> candidates = (List<Map<String, Object>>) responseBody.get("candidates");
            if (candidates != null && !candidates.isEmpty()) {
                Map<String, Object> firstCandidate = candidates.get(0);
                Map<String, Object> content2 = (Map<String, Object>) firstCandidate.get("content");
                List<Map<String, Object>> parts = (List<Map<String, Object>>) content2.get("parts");
                if (parts != null && !parts.isEmpty()) {
                    Map<String, Object> firstPart = parts.get(0);
                    String text = (String) firstPart.get("text");

                    // Limpiar markdown si viene con ```json
                    text = text.replaceAll("```json\\n", "").replaceAll("```", "").trim();

                    return text;
                }
            }

            return "Error: No se pudo generar horario";
        } catch (Exception e) {
            return "Error al generar horario: " + e.getMessage();
        }
    }

    public String construirPrompt(String profesores, String materias, String aulas, String restricciones) {  // ← SIN static
        return String.format("""
            Eres un experto en diseño de horarios académicos. Genera un horario académico en formato JSON válido.
            
            INFORMACIÓN:
            Profesores disponibles: %s
            Materias a asignar: %s
            Aulas disponibles: %s
            Restricciones adicionales: %s
            
            REGLAS OBLIGATORIAS:
            1. El horario debe cubrir de lunes a viernes
            2. Horario de 8:00 AM a 6:00 PM
            3. Cada clase debe durar mínimo 2 horas
            4. NO puede haber conflictos: un profesor NO puede estar en dos lugares al mismo tiempo
            5. NO puede haber conflictos: un aula NO puede tener dos clases simultáneas
            6. Asignar materias SOLO a profesores que las imparten
            7. Respetar las horas semanales de cada materia
            8. Dejar espacios de descanso entre clases
            
            FORMATO DE SALIDA (JSON):
            Responde ÚNICAMENTE con este formato JSON, sin texto adicional, sin markdown, sin explicaciones:
            
            {
              "horario": [
                {
                  "dia": "Lunes",
                  "hora_inicio": "08:00",
                  "hora_fin": "10:00",
                  "materia": "Nombre de la materia",
                  "codigo_materia": "Código",
                  "profesor": "Nombre del profesor",
                  "aula": "Nombre del aula"
                }
              ],
              "resumen": {
                "total_clases": 0,
                "horas_cubiertas": 0,
                "conflictos": []
              }
            }
            
            IMPORTANTE: Responde SOLO con el JSON, nada más.
            """, profesores, materias, aulas, restricciones);
    }
}