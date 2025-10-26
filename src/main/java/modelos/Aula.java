package modelos;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
public class Aula {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String nombre;
    private Integer capacidad;
    private String tipo; // "Lab", "Teórico", "Auditorio"
}