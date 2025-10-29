package com.horarios.generador.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Profesor {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String nombre;
    private String apellido;
    private String email;
    private Integer horasDisponibles;

    @ElementCollection
    @CollectionTable(
        name = "disponibilidad_profesor",
        joinColumns = @JoinColumn(name = "profesor_id")
    )
    private List<DisponibilidadHoraria> disponibilidad;
}

