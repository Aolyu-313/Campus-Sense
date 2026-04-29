package com.example.campussense.controller;

import com.example.campussense.dto.NearbyReportResponse;
import com.example.campussense.dto.ReportRequest;
import com.example.campussense.dto.ReportResponse;
import com.example.campussense.service.ReportService;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.Valid;
import javax.validation.constraints.DecimalMax;
import javax.validation.constraints.DecimalMin;
import java.net.URI;
import java.util.List;

@Validated
@RestController
@RequestMapping("/api/reports")
public class ReportController {

    private final ReportService reportService;

    public ReportController(ReportService reportService) {
        this.reportService = reportService;
    }

    @PostMapping
    public ResponseEntity<ReportResponse> submit(@Valid @RequestBody ReportRequest request) {
        ReportResponse response = reportService.submit(request);
        return ResponseEntity.created(URI.create("/api/reports/" + response.getId())).body(response);
    }

    @GetMapping("/nearby")
    public List<NearbyReportResponse> nearby(
        @RequestParam("lat") @DecimalMin("-90.0") @DecimalMax("90.0") double latitude,
        @RequestParam("lon") @DecimalMin("-180.0") @DecimalMax("180.0") double longitude,
        @RequestParam(value = "radius", defaultValue = "500") @DecimalMin("1.0") @DecimalMax("5000.0") double radius
    ) {
        return reportService.findNearby(latitude, longitude, radius);
    }
}
