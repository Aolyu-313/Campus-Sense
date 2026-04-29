package com.example.campussense.dto;

public class LocationDto {

    private Double latitude;
    private Double longitude;
    private String name;
    private String city;
    private String adcode;

    public LocationDto() {
    }

    public LocationDto(Double latitude, Double longitude, String name, String city, String adcode) {
        this.latitude = latitude;
        this.longitude = longitude;
        this.name = name;
        this.city = city;
        this.adcode = adcode;
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

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getAdcode() {
        return adcode;
    }

    public void setAdcode(String adcode) {
        this.adcode = adcode;
    }
}
