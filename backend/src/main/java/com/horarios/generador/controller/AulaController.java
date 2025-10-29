package com.horarios.generador.controller;

import com.horarios.generador.model.Aula;
import com.horarios.generador.service.SupabaseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/aulas")
@CrossOrigin(origins = "*")
public class AulaController {

    private final SupabaseService supabaseService;

    @Autowired
    public AulaController(SupabaseService supabaseService) {
        this.supabaseService = supabaseService;
    }

    @GetMapping
    public ResponseEntity<List<Aula>> getAllAulas() {
        return ResponseEntity.ok(supabaseService.getAllAulas());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Aula> getAulaById(@PathVariable Long id) {
        Aula a = supabaseService.getAulaById(id);
        if (a == null) return ResponseEntity.notFound().build();
        return ResponseEntity.ok(a);
    }

    @PostMapping
    public ResponseEntity<Aula> createAula(@RequestBody Aula aula) {
        // Persistencia solo en Supabase
        Aula created = supabaseService.insertAula(aula);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Aula> updateAula(@PathVariable Long id, @RequestBody Aula aula) {
        aula.setId(id);
        Aula updated = supabaseService.updateAula(id, aula);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteAula(@PathVariable Long id) {
        supabaseService.deleteAula(id);
        return ResponseEntity.noContent().build();
    }
}
