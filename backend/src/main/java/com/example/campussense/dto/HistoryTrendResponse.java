package com.example.campussense.dto;

import java.util.ArrayList;
import java.util.List;

public class HistoryTrendResponse {

    private String deviceId;
    private List<HistoryTrendPointResponse> points = new ArrayList<HistoryTrendPointResponse>();

    public String getDeviceId() {
        return deviceId;
    }

    public void setDeviceId(String deviceId) {
        this.deviceId = deviceId;
    }

    public List<HistoryTrendPointResponse> getPoints() {
        return points;
    }

    public void setPoints(List<HistoryTrendPointResponse> points) {
        this.points = points;
    }
}
