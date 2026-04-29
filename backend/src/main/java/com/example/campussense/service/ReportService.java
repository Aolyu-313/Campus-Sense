package com.example.campussense.service;

import com.example.campussense.dto.HistoryRecordResponse;
import com.example.campussense.dto.HistoryTrendPointResponse;
import com.example.campussense.dto.HistoryTrendResponse;
import com.example.campussense.dto.NearbyReportResponse;
import com.example.campussense.dto.ReportRequest;
import com.example.campussense.dto.ReportResponse;
import com.example.campussense.entity.EnvironmentSnapshot;
import com.example.campussense.entity.UserReport;
import com.example.campussense.repository.UserReportRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ReportService {

    private final UserReportRepository reportRepository;
    private final EnvironmentService environmentService;
    private final ProfileService profileService;

    public ReportService(UserReportRepository reportRepository,
                         EnvironmentService environmentService,
                         ProfileService profileService) {
        this.reportRepository = reportRepository;
        this.environmentService = environmentService;
        this.profileService = profileService;
    }

    @Transactional
    public ReportResponse submit(ReportRequest request) {
        profileService.ensureProfile(request.getDeviceId());
        EnvironmentSnapshot snapshot = environmentService.captureSnapshot(
            request.getLatitude(),
            request.getLongitude(),
            request.getMovementState(),
            "REPORT_SUBMIT"
        );

        UserReport report = new UserReport();
        report.setDeviceId(request.getDeviceId());
        report.setLatitude(request.getLatitude());
        report.setLongitude(request.getLongitude());
        report.setScene(normalizeCode(request.getScene(), "GENERAL"));
        report.setMovementState(normalizeCode(request.getMovementState(), "UNKNOWN"));
        report.setTags(joinTags(request.getTags()));
        report.setNote(request.getNote());
        report.setComfortScore(snapshot.getComfortScore());
        report.setEnvironmentSnapshot(snapshot);
        report.setCreatedAt(LocalDateTime.now());
        return toReportResponse(reportRepository.save(report));
    }

    @Transactional(readOnly = true)
    public List<NearbyReportResponse> findNearby(double latitude, double longitude, double radiusMeters) {
        double safeRadius = radiusMeters <= 0 ? 500.0 : Math.min(radiusMeters, 5000.0);
        List<NearbyReportResponse> nearby = new ArrayList<NearbyReportResponse>();
        for (UserReport report : reportRepository.findAll()) {
            double distance = environmentService.distanceMeters(latitude, longitude, report.getLatitude(), report.getLongitude());
            if (distance <= safeRadius) {
                NearbyReportResponse response = toNearbyResponse(report);
                response.setDistanceMeters(round(distance));
                nearby.add(response);
            }
        }
        Collections.sort(nearby, new Comparator<NearbyReportResponse>() {
            @Override
            public int compare(NearbyReportResponse left, NearbyReportResponse right) {
                return left.getDistanceMeters().compareTo(right.getDistanceMeters());
            }
        });
        return nearby;
    }

    @Transactional(readOnly = true)
    public List<HistoryRecordResponse> findHistory(String deviceId) {
        return reportRepository.findByDeviceIdOrderByCreatedAtDesc(deviceId).stream()
            .map(this::toHistoryResponse)
            .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public HistoryTrendResponse findTrends(String deviceId, int limit) {
        List<UserReport> reports = reportRepository.findByDeviceIdOrderByCreatedAtDesc(deviceId);
        int safeLimit = Math.max(1, Math.min(limit, 100));
        List<UserReport> limited = reports.stream()
            .limit(safeLimit)
            .collect(Collectors.toList());
        Collections.reverse(limited);

        HistoryTrendResponse response = new HistoryTrendResponse();
        response.setDeviceId(deviceId);
        response.setPoints(limited.stream()
            .map(this::toTrendPoint)
            .collect(Collectors.toList()));
        return response;
    }

    private ReportResponse toReportResponse(UserReport report) {
        ReportResponse response = new ReportResponse();
        copyReportFields(report, response);
        return response;
    }

    private NearbyReportResponse toNearbyResponse(UserReport report) {
        NearbyReportResponse response = new NearbyReportResponse();
        copyReportFields(report, response);
        return response;
    }

    private HistoryRecordResponse toHistoryResponse(UserReport report) {
        HistoryRecordResponse response = new HistoryRecordResponse();
        copyReportFields(report, response);
        if (report.getEnvironmentSnapshot() != null) {
            response.setEnvironmentSnapshot(environmentService.toResponse(report.getEnvironmentSnapshot()));
        }
        return response;
    }

    private HistoryTrendPointResponse toTrendPoint(UserReport report) {
        HistoryTrendPointResponse point = new HistoryTrendPointResponse();
        point.setCreatedAt(report.getCreatedAt());
        point.setComfortScore(report.getComfortScore());
        if (report.getEnvironmentSnapshot() != null) {
            point.setAqi(report.getEnvironmentSnapshot().getAqi());
            point.setTemperature(report.getEnvironmentSnapshot().getTemperature());
        }
        return point;
    }

    private void copyReportFields(UserReport report, ReportResponse response) {
        response.setId(report.getId());
        response.setDeviceId(report.getDeviceId());
        response.setLatitude(report.getLatitude());
        response.setLongitude(report.getLongitude());
        response.setScene(report.getScene());
        response.setMovementState(report.getMovementState());
        response.setTags(splitTags(report.getTags()));
        response.setNote(report.getNote());
        response.setComfortScore(report.getComfortScore());
        response.setCreatedAt(report.getCreatedAt());
    }

    private String joinTags(List<String> tags) {
        if (tags == null || tags.isEmpty()) {
            return "";
        }
        List<String> normalized = new ArrayList<String>();
        for (String tag : tags) {
            if (tag != null && !tag.trim().isEmpty()) {
                normalized.add(normalizeCode(tag, tag));
            }
        }
        return String.join(",", normalized);
    }

    private List<String> splitTags(String tags) {
        if (tags == null || tags.trim().isEmpty()) {
            return new ArrayList<String>();
        }
        return Arrays.asList(tags.split(","));
    }

    private String normalizeCode(String value, String fallback) {
        if (value == null || value.trim().isEmpty()) {
            return fallback;
        }
        return value.trim().toUpperCase().replace('-', '_').replace(' ', '_');
    }

    private double round(double value) {
        return Math.round(value * 10.0) / 10.0;
    }
}
