package com.example.campussense.controller;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.notNullValue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class ErrorHandlingIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void rejectsInvalidNearbyRadiusWithUnifiedErrorResponse() throws Exception {
        mockMvc.perform(get("/api/reports/nearby")
                .param("lat", "51.5246")
                .param("lon", "-0.1340")
                .param("radius", "-1"))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.timestamp", notNullValue()))
            .andExpect(jsonPath("$.status").value(400))
            .andExpect(jsonPath("$.errorCode").value("INVALID_REQUEST"))
            .andExpect(jsonPath("$.message", containsString("radius")));
    }

    @Test
    void rejectsMalformedJsonWithUnifiedErrorResponse() throws Exception {
        mockMvc.perform(post("/api/reports")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"deviceId\":"))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.timestamp", notNullValue()))
            .andExpect(jsonPath("$.status").value(400))
            .andExpect(jsonPath("$.errorCode").value("INVALID_REQUEST"))
            .andExpect(jsonPath("$.message", containsString("Malformed JSON")));
    }
}
