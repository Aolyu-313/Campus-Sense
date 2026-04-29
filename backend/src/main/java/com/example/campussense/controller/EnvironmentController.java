package com.example.campussense.controller;

import com.example.campussense.dto.EnvironmentCurrentResponse;
import com.example.campussense.service.EnvironmentService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.constraints.DecimalMax;
import javax.validation.constraints.DecimalMin;

@Validated
@RestController
@RequestMapping("/api/environment")
public class EnvironmentController {

    private final EnvironmentService environmentService;

    public EnvironmentController(EnvironmentService environmentService) {
        this.environmentService = environmentService;
    }

    @GetMapping("/current")
    public EnvironmentCurrentResponse current(
        @RequestParam("lat") @DecimalMin("-90.0") @DecimalMax("90.0") double latitude,
        @RequestParam("lon") @DecimalMin("-180.0") @DecimalMax("180.0") double longitude,
        @RequestParam(value = "movementState", defaultValue = "UNKNOWN") String movementState
    ) {
        return environmentService.getCurrent(latitude, longitude, movementState);
    }
}
