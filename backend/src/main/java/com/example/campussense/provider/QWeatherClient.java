package com.example.campussense.provider;

import com.example.campussense.config.ExternalApiProperties;
import com.example.campussense.dto.AirQualityDto;
import com.example.campussense.service.ApiCacheService;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.time.Duration;
import java.util.Map;
import java.util.Optional;

@Component
public class QWeatherClient {

    private static final String PROVIDER = "QWEATHER";

    private final RestTemplate restTemplate;
    private final ExternalApiProperties properties;
    private final ApiCacheService cacheService;

    public QWeatherClient(RestTemplate restTemplate, ExternalApiProperties properties, ApiCacheService cacheService) {
        this.restTemplate = restTemplate;
        this.properties = properties;
        this.cacheService = cacheService;
    }

    public AirQualityDto getAirQuality(double latitude, double longitude) {
        String cacheKey = String.format("air:%.4f,%.4f", latitude, longitude);
        Optional<AirQualityDto> cached = cacheService.get(PROVIDER, cacheKey, AirQualityDto.class);
        if (cached.isPresent()) {
            return cached.get();
        }
        AirQualityDto airQuality = properties.hasQWeatherApiKey()
            ? fetchAirQuality(latitude, longitude)
            : fallbackAirQuality(latitude, longitude);
        cacheService.put(PROVIDER, cacheKey, airQuality, Duration.ofMinutes(20));
        return airQuality;
    }

    @SuppressWarnings("unchecked")
    private AirQualityDto fetchAirQuality(double latitude, double longitude) {
        try {
            String url = UriComponentsBuilder.fromHttpUrl(properties.getQweatherAirUrl())
                .queryParam("location", longitude + "," + latitude)
                .queryParam("key", properties.getQweatherApiKey())
                .build()
                .toUriString();
            Map<String, Object> response = restTemplate.getForObject(url, Map.class);
            if (response == null || response.get("now") == null) {
                return fallbackAirQuality(latitude, longitude);
            }
            Map<String, Object> now = (Map<String, Object>) response.get("now");
            Integer aqi = asInteger(now.get("aqi"), 45);
            return new AirQualityDto(
                aqi,
                asDouble(now.get("pm2p5"), 12.0),
                asDouble(now.get("pm10"), 24.0),
                levelFromAqi(aqi)
            );
        } catch (Exception ignored) {
            return fallbackAirQuality(latitude, longitude);
        }
    }

    private AirQualityDto fallbackAirQuality(double latitude, double longitude) {
        int aqi = 35 + (int) (Math.abs(latitude * longitude) % 25);
        return new AirQualityDto(aqi, 10.0 + (aqi % 8), 22.0 + (aqi % 12), levelFromAqi(aqi));
    }

    private String levelFromAqi(Integer aqi) {
        int value = aqi == null ? 50 : aqi;
        if (value <= 50) {
            return "GOOD";
        }
        if (value <= 100) {
            return "MODERATE";
        }
        if (value <= 150) {
            return "UNHEALTHY_FOR_SENSITIVE";
        }
        return "UNHEALTHY";
    }

    private Double asDouble(Object value, Double fallback) {
        try {
            return value == null ? fallback : Double.valueOf(String.valueOf(value));
        } catch (NumberFormatException exception) {
            return fallback;
        }
    }

    private Integer asInteger(Object value, Integer fallback) {
        try {
            return value == null ? fallback : Integer.valueOf(String.valueOf(value));
        } catch (NumberFormatException exception) {
            return fallback;
        }
    }
}
