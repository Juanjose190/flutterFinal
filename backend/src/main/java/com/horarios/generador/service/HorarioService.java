package com.horarios.generador.service;

import com.horarios.generador.model.Horario;
import com.horarios.generador.repository.HorarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class HorarioService {

    private final HorarioRepository horarioRepository;
    private final SupabaseService supabaseService;

    @Autowired
    public HorarioService(HorarioRepository horarioRepository, SupabaseService supabaseService) {
        this.horarioRepository = horarioRepository;
        this.supabaseService = supabaseService;
    }

    public List<Horario> findAll() {
        return horarioRepository.findAll();
    }

    public Optional<Horario> findById(Long id) {
        return horarioRepository.findById(id);
    }

    public Horario save(Horario horario) {
        if (horario.getFechaCreacion() == null) {
            horario.setFechaCreacion(LocalDateTime.now());
        }
        return horarioRepository.save(horario);
    }

    public void deleteById(Long id) {
        horarioRepository.deleteById(id);
    }

    public Horario generarHorarioConIA(List<Long> materiaIds, List<Long> profesorIds, List<Long> aulaIds) {
        Horario horario = new Horario();
        horario.setNombre("Horario generado");
        horario.setDescripcion("Generado automáticamente");
        horario.setFechaCreacion(LocalDateTime.now());
        // Ya no persistimos localmente: la persistencia se hará exclusivamente en Supabase
        return horario;
    }
}
