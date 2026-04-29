package com.example.campussense.entity;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;
import java.time.LocalDateTime;

@Entity
@Table(name = "user_report")
public class UserReport {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "device_id", nullable = false, length = 128)
    private String deviceId;

    @Column(nullable = false)
    private Double latitude;

    @Column(nullable = false)
    private Double longitude;

    @Column(nullable = false, length = 40)
    private String scene;

    @Column(name = "movement_state", length = 40)
    private String movementState;

    @Column(length = 500)
    private String tags;

    @Column(length = 500)
    private String note;

    @Column(name = "comfort_score")
    private Integer comfortScore;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "environment_snapshot_id")
    private EnvironmentSnapshot environmentSnapshot;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

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

    public String getTags() {
        return tags;
    }

    public void setTags(String tags) {
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

    public EnvironmentSnapshot getEnvironmentSnapshot() {
        return environmentSnapshot;
    }

    public void setEnvironmentSnapshot(EnvironmentSnapshot environmentSnapshot) {
        this.environmentSnapshot = environmentSnapshot;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
