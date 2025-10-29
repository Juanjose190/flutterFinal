package com.horarios.generador.service;

import com.horarios.generador.model.Materia;
import com.horarios.generador.repository.MateriaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class MateriaService {

    private final MateriaRepository materiaRepository;
    private final SupabaseService supabaseService;

    @Autowired
    public MateriaService(MateriaRepository materiaRepository, SupabaseService supabaseService) {
        this.materiaRepository = materiaRepository;
        this.supabaseService = supabaseService;
    }

    public List<Materia> findAll() {
        return materiaRepository.findAll();
    }

    public Optional<Materia> findById(Long id) {
        return materiaRepository.findById(id);
    }

    public Materia save(Materia materia) {
        return materiaRepository.save(materia);
    }

    public void deleteById(Long id) {
        materiaRepository.deleteById(id);
    }
}
