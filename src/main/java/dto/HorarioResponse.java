package dto;

import lombok.Data;

@Data
public class HorarioResponse {
    private Long id;
    private String nombreHorario;
    private String horarioJson;
    private String observaciones;
    private String estado;
}