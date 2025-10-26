package modelos;

import jakarta.persistence.*;
import lombok.Data;
import java.util.List;

@Entity
@Data
public class Profesor {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String nombre;
    private String email;

    @ElementCollection
    private List<String> materiasQueImparte;

    @ElementCollection
    private List<String> horariosDisponibles; // Ej: "Lunes 8:00-10:00"
}