package com.example.campussense;

import com.example.campussense.config.ExternalApiProperties;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;

@SpringBootApplication
@EnableConfigurationProperties(ExternalApiProperties.class)
public class CampusSenseApplication {

    public static void main(String[] args) {
        SpringApplication.run(CampusSenseApplication.class, args);
    }
}
