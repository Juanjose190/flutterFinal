package com.horarios.generador.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

@Entity
@Table(name = "profesores")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Profesor {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private String nombre;
    
    @Column(nullable = false)
    private String apellido;
    
    private String email;
    
    @Column(name = "horas_disponibles")
    private Integer horasDisponibles;
    
    @ManyToMany
    @JoinTable(
        name = "profesor_materia",
        joinColumns = @JoinColumn(name = "profesor_id"),
        inverseJoinColumns = @JoinColumn(name = "materia_id")
    )
    private List<Materia> materias;
    
    @ElementCollection
    @CollectionTable(name = "disponibilidad_profesor", joinColumns = @JoinColumn(name = "profesor_id"))
    private List<DisponibilidadHoraria> disponibilidad;

    // Lombok genera getters/setters automáticamente.
}
