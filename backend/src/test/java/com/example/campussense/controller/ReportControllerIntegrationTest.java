package com.example.campussense.controller;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.hamcrest.Matchers.greaterThanOrEqualTo;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class ReportControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void storesReportAndMakesItAvailableInNearbyAndHistoryQueries() throws Exception {
        String body = "{"
            + "\"deviceId\":\"device-test-001\","
            + "\"latitude\":51.5246,"
            + "\"longitude\":-0.1340,"
            + "\"scene\":\"STUDY\","
            + "\"movementState\":\"STATIONARY\","
            + "\"tags\":[\"QUIET\",\"COMFORTABLE\"],"
            + "\"note\":\"Good place to sit for a short break.\""
            + "}";

        mockMvc.perform(post("/api/reports")
                .contentType(MediaType.APPLICATION_JSON)
                .content(body))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.id", notNullValue()))
            .andExpect(jsonPath("$.deviceId", is("device-test-001")))
            .andExpect(jsonPath("$.scene", is("STUDY")))
            .andExpect(jsonPath("$.comfortScore", greaterThanOrEqualTo(0)))
            .andExpect(jsonPath("$.createdAt", notNullValue()));

        mockMvc.perform(get("/api/reports/nearby")
                .param("lat", "51.5247")
                .param("lon", "-0.1341")
                .param("radius", "100"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$", hasSize(1)))
            .andExpect(jsonPath("$[0].deviceId", is("device-test-001")))
            .andExpect(jsonPath("$[0].distanceMeters", greaterThanOrEqualTo(0.0)));

        mockMvc.perform(get("/api/history")
                .param("deviceId", "device-test-001"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$", hasSize(1)))
            .andExpect(jsonPath("$[0].scene", is("STUDY")))
            .andExpect(jsonPath("$[0].environmentSnapshot", notNullValue()));
    }

    @Test
    void returnsHistoryTrendPointsForCharts() throws Exception {
        String firstBody = "{"
            + "\"deviceId\":\"trend-device-001\","
            + "\"latitude\":51.5246,"
            + "\"longitude\":-0.1340,"
            + "\"scene\":\"STUDY\","
            + "\"movementState\":\"STATIONARY\","
            + "\"tags\":[\"QUIET\",\"COMFORTABLE\"],"
            + "\"note\":\"First trend point\""
            + "}";
        String secondBody = "{"
            + "\"deviceId\":\"trend-device-001\","
            + "\"latitude\":51.5250,"
            + "\"longitude\":-0.1343,"
            + "\"scene\":\"REST\","
            + "\"movementState\":\"WALKING\","
            + "\"tags\":[\"TOO_NOISY\"],"
            + "\"note\":\"Second trend point\""
            + "}";

        mockMvc.perform(post("/api/reports")
                .contentType(MediaType.APPLICATION_JSON)
                .content(firstBody))
            .andExpect(status().isCreated());
        mockMvc.perform(post("/api/reports")
                .contentType(MediaType.APPLICATION_JSON)
                .content(secondBody))
            .andExpect(status().isCreated());

        mockMvc.perform(get("/api/history/trends")
                .param("deviceId", "trend-device-001")
                .param("limit", "10"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.deviceId").value("trend-device-001"))
            .andExpect(jsonPath("$.points", hasSize(2)))
            .andExpect(jsonPath("$.points[0].createdAt", notNullValue()))
            .andExpect(jsonPath("$.points[0].comfortScore", greaterThanOrEqualTo(0)))
            .andExpect(jsonPath("$.points[0].aqi", notNullValue()))
            .andExpect(jsonPath("$.points[0].temperature", notNullValue()));
    }
}
