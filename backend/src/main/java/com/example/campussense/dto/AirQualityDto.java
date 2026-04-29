package com.example.campussense.dto;

public class AirQualityDto {

    private Integer aqi;
    private Double pm25;
    private Double pm10;
    private String levelCode;

    public AirQualityDto() {
    }

    public AirQualityDto(Integer aqi, Double pm25, Double pm10, String levelCode) {
        this.aqi = aqi;
        this.pm25 = pm25;
        this.pm10 = pm10;
        this.levelCode = levelCode;
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

    public String getLevelCode() {
        return levelCode;
    }

    public void setLevelCode(String levelCode) {
        this.levelCode = levelCode;
    }
}
