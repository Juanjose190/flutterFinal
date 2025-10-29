package com.horarios.generador.model;

import jakarta.persistence.Embeddable;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Embeddable
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DisponibilidadHoraria {
    private String dia;
    private String horaInicio;
    private String horaFin;
}