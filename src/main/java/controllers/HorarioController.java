package controllers;
import dto.HorarioRequest;
import dto.HorarioResponse;
import modelos.*;
import repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import services.HorarioService;

import java.util.List;

@RestController
@RequestMapping("/api/horarios")
class HorarioController {

    @Autowired
    private HorarioService horarioService;

    @PostMapping("/generar")
    public ResponseEntity<HorarioResponse> generarHorario(@RequestBody HorarioRequest request) {
        try {
            HorarioResponse response = horarioService.generarHorario(request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    @GetMapping
    public List<Horario> obtenerTodos() {
        return horarioService.obtenerTodos();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Horario> obtenerPorId(@PathVariable Long id) {
        Horario horario = horarioService.obtenerPorId(id);
        return horario != null ? ResponseEntity.ok(horario) : ResponseEntity.notFound().build();
    }

    @PutMapping("/{id}/estado")
    public ResponseEntity<?> actualizarEstado(@PathVariable Long id, @RequestParam String estado) {
        try {
            horarioService.actualizarEstado(id, estado);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }
}