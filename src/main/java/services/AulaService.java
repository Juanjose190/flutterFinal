package services;
import modelos.*;
import repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;


@Service
class AulaService {

    @Autowired
    private AulaRepository aulaRepo;

    public List<Aula> obtenerTodas() {
        return aulaRepo.findAll();
    }

    public Optional<Aula> obtenerPorId(Long id) {
        return aulaRepo.findById(id);
    }

    public Aula crear(Aula aula) {
        return aulaRepo.save(aula);
    }

    public Aula actualizar(Long id, Aula aulaActualizada) {
        return aulaRepo.findById(id)
                .map(aula -> {
                    aula.setNombre(aulaActualizada.getNombre());
                    aula.setCapacidad(aulaActualizada.getCapacidad());
                    aula.setTipo(aulaActualizada.getTipo());
                    return aulaRepo.save(aula);
                })
                .orElseThrow(() -> new RuntimeException("Aula no encontrada con id: " + id));
    }

    public void eliminar(Long id) {
        aulaRepo.deleteById(id);
    }

    public boolean existe(Long id) {
        return aulaRepo.existsById(id);
    }
}