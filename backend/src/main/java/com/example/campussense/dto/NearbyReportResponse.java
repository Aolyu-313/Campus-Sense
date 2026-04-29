package com.example.campussense.dto;

public class NearbyReportResponse extends ReportResponse {

    private Double distanceMeters;

    public Double getDistanceMeters() {
        return distanceMeters;
    }

    public void setDistanceMeters(Double distanceMeters) {
        this.distanceMeters = distanceMeters;
    }
}
