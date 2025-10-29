package com.horarios.generador.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

@Configuration
public class SupabaseConfig {

    @Value("${supabase.url}")
    private String supabaseUrl;

    @Value("${supabase.service-role}")
    private String supabaseKey;

    // Método comentado temporalmente para permitir la compilación
    /*
    @Bean
    public SupabaseClient supabaseClient() {
        return createClient(supabaseUrl, supabaseKey);
    }
    */
}
