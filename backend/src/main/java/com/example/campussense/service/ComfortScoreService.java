package com.example.campussense.service;

import com.example.campussense.dto.AirQualityDto;
import com.example.campussense.dto.ComfortDto;
import com.example.campussense.dto.WeatherDto;
import org.springframework.stereotype.Service;

@Service
public class ComfortScoreService {

    public ComfortDto calculate(WeatherDto weather, AirQualityDto airQuality, double userFeedbackSignal, String movementState, double recencySignal) {
        double weatherScore = weatherScore(weather);
        double airQualityScore = airQualityScore(airQuality);
        double feedbackScore = clamp(userFeedbackSignal, 0.0, 1.0) * 100.0;
        double movementScore = movementScore(movementState);
        double recencyScore = clamp(recencySignal, 0.0, 1.0) * 100.0;

        int score = (int) Math.round(
            weatherScore * 0.35
                + airQualityScore * 0.30
                + feedbackScore * 0.20
                + movementScore * 0.10
                + recencyScore * 0.05
        );
        score = (int) clamp(score, 0, 100);
        return new ComfortDto(score, levelCode(score), adviceCode(score));
    }

    private double weatherScore(WeatherDto weather) {
        double feelsLike = weather.getFeelsLike() != null ? weather.getFeelsLike() : safeDouble(weather.getTemperature(), 22.0);
        double temperaturePenalty = Math.abs(feelsLike - 22.0) * 5.0;
        double humidityPenalty = Math.max(0, safeInteger(weather.getHumidity(), 55) - 70) * 0.8;
        double windPenalty = Math.max(0, safeDouble(weather.getWindSpeed(), 0.0) - 15.0) * 2.0;
        double rainPenalty = Math.min(35.0, safeDouble(weather.getPrecipitation(), 0.0) * 6.0);
        return clamp(100.0 - temperaturePenalty - humidityPenalty - windPenalty - rainPenalty, 0.0, 100.0);
    }

    private double airQualityScore(AirQualityDto airQuality) {
        int aqi = safeInteger(airQuality.getAqi(), 50);
        double pm25Penalty = Math.max(0.0, safeDouble(airQuality.getPm25(), 12.0) - 35.0) * 0.4;
        double pm10Penalty = Math.max(0.0, safeDouble(airQuality.getPm10(), 25.0) - 50.0) * 0.2;
        return clamp(100.0 - aqi * 0.45 - pm25Penalty - pm10Penalty, 0.0, 100.0);
    }

    private double movementScore(String movementState) {
        if (movementState == null) {
            return 80.0;
        }
        String normalized = movementState.trim().toUpperCase();
        if ("STATIONARY".equals(normalized) || "LOW_MOTION".equals(normalized)) {
            return 100.0;
        }
        if ("WALKING".equals(normalized)) {
            return 70.0;
        }
        if ("RUNNING".equals(normalized) || "CYCLING".equals(normalized) || "MOVING".equals(normalized)) {
            return 55.0;
        }
        return 80.0;
    }

    private String levelCode(int score) {
        if (score >= 80) {
            return "COMFORTABLE";
        }
        if (score >= 60) {
            return "MODERATE";
        }
        if (score >= 45) {
            return "LOW";
        }
        return "UNCOMFORTABLE";
    }

    private String adviceCode(int score) {
        if (score >= 80) {
            return "GOOD_FOR_OUTDOOR_STAY";
        }
        if (score >= 60) {
            return "OK_FOR_SHORT_STAY";
        }
        if (score >= 45) {
            return "USE_WITH_CAUTION";
        }
        return "CHOOSE_INDOOR_SPACE";
    }

    private double safeDouble(Double value, double fallback) {
        return value == null ? fallback : value;
    }

    private int safeInteger(Integer value, int fallback) {
        return value == null ? fallback : value;
    }

    private double clamp(double value, double min, double max) {
        return Math.max(min, Math.min(max, value));
    }
}
