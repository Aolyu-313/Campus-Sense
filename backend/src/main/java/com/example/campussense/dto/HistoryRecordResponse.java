package com.example.campussense.dto;

public class HistoryRecordResponse extends ReportResponse {

    private EnvironmentCurrentResponse environmentSnapshot;

    public EnvironmentCurrentResponse getEnvironmentSnapshot() {
        return environmentSnapshot;
    }

    public void setEnvironmentSnapshot(EnvironmentCurrentResponse environmentSnapshot) {
        this.environmentSnapshot = environmentSnapshot;
    }
}
