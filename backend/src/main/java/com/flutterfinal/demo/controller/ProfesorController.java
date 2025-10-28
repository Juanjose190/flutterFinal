package com.flutterfinal.demo.controller;

import com.flutterfinal.demo.model.*;
import com.flutterfinal.demo.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

// ============== PROFESORES ==============
@RestController
@RequestMapping("/api/profesores")
public class ProfesorController {

    @Autowired
    private ProfesorRepository profesorRepo;

    @GetMapping
    public List<Profesor> obtenerTodos() {
        return profesorRepo.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Profesor> obtenerPorId(@PathVariable Long id) {
        return profesorRepo.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public Profesor crear(@RequestBody Profesor profesor) {
        return profesorRepo.save(profesor);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Profesor> actualizar(@PathVariable Long id, @RequestBody Profesor profesor) {
        return profesorRepo.findById(id)
                .map(p -> {
                    p.setNombre(profesor.getNombre());
                    p.setEmail(profesor.getEmail());
                    p.setMateriasQueImparte(profesor.getMateriasQueImparte());
                    p.setHorariosDisponibles(profesor.getHorariosDisponibles());
                    return ResponseEntity.ok(profesorRepo.save(p));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> eliminar(@PathVariable Long id) {
        return profesorRepo.findById(id)
                .map(p -> {
                    profesorRepo.delete(p);
                    return ResponseEntity.ok().build();
                })
                .orElse(ResponseEntity.notFound().build());
    }
}