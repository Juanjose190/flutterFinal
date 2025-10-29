package com.horarios.generador.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "aulas")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Aula {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private String nombre;
    
    private Integer capacidad;
    
    @Column(name = "es_especial")
    private Boolean esEspecial;
    
    @Column(name = "tipo_aula")
    private String tipoAula;

    // Lombok genera getters/setters automáticamente.
}
