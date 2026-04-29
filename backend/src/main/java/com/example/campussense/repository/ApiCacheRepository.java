package com.example.campussense.repository;

import com.example.campussense.entity.ApiCache;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ApiCacheRepository extends JpaRepository<ApiCache, Long> {
    Optional<ApiCache> findByProviderAndCacheKey(String provider, String cacheKey);
}
