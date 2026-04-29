package com.example.campussense.repository;

import com.example.campussense.entity.UserReport;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;

public interface UserReportRepository extends JpaRepository<UserReport, Long> {
    List<UserReport> findByDeviceIdOrderByCreatedAtDesc(String deviceId);

    List<UserReport> findByCreatedAtAfter(LocalDateTime createdAt);
}
