package com.example.campussense.service;

import com.example.campussense.config.ExternalApiProperties;
import com.example.campussense.entity.ApiCache;
import com.example.campussense.repository.ApiCacheRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Optional;

@Service
public class ApiCacheService {

    private final ApiCacheRepository repository;
    private final ObjectMapper objectMapper;
    private final ExternalApiProperties properties;

    public ApiCacheService(ApiCacheRepository repository, ObjectMapper objectMapper, ExternalApiProperties properties) {
        this.repository = repository;
        this.objectMapper = objectMapper;
        this.properties = properties;
    }

    public <T> Optional<T> get(String provider, String cacheKey, Class<T> type) {
        if (!properties.isCacheEnabled()) {
            return Optional.empty();
        }
        Optional<ApiCache> cache = repository.findByProviderAndCacheKey(provider, cacheKey);
        if (!cache.isPresent() || cache.get().getExpiresAt().isBefore(LocalDateTime.now())) {
            return Optional.empty();
        }
        try {
            return Optional.of(objectMapper.readValue(cache.get().getResponseJson(), type));
        } catch (Exception ignored) {
            return Optional.empty();
        }
    }

    @Transactional
    public void put(String provider, String cacheKey, Object value, Duration ttl) {
        if (!properties.isCacheEnabled()) {
            return;
        }
        try {
            ApiCache cache = repository.findByProviderAndCacheKey(provider, cacheKey).orElse(new ApiCache());
            cache.setProvider(provider);
            cache.setCacheKey(cacheKey);
            cache.setResponseJson(objectMapper.writeValueAsString(value));
            cache.setExpiresAt(LocalDateTime.now().plus(ttl));
            repository.save(cache);
        } catch (Exception ignored) {
            // Cache writes must never break the main user journey.
        }
    }
}
