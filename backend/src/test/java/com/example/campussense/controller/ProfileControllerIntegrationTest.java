package com.example.campussense.controller;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.hamcrest.Matchers.notNullValue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class ProfileControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void savesAndReturnsAnonymousUserLanguagePreference() throws Exception {
        String body = "{"
            + "\"deviceId\":\"profile-device-001\","
            + "\"preferredLanguage\":\"zh\""
            + "}";

        mockMvc.perform(put("/api/profile")
                .contentType(MediaType.APPLICATION_JSON)
                .content(body))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.deviceId").value("profile-device-001"))
            .andExpect(jsonPath("$.preferredLanguage").value("zh"))
            .andExpect(jsonPath("$.createdAt", notNullValue()));

        mockMvc.perform(get("/api/profile")
                .param("deviceId", "profile-device-001"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.deviceId").value("profile-device-001"))
            .andExpect(jsonPath("$.preferredLanguage").value("zh"))
            .andExpect(jsonPath("$.createdAt", notNullValue()));
    }

    @Test
    void returnsDefaultEnglishProfileWhenDeviceIsFirstSeen() throws Exception {
        mockMvc.perform(get("/api/profile")
                .param("deviceId", "profile-device-new"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.deviceId").value("profile-device-new"))
            .andExpect(jsonPath("$.preferredLanguage").value("en"))
            .andExpect(jsonPath("$.createdAt", notNullValue()));
    }
}
