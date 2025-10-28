package com.flutterfinal.demo.service;

import com.flutterfinal.demo.model.*;
import com.flutterfinal.demo.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
class MateriaService {

    @Autowired
    private MateriaRepository materiaRepo;

    public List<Materia> obtenerTodas() {
        return materiaRepo.findAll();
    }

    public Optional<Materia> obtenerPorId(Long id) {
        return materiaRepo.findById(id);
    }

    public Materia crear(Materia materia) {
        return materiaRepo.save(materia);
    }

    public Materia actualizar(Long id, Materia materiaActualizada) {
        return materiaRepo.findById(id)
                .map(materia -> {
                    materia.setNombre(materiaActualizada.getNombre());
                    materia.setCodigo(materiaActualizada.getCodigo());
                    materia.setHorasSemana(materiaActualizada.getHorasSemana());
                    materia.setNivel(materiaActualizada.getNivel());
                    return materiaRepo.save(materia);
                })
                .orElseThrow(() -> new RuntimeException("Materia no encontrada con id: " + id));
    }

    public void eliminar(Long id) {
        materiaRepo.deleteById(id);
    }

    public boolean existe(Long id) {
        return materiaRepo.existsById(id);
    }
}