package com.example.campussense.provider;

import com.example.campussense.config.ExternalApiProperties;
import com.example.campussense.dto.LocationDto;
import com.example.campussense.dto.WeatherDto;
import com.example.campussense.service.ApiCacheService;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.web.client.RestTemplate;

import java.time.Duration;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withSuccess;

class AMapClientTest {

    @Test
    void reverseGeocodeRefreshesCachedAmapLocationWhenAdcodeIsMissing() {
        RestTemplate restTemplate = new RestTemplate();
        MockRestServiceServer server = MockRestServiceServer.bindTo(restTemplate).build();
        ApiCacheService cacheService = mock(ApiCacheService.class);
        ExternalApiProperties properties = new ExternalApiProperties();
        properties.setAmapApiKey("test-amap-key");
        properties.setAmapRegeoUrl("https://restapi.amap.com/v3/geocode/regeo");

        String cacheKey = "regeo:31.2304,121.4737";
        when(cacheService.get(eq("AMAP"), eq(cacheKey), eq(LocationDto.class)))
            .thenReturn(Optional.of(new LocationDto(
                31.2304,
                121.4737,
                "Shanghai Municipal People's Government",
                "Shanghai",
                null
            )));

        server.expect(request -> {
                assertThat(request.getURI().getPath()).isEqualTo("/v3/geocode/regeo");
                assertThat(request.getURI().getQuery())
                    .contains("location=121.4737,31.2304")
                    .contains("extensions=base")
                    .contains("output=JSON");
            })
            .andRespond(withSuccess("{"
                + "\"status\":\"1\","
                + "\"info\":\"OK\","
                + "\"infocode\":\"10000\","
                + "\"regeocode\":{"
                + "\"formatted_address\":\"\\u4e0a\\u6d77\\u5e02\\u9ec4\\u6d66\\u533a\\u5357\\u4eac\\u4e1c\\u8def\\u8857\\u9053\\u4e0a\\u6d77\\u5e02\\u4eba\\u6c11\\u653f\\u5e9c\","
                + "\"addressComponent\":{"
                + "\"province\":\"\\u4e0a\\u6d77\\u5e02\","
                + "\"city\":[],"
                + "\"adcode\":\"310101\""
                + "}"
                + "}"
                + "}", MediaType.APPLICATION_JSON));

        LocationDto location = new AMapClient(restTemplate, properties, cacheService)
            .reverseGeocode(31.2304, 121.4737);

        assertThat(location.getAdcode()).isEqualTo("310101");
        assertThat(location.getCity()).isEqualTo("\u4e0a\u6d77\u5e02");
        verify(cacheService).put(eq("AMAP"), eq(cacheKey), any(LocationDto.class), eq(Duration.ofDays(7)));
        server.verify();
    }

    @Test
    void getWeatherUsesAmapWeatherInfoCurrentWeatherEndpoint() {
        RestTemplate restTemplate = new RestTemplate();
        MockRestServiceServer server = MockRestServiceServer.bindTo(restTemplate).build();
        ApiCacheService cacheService = mock(ApiCacheService.class);
        ExternalApiProperties properties = new ExternalApiProperties();
        properties.setAmapApiKey("test-amap-key");
        properties.setAmapWeatherUrl("https://restapi.amap.com/v3/weather/weatherInfo");

        when(cacheService.get(eq("AMAP"), eq("weather:110101"), eq(WeatherDto.class)))
            .thenReturn(Optional.empty());

        server.expect(request -> {
                assertThat(request.getURI().getScheme()).isEqualTo("https");
                assertThat(request.getURI().getHost()).isEqualTo("restapi.amap.com");
                assertThat(request.getURI().getPath()).isEqualTo("/v3/weather/weatherInfo");
                assertThat(request.getURI().getQuery())
                    .contains("key=test-amap-key")
                    .contains("city=110101")
                    .contains("extensions=base")
                    .contains("output=JSON");
            })
            .andRespond(withSuccess("{"
                + "\"status\":\"1\","
                + "\"count\":\"1\","
                + "\"info\":\"OK\","
                + "\"infocode\":\"10000\","
                + "\"lives\":[{"
                + "\"province\":\"\\u5317\\u4eac\","
                + "\"city\":\"\\u4e1c\\u57ce\\u533a\","
                + "\"adcode\":\"110101\","
                + "\"weather\":\"\\u6674\","
                + "\"temperature\":\"17\","
                + "\"winddirection\":\"\\u897f\\u5357\","
                + "\"windpower\":\"\\u22643\","
                + "\"humidity\":\"27\","
                + "\"reporttime\":\"2026-04-28 18:30:00\""
                + "}]"
                + "}", MediaType.APPLICATION_JSON));

        WeatherDto weather = new AMapClient(restTemplate, properties, cacheService).getWeather("110101");

        assertThat(weather.getTemperature()).isEqualTo(17.0);
        assertThat(weather.getFeelsLike()).isEqualTo(17.0);
        assertThat(weather.getHumidity()).isEqualTo(27);
        assertThat(weather.getWindSpeed()).isEqualTo(4.5);
        assertThat(weather.getPrecipitation()).isEqualTo(0.0);
        assertThat(weather.getConditionCode()).isEqualTo("SUNNY");
        verify(cacheService).put(eq("AMAP"), eq("weather:110101"), any(WeatherDto.class), eq(Duration.ofMinutes(15)));
        server.verify();
    }

    @Test
    void getWeatherFallsBackWhenAmapInfocodeIsNotSuccess() {
        RestTemplate restTemplate = new RestTemplate();
        MockRestServiceServer server = MockRestServiceServer.bindTo(restTemplate).build();
        ApiCacheService cacheService = mock(ApiCacheService.class);
        ExternalApiProperties properties = new ExternalApiProperties();
        properties.setAmapApiKey("test-amap-key");
        properties.setAmapWeatherUrl("https://restapi.amap.com/v3/weather/weatherInfo");

        when(cacheService.get(eq("AMAP"), eq("weather:110101"), eq(WeatherDto.class)))
            .thenReturn(Optional.empty());

        server.expect(request -> assertThat(request.getURI().getQuery()).contains("city=110101"))
            .andRespond(withSuccess("{"
                + "\"status\":\"1\","
                + "\"info\":\"INVALID_USER_KEY\","
                + "\"infocode\":\"10001\","
                + "\"lives\":[{\"weather\":\"\\u6674\",\"temperature\":\"17\",\"humidity\":\"27\"}]"
                + "}", MediaType.APPLICATION_JSON));

        WeatherDto weather = new AMapClient(restTemplate, properties, cacheService).getWeather("110101");

        assertThat(weather.getTemperature()).isEqualTo(22.0);
        assertThat(weather.getHumidity()).isEqualTo(55);
        assertThat(weather.getConditionCode()).isEqualTo("CLOUDY");
        server.verify();
    }
}
