package com.example.campussense.service;

import com.example.campussense.dto.AirQualityDto;
import com.example.campussense.dto.ComfortDto;
import com.example.campussense.dto.WeatherDto;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class ComfortScoreServiceTest {

    private final ComfortScoreService service = new ComfortScoreService();

    @Test
    void calculatesComfortableScoreForMildWeatherCleanAirAndPositiveFeedback() {
        WeatherDto weather = new WeatherDto(22.0, 21.5, 55, 5.0, 0.0, "CLOUDY");
        AirQualityDto airQuality = new AirQualityDto(38, 10.0, 20.0, "GOOD");

        ComfortDto comfort = service.calculate(weather, airQuality, 0.85, "STATIONARY", 0.95);

        assertThat(comfort.getScore()).isBetween(80, 100);
        assertThat(comfort.getLevelCode()).isEqualTo("COMFORTABLE");
        assertThat(comfort.getAdviceCode()).isEqualTo("GOOD_FOR_OUTDOOR_STAY");
    }

    @Test
    void penalizesExtremeHeatRainAndPoorAirQuality() {
        WeatherDto weather = new WeatherDto(35.0, 39.0, 82, 25.0, 8.0, "RAIN");
        AirQualityDto airQuality = new AirQualityDto(180, 95.0, 140.0, "UNHEALTHY");

        ComfortDto comfort = service.calculate(weather, airQuality, 0.15, "WALKING", 0.2);

        assertThat(comfort.getScore()).isLessThan(45);
        assertThat(comfort.getLevelCode()).isEqualTo("UNCOMFORTABLE");
        assertThat(comfort.getAdviceCode()).isEqualTo("CHOOSE_INDOOR_SPACE");
    }
}
