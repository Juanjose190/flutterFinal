package com.flutterfinal.demo.dto;

import lombok.Data;
import java.util.List;

@Data
public class HorarioRequest {
    private List<Long> profesorIds;
    private List<Long> materiaIds;
    private List<Long> aulaIds;
    private String restricciones; // Texto libre con restricciones adicionales
}