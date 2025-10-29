package com.horarios.generador.controller;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@CrossOrigin(origins = "*")
public class HomeController {

    @GetMapping("/")
    public Map<String, Object> root() {
        Map<String, Object> resp = new HashMap<>();
        resp.put("name", "generador-horarios");
        resp.put("status", "ok");
        return resp;
    }
}

