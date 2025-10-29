package com.horarios.generador.dto;

import com.horarios.generador.model.DisponibilidadHoraria;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ProfesorRequest {
    private String nombre;
    private String apellido;
    private String email;
    private Integer horasDisponibles;
    // Lista de IDs de materias
    private List<Long> materias;
    // Disponibilidad opcional
    private List<DisponibilidadHoraria> disponibilidad;
}
