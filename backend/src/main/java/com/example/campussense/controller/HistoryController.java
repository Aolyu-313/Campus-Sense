package com.example.campussense.controller;

import com.example.campussense.dto.HistoryRecordResponse;
import com.example.campussense.dto.HistoryTrendResponse;
import com.example.campussense.service.ReportService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Max;
import javax.validation.constraints.Min;
import java.util.List;

@Validated
@RestController
@RequestMapping("/api")
public class HistoryController {

    private final ReportService reportService;

    public HistoryController(ReportService reportService) {
        this.reportService = reportService;
    }

    @GetMapping("/history")
    public List<HistoryRecordResponse> history(@RequestParam("deviceId") @NotBlank String deviceId) {
        return reportService.findHistory(deviceId);
    }

    @GetMapping("/history/trends")
    public HistoryTrendResponse trends(
        @RequestParam("deviceId") @NotBlank String deviceId,
        @RequestParam(value = "limit", defaultValue = "10") @Min(1) @Max(100) int limit
    ) {
        return reportService.findTrends(deviceId, limit);
    }
}
