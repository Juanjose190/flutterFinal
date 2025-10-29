package com.horarios.generador.service;

import com.horarios.generador.model.Aula;
import com.horarios.generador.repository.AulaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class AulaService {
    private final AulaRepository aulaRepository;
    private final SupabaseService supabaseService;

    @Autowired
    public AulaService(AulaRepository aulaRepository, SupabaseService supabaseService) {
        this.aulaRepository = aulaRepository;
        this.supabaseService = supabaseService;
    }

    public List<Aula> findAll() {
        return aulaRepository.findAll();
    }

    public Optional<Aula> findById(Long id) {
        return aulaRepository.findById(id);
    }

    public Aula save(Aula aula) {
        return aulaRepository.save(aula);
    }

    public void deleteById(Long id) {
        aulaRepository.deleteById(id);
    }
}
