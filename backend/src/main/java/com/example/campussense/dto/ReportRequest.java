package com.example.campussense.dto;

import com.example.campussense.validation.EnumValue;

import javax.validation.constraints.DecimalMax;
import javax.validation.constraints.DecimalMin;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;
import java.util.ArrayList;
import java.util.List;

public class ReportRequest {

    @NotBlank
    @Size(max = 128)
    private String deviceId;

    @NotNull
    @DecimalMin("-90.0")
    @DecimalMax("90.0")
    private Double latitude;

    @NotNull
    @DecimalMin("-180.0")
    @DecimalMax("180.0")
    private Double longitude;

    @NotBlank
    @Size(max = 40)
    @EnumValue(anyOf = {"STUDY", "REST", "WALK", "COMMUTE", "GENERAL"})
    private String scene;

    @Size(max = 40)
    @EnumValue(anyOf = {"UNKNOWN", "STATIONARY", "LOW_MOTION", "WALKING", "RUNNING", "CYCLING", "MOVING"})
    private String movementState = "UNKNOWN";

    @Size(max = 12)
    private List<@Size(max = 40) String> tags = new ArrayList<String>();

    @Size(max = 500)
    private String note;

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
}
