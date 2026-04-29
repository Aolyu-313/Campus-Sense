package com.example.campussense.dto;

public class EnvironmentCurrentResponse {

    private LocationDto location;
    private WeatherDto weather;
    private AirQualityDto airQuality;
    private ComfortDto comfort;

    public EnvironmentCurrentResponse() {
    }

    public EnvironmentCurrentResponse(LocationDto location, WeatherDto weather, AirQualityDto airQuality, ComfortDto comfort) {
        this.location = location;
        this.weather = weather;
        this.airQuality = airQuality;
        this.comfort = comfort;
    }

    public LocationDto getLocation() {
        return location;
    }

    public void setLocation(LocationDto location) {
        this.location = location;
    }

    public WeatherDto getWeather() {
        return weather;
    }

    public void setWeather(WeatherDto weather) {
        this.weather = weather;
    }

    public AirQualityDto getAirQuality() {
        return airQuality;
    }

    public void setAirQuality(AirQualityDto airQuality) {
        this.airQuality = airQuality;
    }

    public ComfortDto getComfort() {
        return comfort;
    }

    public void setComfort(ComfortDto comfort) {
        this.comfort = comfort;
    }
}
