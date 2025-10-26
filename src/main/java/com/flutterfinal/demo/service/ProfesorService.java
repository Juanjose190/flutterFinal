package com.flutterfinal.demo.service;

import com.flutterfinal.demo.model.*;
import com.flutterfinal.demo.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

// ============== PROFESOR SERVICE ==============
@Service
public class ProfesorService {

    @Autowired
    private ProfesorRepository profesorRepo;

    public List<Profesor> obtenerTodos() {
        return profesorRepo.findAll();
    }

    public Optional<Profesor> obtenerPorId(Long id) {
        return profesorRepo.findById(id);
    }

    public Profesor crear(Profesor profesor) {
        return profesorRepo.save(profesor);
    }

    public Profesor actualizar(Long id, Profesor profesorActualizado) {
        return profesorRepo.findById(id)
                .map(profesor -> {
                    profesor.setNombre(profesorActualizado.getNombre());
                    profesor.setEmail(profesorActualizado.getEmail());
                    profesor.setMateriasQueImparte(profesorActualizado.getMateriasQueImparte());
                    profesor.setHorariosDisponibles(profesorActualizado.getHorariosDisponibles());
                    return profesorRepo.save(profesor);
                })
                .orElseThrow(() -> new RuntimeException("Profesor no encontrado con id: " + id));
    }

    public void eliminar(Long id) {
        profesorRepo.deleteById(id);
    }

    public boolean existe(Long id) {
        return profesorRepo.existsById(id);
    }
}
