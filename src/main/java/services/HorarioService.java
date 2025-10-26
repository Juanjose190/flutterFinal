package services;

import dto.*;
import modelos.*;
import repository.AulaRepository;
import repository.HorarioRepository;
import repository.MateriaRepository;
import repository.ProfesorRepository;
import repository.ProfesorRepository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class HorarioService {

    @Autowired
    private ProfesorRepository profesorRepo;

    @Autowired
    private MateriaRepository materiaRepo;

    @Autowired
    private AulaRepository aulaRepo;

    @Autowired
    private HorarioRepository horarioRepo;

    @Autowired
    private GeminiService geminiService;

    public HorarioResponse generarHorario(HorarioRequest request) {
        // Obtener datos
        List<Profesor> profesores = profesorRepo.findAllById(request.getProfesorIds());
        List<Materia> materias = materiaRepo.findAllById(request.getMateriaIds());
        List<Aula> aulas = aulaRepo.findAllById(request.getAulaIds());

        // Convertir a strings para el prompt
        String profesoresStr = profesores.stream()
                .map(p -> p.getNombre() + " (Materias: " + String.join(", ", p.getMateriasQueImparte()) + ")")
                .collect(Collectors.joining(", "));

        String materiasStr = materias.stream()
                .map(m -> m.getNombre() + " (" + m.getHorasSemana() + "h/sem)")
                .collect(Collectors.joining(", "));

        String aulasStr = aulas.stream()
                .map(a -> a.getNombre() + " (Cap: " + a.getCapacidad() + ", Tipo: " + a.getTipo() + ")")
                .collect(Collectors.joining(", "));

        // Construir prompt y llamar a GPT-4
        String prompt = GeminiService.construirPrompt(
                profesoresStr,
                materiasStr,
                aulasStr,
                request.getRestricciones()
        );

        String horarioJson = GeminiService.generarHorario(prompt);

        // Guardar en BD
        Horario horario = new Horario();
        horario.setNombreHorario("Horario " + LocalDateTime.now().toString());
        horario.setHorarioJson(horarioJson);
        horario.setFechaCreacion(LocalDateTime.now());
        horario.setEstado("GENERADO");
        horario.setObservaciones("Generado automáticamente");

        Horario saved = horarioRepo.save(horario);

        // Convertir a response
        HorarioResponse response = new HorarioResponse();
        response.setId(saved.getId());
        response.setNombreHorario(saved.getNombreHorario());
        response.setHorarioJson(saved.getHorarioJson());
        response.setObservaciones(saved.getObservaciones());
        response.setEstado(saved.getEstado());

        return response;
    }

    public List<Horario> obtenerTodos() {
        return horarioRepo.findAll();
    }

    public Horario obtenerPorId(Long id) {
        return horarioRepo.findById(id).orElse(null);
    }

    public void actualizarEstado(Long id, String estado) {
        Horario horario = horarioRepo.findById(id).orElseThrow();
        horario.setEstado(estado);
        horarioRepo.save(horario);
    }
}