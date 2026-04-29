package com.example.campussense.entity;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;
import java.time.LocalDateTime;

@Entity
@Table(name = "environment_snapshot")
public class EnvironmentSnapshot {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Double latitude;

    @Column(nullable = false)
    private Double longitude;

    @Column(name = "location_name")
    private String locationName;

    private String city;
    private Double temperature;

    @Column(name = "feels_like")
    private Double feelsLike;

    private Integer humidity;

    @Column(name = "wind_speed")
    private Double windSpeed;

    private Double precipitation;
    private Integer aqi;
    private Double pm25;
    private Double pm10;

    @Column(name = "condition_code")
    private String conditionCode;

    @Column(name = "air_quality_level_code")
    private String airQualityLevelCode;

    @Column(name = "comfort_score")
    private Integer comfortScore;

    @Column(name = "comfort_level_code")
    private String comfortLevelCode;

    @Column(name = "comfort_advice_code")
    private String comfortAdviceCode;

    private String source;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Double getLatitude() {
        return latitude;
    }

    public void setLatitude(Double latitude) {
        this.latitude = latitude;
    }

    public Double getLongitude() {
        return longitude;
    }

    public void setLongitude(Double longitude) {
        this.longitude = longitude;
    }

    public String getLocationName() {
        return locationName;
    }

    public void setLocationName(String locationName) {
        this.locationName = locationName;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public Double getTemperature() {
        return temperature;
    }

    public void setTemperature(Double temperature) {
        this.temperature = temperature;
    }

    public Double getFeelsLike() {
        return feelsLike;
    }

    public void setFeelsLike(Double feelsLike) {
        this.feelsLike = feelsLike;
    }

    public Integer getHumidity() {
        return humidity;
    }

    public void setHumidity(Integer humidity) {
        this.humidity = humidity;
    }

    public Double getWindSpeed() {
        return windSpeed;
    }

    public void setWindSpeed(Double windSpeed) {
        this.windSpeed = windSpeed;
    }

    public Double getPrecipitation() {
        return precipitation;
    }

    public void setPrecipitation(Double precipitation) {
        this.precipitation = precipitation;
    }

    public Integer getAqi() {
        return aqi;
    }

    public void setAqi(Integer aqi) {
        this.aqi = aqi;
    }

    public Double getPm25() {
        return pm25;
    }

    public void setPm25(Double pm25) {
        this.pm25 = pm25;
    }

    public Double getPm10() {
        return pm10;
    }

    public void setPm10(Double pm10) {
        this.pm10 = pm10;
    }

    public String getConditionCode() {
        return conditionCode;
    }

    public void setConditionCode(String conditionCode) {
        this.conditionCode = conditionCode;
    }

    public String getAirQualityLevelCode() {
        return airQualityLevelCode;
    }

    public void setAirQualityLevelCode(String airQualityLevelCode) {
        this.airQualityLevelCode = airQualityLevelCode;
    }

    public Integer getComfortScore() {
        return comfortScore;
    }

    public void setComfortScore(Integer comfortScore) {
        this.comfortScore = comfortScore;
    }

    public String getComfortLevelCode() {
        return comfortLevelCode;
    }

    public void setComfortLevelCode(String comfortLevelCode) {
        this.comfortLevelCode = comfortLevelCode;
    }

    public String getComfortAdviceCode() {
        return comfortAdviceCode;
    }

    public void setComfortAdviceCode(String comfortAdviceCode) {
        this.comfortAdviceCode = comfortAdviceCode;
    }

    public String getSource() {
        return source;
    }

    public void setSource(String source) {
        this.source = source;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
