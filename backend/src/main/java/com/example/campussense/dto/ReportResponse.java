package com.example.campussense.dto;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class ReportResponse {

    private Long id;
    private String deviceId;
    private Double latitude;
    private Double longitude;
    private String scene;
    private String movementState;
    private List<String> tags = new ArrayList<String>();
    private String note;
    private Integer comfortScore;
    private LocalDateTime createdAt;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getDeviceId() {
        return deviceId;
    }

    public void setDeviceId(String deviceId) {
        this.deviceId = deviceId;
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

    public String getScene() {
        return scene;
    }

    public void setScene(String scene) {
        this.scene = scene;
    }

    public String getMovementState() {
        return movementState;
    }

    public void setMovementState(String movementState) {
        this.movementState = movementState;
    }

    public List<String> getTags() {
        return tags;
    }

    public void setTags(List<String> tags) {
        this.tags = tags;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public Integer getComfortScore() {
        return comfortScore;
    }

    public void setComfortScore(Integer comfortScore) {
        this.comfortScore = comfortScore;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
