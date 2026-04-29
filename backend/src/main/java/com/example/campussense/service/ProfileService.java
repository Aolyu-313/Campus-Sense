package com.example.campussense.service;

import com.example.campussense.dto.ProfileRequest;
import com.example.campussense.dto.ProfileResponse;
import com.example.campussense.entity.UserProfile;
import com.example.campussense.exception.ApiException;
import com.example.campussense.exception.ErrorCode;
import com.example.campussense.repository.UserProfileRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Optional;

@Service
public class ProfileService {

    private final UserProfileRepository userProfileRepository;

    public ProfileService(UserProfileRepository userProfileRepository) {
        this.userProfileRepository = userProfileRepository;
    }

    @Transactional
    public ProfileResponse get(String deviceId) {
        return toResponse(findOrCreateDefault(deviceId));
    }

    @Transactional
    public ProfileResponse upsert(ProfileRequest request) {
        UserProfile profile = userProfileRepository.findByDeviceId(request.getDeviceId()).orElse(new UserProfile());
        if (profile.getDeviceId() == null) {
            profile.setDeviceId(request.getDeviceId());
            profile.setCreatedAt(LocalDateTime.now());
        }
        profile.setPreferredLanguage(normalizeLanguage(request.getPreferredLanguage()));
        return toResponse(userProfileRepository.save(profile));
    }

    @Transactional
    public void ensureProfile(String deviceId) {
        findOrCreateDefault(deviceId);
    }

    private UserProfile findOrCreateDefault(String deviceId) {
        Optional<UserProfile> existing = userProfileRepository.findByDeviceId(deviceId);
        if (existing.isPresent()) {
            return existing.get();
        }
        UserProfile profile = new UserProfile();
        profile.setDeviceId(deviceId);
        profile.setPreferredLanguage("en");
        profile.setCreatedAt(LocalDateTime.now());
        return userProfileRepository.save(profile);
    }

    private ProfileResponse toResponse(UserProfile profile) {
        ProfileResponse response = new ProfileResponse();
        response.setDeviceId(profile.getDeviceId());
        response.setPreferredLanguage(profile.getPreferredLanguage());
        response.setCreatedAt(profile.getCreatedAt());
        return response;
    }

    private String normalizeLanguage(String language) {
        String normalized = language == null ? "" : language.trim().toLowerCase();
        if ("zh".equals(normalized) || "zh-cn".equals(normalized) || "zh_cn".equals(normalized)) {
            return "zh";
        }
        if ("en".equals(normalized) || "en-us".equals(normalized) || "en_gb".equals(normalized)) {
            return "en";
        }
        throw new ApiException(ErrorCode.INVALID_REQUEST, "preferredLanguage must be either zh or en.");
    }
}
