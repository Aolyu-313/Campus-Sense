package com.example.campussense.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI campusSenseOpenApi() {
        return new OpenAPI()
            .info(new Info()
                .title("CampusSense Backend API")
                .version("0.1.0")
                .description("Local REST API for campus micro-environment comfort sensing and feedback."));
    }
}
