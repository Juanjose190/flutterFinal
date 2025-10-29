package com.horarios.generador.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "asignaciones_horarias")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class AsignacionHoraria {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @JoinColumn(name = "materia_id", nullable = false)
    private Materia materia;
    
    @ManyToOne
    @JoinColumn(name = "profesor_id", nullable = false)
    private Profesor profesor;
    
    @ManyToOne
    @JoinColumn(name = "aula_id", nullable = false)
    private Aula aula;
    
    @Column(nullable = false)
    private String dia;
    
    @Column(name = "hora_inicio", nullable = false)
    private String horaInicio;
    
    @Column(name = "hora_fin", nullable = false)
    private String horaFin;
}