package com.example.campussense.service;

import com.example.campussense.dto.AirQualityDto;
import com.example.campussense.dto.ComfortDto;
import com.example.campussense.dto.EnvironmentCurrentResponse;
import com.example.campussense.dto.LocationDto;
import com.example.campussense.dto.WeatherDto;
import com.example.campussense.entity.EnvironmentSnapshot;
import com.example.campussense.entity.UserReport;
import com.example.campussense.exception.ApiException;
import com.example.campussense.exception.ErrorCode;
import com.example.campussense.provider.AMapClient;
import com.example.campussense.provider.QWeatherClient;
import com.example.campussense.repository.EnvironmentSnapshotRepository;
import com.example.campussense.repository.UserReportRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class EnvironmentService {

    private final AMapClient aMapClient;
    private final QWeatherClient qWeatherClient;
    private final ComfortScoreService comfortScoreService;
    private final EnvironmentSnapshotRepository snapshotRepository;
    private final UserReportRepository reportRepository;

    public EnvironmentService(AMapClient aMapClient,
                              QWeatherClient qWeatherClient,
                              ComfortScoreService comfortScoreService,
                              EnvironmentSnapshotRepository snapshotRepository,
                              UserReportRepository reportRepository) {
        this.aMapClient = aMapClient;
        this.qWeatherClient = qWeatherClient;
        this.comfortScoreService = comfortScoreService;
        this.snapshotRepository = snapshotRepository;
        this.reportRepository = reportRepository;
    }

    @Transactional
    public EnvironmentCurrentResponse getCurrent(double latitude, double longitude, String movementState) {
        EnvironmentSnapshot snapshot = captureSnapshot(latitude, longitude, movementState, "CURRENT_QUERY");
        return toResponse(snapshot);
    }

    @Transactional
    public EnvironmentSnapshot captureSnapshot(double latitude, double longitude, String movementState, String source) {
        validateLocation(latitude, longitude);
        LocationDto location = aMapClient.reverseGeocode(latitude, longitude);
        WeatherDto weather = aMapClient.getWeather(location.getAdcode());
        AirQualityDto airQuality = qWeatherClient.getAirQuality(latitude, longitude);
        double feedbackSignal = nearbyFeedbackSignal(latitude, longitude);
        double recencySignal = feedbackRecencySignal(latitude, longitude);
        ComfortDto comfort = comfortScoreService.calculate(weather, airQuality, feedbackSignal, movementState, recencySignal);

        EnvironmentSnapshot snapshot = new EnvironmentSnapshot();
        snapshot.setLatitude(latitude);
        snapshot.setLongitude(longitude);
        snapshot.setLocationName(location.getName());
        snapshot.setCity(location.getCity());
        snapshot.setTemperature(weather.getTemperature());
        snapshot.setFeelsLike(weather.getFeelsLike());
        snapshot.setHumidity(weather.getHumidity());
        snapshot.setWindSpeed(weather.getWindSpeed());
        snapshot.setPrecipitation(weather.getPrecipitation());
        snapshot.setConditionCode(weather.getConditionCode());
        snapshot.setAqi(airQuality.getAqi());
        snapshot.setPm25(airQuality.getPm25());
        snapshot.setPm10(airQuality.getPm10());
        snapshot.setAirQualityLevelCode(airQuality.getLevelCode());
        snapshot.setComfortScore(comfort.getScore());
        snapshot.setComfortLevelCode(comfort.getLevelCode());
        snapshot.setComfortAdviceCode(comfort.getAdviceCode());
        snapshot.setSource(source);
        return snapshotRepository.save(snapshot);
    }

    public EnvironmentCurrentResponse toResponse(EnvironmentSnapshot snapshot) {
        LocationDto location = new LocationDto(snapshot.getLatitude(), snapshot.getLongitude(), snapshot.getLocationName(), snapshot.getCity(), "");
        WeatherDto weather = new WeatherDto(
            snapshot.getTemperature(),
            snapshot.getFeelsLike(),
            snapshot.getHumidity(),
            snapshot.getWindSpeed(),
            snapshot.getPrecipitation(),
            snapshot.getConditionCode()
        );
        AirQualityDto airQuality = new AirQualityDto(snapshot.getAqi(), snapshot.getPm25(), snapshot.getPm10(), snapshot.getAirQualityLevelCode());
        ComfortDto comfort = new ComfortDto(snapshot.getComfortScore(), snapshot.getComfortLevelCode(), snapshot.getComfortAdviceCode());
        return new EnvironmentCurrentResponse(location, weather, airQuality, comfort);
    }

    private double nearbyFeedbackSignal(double latitude, double longitude) {
        List<UserReport> recentReports = reportRepository.findByCreatedAtAfter(LocalDateTime.now().minusHours(24));
        if (recentReports.isEmpty()) {
            return 0.65;
        }
        double total = 0.0;
        int count = 0;
        for (UserReport report : recentReports) {
            double distance = distanceMeters(latitude, longitude, report.getLatitude(), report.getLongitude());
            if (distance <= 500.0) {
                total += reportSignal(report);
                count++;
            }
        }
        if (count == 0) {
            return 0.65;
        }
        return clamp((total / count + 1.0) / 2.0, 0.0, 1.0);
    }

    private double feedbackRecencySignal(double latitude, double longitude) {
        List<UserReport> reports = reportRepository.findByCreatedAtAfter(LocalDateTime.now().minusHours(24));
        double best = 0.7;
        for (UserReport report : reports) {
            if (distanceMeters(latitude, longitude, report.getLatitude(), report.getLongitude()) <= 500.0) {
                long minutes = java.time.Duration.between(report.getCreatedAt(), LocalDateTime.now()).toMinutes();
                best = Math.max(best, 1.0 - Math.min(0.8, minutes / 1440.0));
            }
        }
        return clamp(best, 0.0, 1.0);
    }

    private double reportSignal(UserReport report) {
        String tags = report.getTags() == null ? "" : report.getTags().toUpperCase();
        double signal = 0.0;
        if (tags.contains("COMFORTABLE") || tags.contains("QUIET") || tags.contains("GOOD_FOR_STUDY")) {
            signal += 1.0;
        }
        if (tags.contains("TOO_HOT") || tags.contains("TOO_COLD") || tags.contains("TOO_NOISY") || tags.contains("POOR_AIR")) {
            signal -= 1.0;
        }
        if (report.getComfortScore() != null) {
            signal += (report.getComfortScore() - 50.0) / 50.0;
        }
        return clamp(signal / 2.0, -1.0, 1.0);
    }

    public double distanceMeters(double lat1, double lon1, double lat2, double lon2) {
        double earthRadius = 6371000.0;
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
            + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
            * Math.sin(dLon / 2) * Math.sin(dLon / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return earthRadius * c;
    }

    private void validateLocation(double latitude, double longitude) {
        if (latitude < -90.0 || latitude > 90.0 || longitude < -180.0 || longitude > 180.0) {
            throw new ApiException(ErrorCode.INVALID_LOCATION, "Latitude must be between -90 and 90 and longitude must be between -180 and 180.");
        }
    }

    private double clamp(double value, double min, double max) {
        return Math.max(min, Math.min(max, value));
    }
}
