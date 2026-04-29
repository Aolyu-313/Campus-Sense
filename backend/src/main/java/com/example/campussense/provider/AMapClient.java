package com.example.campussense.provider;

import com.example.campussense.config.ExternalApiProperties;
import com.example.campussense.dto.LocationDto;
import com.example.campussense.dto.WeatherDto;
import com.example.campussense.service.ApiCacheService;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.time.Duration;
import java.util.Map;
import java.util.Optional;

@Component
public class AMapClient {

    private static final String PROVIDER = "AMAP";

    private final RestTemplate restTemplate;
    private final ExternalApiProperties properties;
    private final ApiCacheService cacheService;

    public AMapClient(RestTemplate restTemplate, ExternalApiProperties properties, ApiCacheService cacheService) {
        this.restTemplate = restTemplate;
        this.properties = properties;
        this.cacheService = cacheService;
    }

    public LocationDto reverseGeocode(double latitude, double longitude) {
        String cacheKey = String.format("regeo:%.4f,%.4f", latitude, longitude);
        Optional<LocationDto> cached = cacheService.get(PROVIDER, cacheKey, LocationDto.class);
        if (cached.isPresent() && isReusableLocation(cached.get())) {
            return cached.get();
        }

        LocationDto location = properties.hasAmapApiKey()
            ? fetchFromAmap(latitude, longitude)
            : fallback(latitude, longitude);
        cacheService.put(PROVIDER, cacheKey, location, Duration.ofDays(7));
        return location;
    }

    @SuppressWarnings("unchecked")
    private LocationDto fetchFromAmap(double latitude, double longitude) {
        try {
            String url = UriComponentsBuilder.fromHttpUrl(properties.getAmapRegeoUrl())
                .queryParam("key", properties.getAmapApiKey())
                .queryParam("location", longitude + "," + latitude)
                .queryParam("extensions", "base")
                .queryParam("output", "JSON")
                .build()
                .toUriString();
            Map<String, Object> response = restTemplate.getForObject(url, Map.class);
            if (response == null
                || !"1".equals(String.valueOf(response.get("status")))
                || !"10000".equals(String.valueOf(response.get("infocode")))) {
                return fallback(latitude, longitude);
            }
            Map<String, Object> regeocode = (Map<String, Object>) response.get("regeocode");
            if (regeocode == null) {
                return fallback(latitude, longitude);
            }
            String name = String.valueOf(regeocode.get("formatted_address"));
            String city = "Unknown";
            String adcode = "";
            Object addressComponent = regeocode.get("addressComponent");
            if (addressComponent instanceof Map) {
                Map<String, Object> ac = (Map<String, Object>) addressComponent;
                Object cityValue = ac.get("city");
                Object provinceValue = ac.get("province");
                city = readableValue(cityValue, readableValue(provinceValue, "Unknown"));
                Object adcodeValue = ac.get("adcode");
                if (adcodeValue != null) {
                    adcode = String.valueOf(adcodeValue);
                }
            }
            return new LocationDto(latitude, longitude, readableValue(name, "Campus Area"), city, adcode);
        } catch (Exception ignored) {
            return fallback(latitude, longitude);
        }
    }

    private LocationDto fallback(double latitude, double longitude) {
        String name = String.format("Campus Area %.4f, %.4f", latitude, longitude);
        return new LocationDto(latitude, longitude, name, "Local Campus", "");
    }

    private boolean isReusableLocation(LocationDto location) {
        return hasText(location.getAdcode()) || "Local Campus".equals(location.getCity());
    }

    private boolean hasText(String value) {
        return value != null && !value.trim().isEmpty();
    }

    private String readableValue(Object value, String fallback) {
        if (value == null) {
            return fallback;
        }
        String text = String.valueOf(value);
        return text.trim().isEmpty() || "[]".equals(text) ? fallback : text;
    }

    // ---- Weather API ----

