package com.horarios.generador.service;

import com.horarios.generador.model.Profesor;
import com.horarios.generador.repository.ProfesorRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class ProfesorService {

    private final ProfesorRepository profesorRepository;
    private final SupabaseService supabaseService;

    @Autowired
    public ProfesorService(ProfesorRepository profesorRepository, SupabaseService supabaseService) {
        this.profesorRepository = profesorRepository;
        this.supabaseService = supabaseService;
    }

    public List<Profesor> findAll() {
        return profesorRepository.findAll();
    }

    public Optional<Profesor> findById(Long id) {
        return profesorRepository.findById(id);
    }

    public Profesor save(Profesor profesor) {
        return profesorRepository.save(profesor);
    }

    public void deleteById(Long id) {
        profesorRepository.deleteById(id);
    }
}
