package com.horarios.generador.controller;

import com.horarios.generador.model.Materia;
import com.horarios.generador.service.SupabaseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/materias")
@CrossOrigin(origins = "*")
public class MateriaController {

    private final SupabaseService supabaseService;

    @Autowired
    public MateriaController(SupabaseService supabaseService) {
        this.supabaseService = supabaseService;
    }

    @GetMapping
    public ResponseEntity<List<Materia>> getAllMaterias() {
        return ResponseEntity.ok(supabaseService.getAllMaterias());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Materia> getMateriaById(@PathVariable Long id) {
        Materia m = supabaseService.getMateriaById(id);
        if (m == null) return ResponseEntity.notFound().build();
        return ResponseEntity.ok(m);
    }

    @PostMapping
    public ResponseEntity<Materia> createMateria(@RequestBody Materia materia) {
        // Persistencia solo en Supabase
        Materia created = supabaseService.insertMateria(materia);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Materia> updateMateria(@PathVariable Long id, @RequestBody Materia materia) {
        materia.setId(id);
        Materia updated = supabaseService.updateMateria(id, materia);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteMateria(@PathVariable Long id) {
        supabaseService.deleteMateria(id);
        return ResponseEntity.noContent().build();
    }
}
