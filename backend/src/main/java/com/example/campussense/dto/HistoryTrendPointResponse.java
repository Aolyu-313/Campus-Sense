package com.example.campussense.dto;

import java.time.LocalDateTime;

public class HistoryTrendPointResponse {

    private LocalDateTime createdAt;
    private Integer comfortScore;
    private Integer aqi;
    private Double temperature;

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public Integer getComfortScore() {
        return comfortScore;
    }

    public void setComfortScore(Integer comfortScore) {
        this.comfortScore = comfortScore;
    }

    public Integer getAqi() {
        return aqi;
    }

    public void setAqi(Integer aqi) {
        this.aqi = aqi;
    }

    public Double getTemperature() {
        return temperature;
    }

    public void setTemperature(Double temperature) {
        this.temperature = temperature;
    }
}
