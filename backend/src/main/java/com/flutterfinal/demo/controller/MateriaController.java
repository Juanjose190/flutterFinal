package com.flutterfinal.demo.controller;

import com.flutterfinal.demo.model.*;
import com.flutterfinal.demo.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/materias")
class MateriaController {

    @Autowired
    private MateriaRepository materiaRepo;

    @GetMapping
    public List<Materia> obtenerTodos() {
        return materiaRepo.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Materia> obtenerPorId(@PathVariable Long id) {
        return materiaRepo.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public Materia crear(@RequestBody Materia materia) {
        return materiaRepo.save(materia);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Materia> actualizar(@PathVariable Long id, @RequestBody Materia materia) {
        return materiaRepo.findById(id)
                .map(m -> {
                    m.setNombre(materia.getNombre());
                    m.setCodigo(materia.getCodigo());
                    m.setHorasSemana(materia.getHorasSemana());
                    m.setNivel(materia.getNivel());
                    return ResponseEntity.ok(materiaRepo.save(m));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> eliminar(@PathVariable Long id) {
        return materiaRepo.findById(id)
                .map(m -> {
                    materiaRepo.delete(m);
                    return ResponseEntity.ok().build();
                })
                .orElse(ResponseEntity.notFound().build());
    }
}
