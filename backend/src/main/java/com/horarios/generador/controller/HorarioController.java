package com.horarios.generador.controller;

import com.horarios.generador.model.Horario;
import com.horarios.generador.service.HorarioService;
import com.horarios.generador.service.SupabaseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/horarios")
@CrossOrigin(origins = "*")
public class HorarioController {

    private final HorarioService horarioService;
    private final SupabaseService supabaseService;

    @Autowired
    public HorarioController(HorarioService horarioService, SupabaseService supabaseService) {
        this.horarioService = horarioService;
        this.supabaseService = supabaseService;
    }

    @GetMapping
    public ResponseEntity<List<Horario>> getAllHorarios() {
        return ResponseEntity.ok(supabaseService.getAllHorarios());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Horario> getHorarioById(@PathVariable Long id) {
        Horario h = supabaseService.getHorarioById(id);
        if (h == null) return ResponseEntity.notFound().build();
        return ResponseEntity.ok(h);
    }

    @PostMapping
    public ResponseEntity<Horario> createHorario(@RequestBody Horario horario) {
        Horario created = supabaseService.insertHorario(horario);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Horario> updateHorario(@PathVariable Long id, @RequestBody Horario horario) {
        horario.setId(id);
        Horario updated = supabaseService.updateHorario(id, horario);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteHorario(@PathVariable Long id) {
        supabaseService.deleteHorario(id);
        return ResponseEntity.noContent().build();
    }
    
    @PostMapping("/generar")
    public ResponseEntity<Horario> generarHorario(@RequestBody Map<String, List<Long>> datos) {
        List<Long> materiaIds = datos.get("materiaIds");
        List<Long> profesorIds = datos.get("profesorIds");
        List<Long> aulaIds = datos.get("aulaIds");
        
        Horario horarioGenerado = horarioService.generarHorarioConIA(materiaIds, profesorIds, aulaIds);
        Horario creado = supabaseService.insertHorario(horarioGenerado);
        return new ResponseEntity<>(creado, HttpStatus.CREATED);
    }
}