    public WeatherDto getWeather(String adcode) {
        if (adcode == null || adcode.trim().isEmpty()) {
            return fallbackWeather();
        }
        String cacheKey = "weather:" + adcode;
        Optional<WeatherDto> cached = cacheService.get(PROVIDER, cacheKey, WeatherDto.class);
        if (cached.isPresent()) {
            return cached.get();
        }

        WeatherDto weather = properties.hasAmapApiKey()
            ? fetchWeather(adcode)
            : fallbackWeather();
        cacheService.put(PROVIDER, cacheKey, weather, Duration.ofMinutes(15));
        return weather;
    }

    @SuppressWarnings("unchecked")
    private WeatherDto fetchWeather(String adcode) {
        try {
            String url = UriComponentsBuilder.fromHttpUrl(properties.getAmapWeatherUrl())
                .queryParam("key", properties.getAmapApiKey())
                .queryParam("city", adcode)
                .queryParam("extensions", "base")
                .queryParam("output", "JSON")
                .build()
                .toUriString();
            Map<String, Object> response = restTemplate.getForObject(url, Map.class);
            if (response == null
                || !"1".equals(String.valueOf(response.get("status")))
                || !"10000".equals(String.valueOf(response.get("infocode")))) {
                return fallbackWeather();
            }
            Object livesObj = response.get("lives");
            if (!(livesObj instanceof java.util.List)) {
                return fallbackWeather();
            }
            java.util.List<?> lives = (java.util.List<?>) livesObj;
            if (lives.isEmpty() || !(lives.get(0) instanceof Map)) {
                return fallbackWeather();
            }
            Map<String, Object> live = (Map<String, Object>) lives.get(0);

            Double temperature = asDouble(live.get("temperature"), 22.0);
            Integer humidity = asInteger(live.get("humidity"), 55);
            String windPower = String.valueOf(live.getOrDefault("windpower", "3"));
            String weatherText = String.valueOf(live.getOrDefault("weather", ""));

            return new WeatherDto(
                temperature,
                temperature,
                humidity,
                windPowerToSpeed(windPower),
                0.0,
                conditionFromText(weatherText)
            );
        } catch (Exception ignored) {
            return fallbackWeather();
        }
    }

    private WeatherDto fallbackWeather() {
        return new WeatherDto(22.0, 22.0, 55, 6.0, 0.0, "CLOUDY");
    }

    private double windPowerToSpeed(String power) {
        try {
            String text = power == null ? "" : power.trim();
            java.util.regex.Matcher matcher = java.util.regex.Pattern.compile("\\d+").matcher(text);
            if (!matcher.find()) {
                return 5.0;
            }
            int level = Integer.parseInt(matcher.group());
            if (level <= 0) return 0.5;
            if (level == 1) return 1.0;
            if (level == 2) return 2.5;
            if (level == 3) return 4.5;
            if (level == 4) return 6.5;
            if (level == 5) return 9.5;
            if (level == 6) return 12.5;
            return 15.0 + (level - 7) * 3.0;
        } catch (NumberFormatException e) {
            return 5.0;
        }
    }

    private String conditionFromText(String text) {
        String normalized = text == null ? "" : text.trim();
        if (normalized.contains("雨")) {
            return "RAIN";
        }
        if (normalized.contains("雪")) {
            return "SNOW";
        }
        if (normalized.contains("晴")) {
            return "SUNNY";
        }
        if (normalized.contains("云")) {
            return "CLOUDY";
        }
        if (normalized.contains("阴")) {
            return "CLOUDY";
        }
        if (normalized.contains("雾") || normalized.contains("霾") || normalized.contains("沙")) {
            return "CLOUDY";
        }
        return "CLOUDY";
    }

    private Double asDouble(Object value, Double fallback) {
        try {
            return value == null ? fallback : Double.parseDouble(String.valueOf(value));
        } catch (NumberFormatException e) {
            return fallback;
        }
    }

    private Integer asInteger(Object value, Integer fallback) {
        try {
            return value == null ? fallback : Integer.parseInt(String.valueOf(value));
        } catch (NumberFormatException e) {
            return fallback;
        }
    }
}
