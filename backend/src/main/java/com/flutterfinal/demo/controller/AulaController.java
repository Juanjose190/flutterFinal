package com.flutterfinal.demo.controller;

import com.flutterfinal.demo.dto.HorarioRequest;
import com.flutterfinal.demo.dto.HorarioResponse;
import com.flutterfinal.demo.model.*;
import com.flutterfinal.demo.repository.*;
import com.flutterfinal.demo.service.HorarioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/aulas")
class AulaController {

    @Autowired
    private AulaRepository aulaRepo;

    @GetMapping
    public List<Aula> obtenerTodos() {
        return aulaRepo.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Aula> obtenerPorId(@PathVariable Long id) {
        return aulaRepo.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public Aula crear(@RequestBody Aula aula) {
        return aulaRepo.save(aula);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Aula> actualizar(@PathVariable Long id, @RequestBody Aula aula) {
        return aulaRepo.findById(id)
                .map(a -> {
                    a.setNombre(aula.getNombre());
                    a.setCapacidad(aula.getCapacidad());
                    a.setTipo(aula.getTipo());
                    return ResponseEntity.ok(aulaRepo.save(a));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> eliminar(@PathVariable Long id) {
        return aulaRepo.findById(id)
                .map(a -> {
                    aulaRepo.delete(a);
                    return ResponseEntity.ok().build();
                })
                .orElse(ResponseEntity.notFound().build());
    }
}
