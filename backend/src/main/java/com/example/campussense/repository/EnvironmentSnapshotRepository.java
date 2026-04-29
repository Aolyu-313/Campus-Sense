package com.example.campussense.repository;

import com.example.campussense.entity.EnvironmentSnapshot;
import org.springframework.data.jpa.repository.JpaRepository;

public interface EnvironmentSnapshotRepository extends JpaRepository<EnvironmentSnapshot, Long> {
}
