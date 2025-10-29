package com.horarios.generador.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "materias")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Materia {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private String nombre;
    
    @Column(nullable = false)
    private Integer horasSemanales;
    
    private String descripcion;
    
    @Column(name = "requiere_aula_especial")
    private Boolean requiereAulaEspecial;
    
    @Column(name = "tipo_aula_especial")
    private String tipoAulaEspecial;

    // Lombok genera getters/setters automáticamente.
}
