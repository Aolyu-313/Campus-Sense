package com.example.campussense.dto;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Size;

public class ProfileRequest {

    @NotBlank
    @Size(max = 128)
    private String deviceId;

    @NotBlank
    @Size(max = 20)
    private String preferredLanguage;

    public String getDeviceId() {
        return deviceId;
    }

    public void setDeviceId(String deviceId) {
        this.deviceId = deviceId;
    }

    public String getPreferredLanguage() {
        return preferredLanguage;
    }

    public void setPreferredLanguage(String preferredLanguage) {
        this.preferredLanguage = preferredLanguage;
    }
}
