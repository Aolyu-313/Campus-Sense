package com.example.campussense.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "campussense.external")
public class ExternalApiProperties {

    private String qweatherApiKey;
    private String amapApiKey;
    private String qweatherAirUrl = "https://devapi.qweather.com/v7/air/now";
    private String amapRegeoUrl = "https://restapi.amap.com/v3/geocode/regeo";
    private String amapWeatherUrl = "https://restapi.amap.com/v3/weather/weatherInfo";
    private boolean cacheEnabled = true;

    public boolean hasQWeatherApiKey() {
        return qweatherApiKey != null && !qweatherApiKey.trim().isEmpty();
    }

    public boolean hasAmapApiKey() {
        return amapApiKey != null && !amapApiKey.trim().isEmpty();
    }

    public String getQweatherApiKey() {
        return qweatherApiKey;
    }

    public void setQweatherApiKey(String qweatherApiKey) {
        this.qweatherApiKey = qweatherApiKey;
    }

    public String getAmapApiKey() {
        return amapApiKey;
    }

    public void setAmapApiKey(String amapApiKey) {
        this.amapApiKey = amapApiKey;
    }

    public String getQweatherAirUrl() {
        return qweatherAirUrl;
    }

    public void setQweatherAirUrl(String qweatherAirUrl) {
        this.qweatherAirUrl = qweatherAirUrl;
    }

    public String getAmapRegeoUrl() {
        return amapRegeoUrl;
    }

    public void setAmapRegeoUrl(String amapRegeoUrl) {
        this.amapRegeoUrl = amapRegeoUrl;
    }

    public String getAmapWeatherUrl() {
        return amapWeatherUrl;
    }

    public void setAmapWeatherUrl(String amapWeatherUrl) {
        this.amapWeatherUrl = amapWeatherUrl;
    }

    public boolean isCacheEnabled() {
        return cacheEnabled;
    }

    public void setCacheEnabled(boolean cacheEnabled) {
        this.cacheEnabled = cacheEnabled;
    }
}
