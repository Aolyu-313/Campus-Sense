package com.example.campussense.controller;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class EnvironmentControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void returnsCurrentEnvironmentSummaryWithLocationWeatherAirQualityAndComfort() throws Exception {
        mockMvc.perform(get("/api/environment/current")
                .param("lat", "51.5246")
                .param("lon", "-0.1340"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.location.latitude", is(51.5246)))
            .andExpect(jsonPath("$.location.longitude", is(-0.134)))
            .andExpect(jsonPath("$.location.name", notNullValue()))
            .andExpect(jsonPath("$.weather.temperature", notNullValue()))
            .andExpect(jsonPath("$.airQuality.aqi", notNullValue()))
            .andExpect(jsonPath("$.comfort.score", notNullValue()))
            .andExpect(jsonPath("$.comfort.levelCode", notNullValue()));
    }
}
