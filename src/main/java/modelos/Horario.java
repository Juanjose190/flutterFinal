package modelos;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Data
public class Horario {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String nombreHorario;

    @Column(columnDefinition = "TEXT")
    private String horarioJson; // JSON generado por GPT-4

    private LocalDateTime fechaCreacion;

    @Column(columnDefinition = "TEXT")
    private String observaciones;

    private String estado; // "GENERADO", "APROBADO", "RECHAZADO"
}
