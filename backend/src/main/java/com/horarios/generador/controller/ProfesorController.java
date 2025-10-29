package com.horarios.generador.controller;

import com.horarios.generador.dto.ProfesorRequest;
import com.horarios.generador.model.Profesor;
import com.horarios.generador.model.DisponibilidadHoraria;
import com.horarios.generador.service.SupabaseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/profesores")
@CrossOrigin(origins = "*")
public class ProfesorController {

    private final SupabaseService supabaseService;

    @Autowired
    public ProfesorController(SupabaseService supabaseService) {
        this.supabaseService = supabaseService;
    }

    @GetMapping
    public ResponseEntity<List<Profesor>> getAllProfesores() {
        return ResponseEntity.ok(supabaseService.getAllProfesores());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Profesor> getProfesorById(@PathVariable Long id) {
        Profesor p = supabaseService.getProfesorById(id);
        if (p == null) return ResponseEntity.notFound().build();
        return ResponseEntity.ok(p);
    }

    @PostMapping
    public ResponseEntity<Profesor> createProfesor(@RequestBody ProfesorRequest req) {
        Profesor profesor = new Profesor();
        profesor.setNombre(req.getNombre());
        profesor.setApellido(req.getApellido());
        profesor.setEmail(req.getEmail());
        profesor.setHorasDisponibles(req.getHorasDisponibles());
        // Disponibilidad se almacena en tabla aparte en Supabase
        profesor.setDisponibilidad(req.getDisponibilidad());
        Profesor created = supabaseService.insertProfesor(profesor);
        // Persistir relaciones y disponibilidad si vienen en request
        if (created != null && created.getId() != null) {
            if (req.getMaterias() != null) {
                supabaseService.replaceProfesorMaterias(created.getId(), req.getMaterias());
            }
            if (req.getDisponibilidad() != null) {
                supabaseService.replaceDisponibilidadProfesor(created.getId(), req.getDisponibilidad());
            }
        }
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Profesor> updateProfesor(@PathVariable Long id, @RequestBody ProfesorRequest req) {
        Profesor p = new Profesor();
        p.setId(id);
        p.setNombre(req.getNombre());
        p.setApellido(req.getApellido());
        p.setEmail(req.getEmail());
        p.setHorasDisponibles(req.getHorasDisponibles());
        p.setDisponibilidad(req.getDisponibilidad());
        Profesor updated = supabaseService.updateProfesor(id, p);
        // Reemplazar relaciones y disponibilidad si vienen en request
        if (req.getMaterias() != null) {
            supabaseService.replaceProfesorMaterias(id, req.getMaterias());
        }
        if (req.getDisponibilidad() != null) {
            supabaseService.replaceDisponibilidadProfesor(id, req.getDisponibilidad());
        }
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProfesor(@PathVariable Long id) {
        supabaseService.deleteProfesor(id);
        return ResponseEntity.noContent().build();
    }

    // ----- Relaciones y disponibilidad -----
    @GetMapping("/{id}/materias")
    public ResponseEntity<List<Long>> getMateriasByProfesor(@PathVariable Long id) {
        return ResponseEntity.ok(supabaseService.getMateriaIdsByProfesorId(id));
    }

    @PutMapping("/{id}/materias")
    public ResponseEntity<Void> replaceMateriasByProfesor(@PathVariable Long id, @RequestBody List<Long> materiaIds) {
        supabaseService.replaceProfesorMaterias(id, materiaIds);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{id}/disponibilidad")
    public ResponseEntity<List<DisponibilidadHoraria>> getDisponibilidadByProfesor(@PathVariable Long id) {
        return ResponseEntity.ok(supabaseService.getDisponibilidadByProfesorId(id));
    }

    @PutMapping("/{id}/disponibilidad")
    public ResponseEntity<Void> replaceDisponibilidadByProfesor(
            @PathVariable Long id,
            @RequestBody List<DisponibilidadHoraria> disponibilidad
    ) {
        supabaseService.replaceDisponibilidadProfesor(id, disponibilidad);
        return ResponseEntity.noContent().build();
    }
}
