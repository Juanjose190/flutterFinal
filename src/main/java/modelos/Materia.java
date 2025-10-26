package modelos;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
public class Materia {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String nombre;
    private String codigo;
    private Integer horasSemana;
    private Integer nivel; // Semestre o año
}