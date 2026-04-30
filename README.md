# CampusSense

>  CampusSense is a Flutter mobile application for sensing, reporting, and reviewing campus micro-environment comfort. It combines mobile GPS, accelerometer-based movement context, weather data, air quality data, and anonymous user feedback to calculate a location-based comfort score.

---

## Table of Contents

- [1. Project Overview](#1-project-overview)
- [2. Problem Statement](#2-problem-statement)
- [3. Target Users and Persona](#3-target-users-and-persona)
- [4. User Journey and Storyboard](#4-user-journey-and-storyboard)
- [5. Key Features](#5-key-features)
- [6. Screens and Interaction Design](#6-screens-and-interaction-design)
  - [6.1 Splash / Onboarding](#61-splash--onboarding)
  - [6.2 Dashboard](#62-dashboard)
  - [6.3 Report](#63-report)
  - [6.4 History](#64-history)
  - [6.5 Nearby](#65-nearby)
  - [6.6 Settings](#66-settings)
- [7. System Architecture](#7-system-architecture)
- [8. Sensors, APIs and Services](#8-sensors-apis-and-services)
  - [Mobile sensors](#mobile-sensors)
  - [External APIs / services](#external-apis--services)
- [9. Data Collection and Handling](#9-data-collection-and-handling)
  - [Data collected](#data-collected)
  - [Privacy approach](#privacy-approach)
- [10. Comfort Score Logic](#10-comfort-score-logic)
- [11. Project Structure](#11-project-structure)
- [12. How to Run Locally](#12-how-to-run-locally)
  - [12.1 Prerequisites](#121-prerequisites)
  - [12.2 Start MySQL](#122-start-mysql)
  - [12.3 Start the backend](#123-start-the-backend)
  - [12.4 Run the Flutter mobile app](#124-run-the-flutter-mobile-app)
- [13. Testing](#13-testing)
  - [13.1 Flutter tests](#131-flutter-tests)
  - [13.2 Flutter static analysis](#132-flutter-static-analysis)
  - [13.3 Backend tests](#133-backend-tests)
  - [13.4 Manual user testing scenario](#134-manual-user-testing-scenario)
- [14. Demo Video and Release APK](#14-demo-video-and-release-apk)
  - [Demo video](#demo-video)
  - [Release APK](#release-apk)
- [15. Design Process](#15-design-process)
  - [Design goals](#design-goals)
- [16. Limitations](#16-limitations)
- [17. Future Improvements](#17-future-improvements)
- [18. Use of Generative AI](#18-use-of-generative-ai)
---

## 1. Project Overview

CampusSense is a connected-environment mobile system that helps users understand whether a nearby campus space is comfortable for staying, studying, resting, or moving through. The mobile app presents a simple **comfort score** based on sensor input, external environmental data, and user reports. The system includes a Flutter mobile app, a Spring Boot backend, and a MySQL database.

**Main idea**

```text
Mobile sensing + environmental APIs + user feedback
        ↓
Campus micro-environment comfort score
        ↓
Dashboard, reports, history, and nearby comfort map
```

---

## 2. Problem Statement

Campus users often make quick decisions about where to study, rest, or spend time outdoors, but they usually do not have an easy way to combine objective environmental data with subjective comfort feedback. Weather apps can show temperature, but they do not explain whether a specific campus micro-location feels comfortable. CampusSense addresses this gap by combining location, movement context, weather, air quality, and nearby user feedback into one readable comfort score.


---

## 3. Target Users and Persona

### Persona

**Name**: Campus student / campus visitor  
**Context**: Moving between study spaces, outdoor seating areas, libraries, cafés, and transport points.  
**Needs**:
- Understand whether a location is comfortable before staying there.
- Quickly compare nearby spaces.
- Report subjective comfort conditions.
- Review previous reports and trends.

---

## 4. User Journey and Storyboard

1. The user opens CampusSense before choosing a study or rest location.
2. The app obtains the current GPS coordinate from the mobile device or emulator.
3. The app reads the accelerometer stream and classifies the movement context, such as stationary or walking.
4. The backend requests weather and air quality data and calculates a comfort score.
5. The user reads the dashboard and decides whether the space is suitable.
6. The user submits a subjective report with scene type, feedback tags, and an optional note.
7. The user can later review their own history and explore nearby comfort reports.

---

## 5. Key Features

- Real-time comfort dashboard
- GPS-based location sensing
- Accelerometer-based movement state detection
- Weather and air quality integration
- Anonymous user feedback reporting
- History page with trend review
- Nearby reports and spatial comfort view
- Configurable backend URL
- Health check for backend connection
- English / Chinese language switch

---

## 6. Screens and Interaction Design

### 6.1 Splash / Onboarding

Introduces the purpose of CampusSense and prepares the user for location-based environmental sensing.

Screenshot path：

```text
screenshots/01_splash.png
```

### 6.2 Dashboard

Displays the current comfort score, comfort level, GPS coordinate, location source, movement state, weather, humidity, air quality, and advice.

Screenshot path：

```text
screenshots/02_dashboard.png
```

### 6.3 Report
 
Allows the user to submit a subjective environmental comfort report. The report includes a scene, feedback tags, optional note, device ID, GPS coordinate, and movement state.

Screenshot path：

```text
screenshots/03_report.png
```

### 6.4 History

Shows recent user reports and trend data for the current anonymous device ID.

Screenshot path：

```text
screenshots/04_history.png
```

### 6.5 Nearby

Shows nearby reports and a lightweight spatial comfort map based on coordinates and distance.

Screenshot path：

```text
screenshots/05_nearby.png
```

### 6.6 Settings

Allows the user to configure the backend base URL, check backend health, view the anonymous device ID, set demo coordinates, and switch language.

Screenshot path：

```text
screenshots/06_settings.png
```

---

## 7. System Architecture

CampusSense uses a mobile-backend-database architecture:

```text
Flutter Mobile App
  ├─ GPS location via geolocator
  ├─ Accelerometer stream via sensors_plus
  ├─ Local settings via shared_preferences
  └─ HTTP requests to backend
        ↓
Spring Boot Backend
  ├─ REST API controllers
  ├─ Comfort score calculation
  ├─ AMap reverse geocoding and weather lookup
  ├─ QWeather air quality lookup
  ├─ API fallback and cache logic
  └─ JPA repositories
        ↓
MySQL Database
  ├─ User reports
  ├─ Environment snapshots
  ├─ Anonymous user profile
  └─ API cache
```


---

## 8. Sensors, APIs and Services

### Mobile sensors

| Sensor / capability | Use in CampusSense |
|---|---|
| GPS location | Gets latitude and longitude for environmental lookup and nearby reports |
| Accelerometer | Infers movement state such as stationary, low motion, walking, or moving |
| Network access | Sends HTTP requests to the Spring Boot backend |
| Local storage | Stores backend URL, device ID, language, and demo coordinates |

### External APIs / services

| Service | Purpose |
|---|---|
| AMap | Reverse geocoding and weatherInfo weather lookup |
| QWeather | Air quality lookup |
| Spring Boot backend | Aggregates data and exposes REST APIs |
| MySQL | Stores reports, snapshots, profiles, and cache |

---

## 9. Data Collection and Handling

### Data collected

| Data | Source | Purpose |
|---|---|---|
| Latitude and longitude | GPS / emulator GPS | Location-based lookup and nearby reports |
| Movement state | Accelerometer | Adds mobile context to comfort score |
| Scene | User input | Describes the context of the report |
| Feedback tags | User input | Captures subjective comfort signal |
| Optional note | User input | Adds qualitative explanation |
| Anonymous device ID | App-generated local ID | Links history to a device without account login |
| Weather and air quality snapshot | Backend APIs / fallback data | Environmental context at report time |
| Timestamp | Backend | Orders history and trends |

### Privacy approach

CampusSense uses an anonymous device ID rather than a real-name account. The project is designed for coursework demonstration and local testing. Reports are linked to the anonymous device ID so the History page can show previous reports from the same app instance.

---

## 10. Comfort Score Logic

The backend calculates a 0–100 comfort score using a weighted combination of weather, air quality, nearby user feedback, movement context, and report recency.


| Factor | Weight |
|---|---:|
| Weather score | 35% |
| Air quality score | 30% |
| User feedback signal | 20% |
| Movement score | 10% |
| Recency score | 5% |

Comfort levels

| Score | Level | Advice |
|---:|---|---|
| 80–100 | Comfortable | Good for outdoor stay |
| 60–79 | Moderate | OK for short stay | 
| 45–59 | Low | Use with caution |
| 0–44 | Uncomfortable | Choose indoor space |

---

## 11. Project Structure

Final repository layout：

```text
CampusSense/
  README.md
  submission-file.md
  submission-file.pdf
  campussense-release.apk
  demo-video.mp4

  backend/
    pom.xml
    docker-compose.yml
    src/

  mobile/
    pubspec.yaml
    lib/
    android/
    test/

  screenshots/
    01_splash.png
    02_dashboard.png
    03_report.png
    04_history.png
    05_nearby.png
    06_settings.png

  landing-page/
    index.html
    style.css
```

Actual development folders may be named differently in the submitted archive. For local reproduction, the important folders are:

```text
backend/
mobile/
```

---

## 12. How to Run Locally

### 12.1 Prerequisites

- macOS / Windows / Linux capable of running Flutter and Java.
- Flutter SDK.
- Android Studio and Android Emulator.
- Java and Maven.
- MySQL 8 or Docker-based MySQL.


The project has been locally reproduced on Android Emulator.  


---

### 12.2 Start MySQL

On local device with Homebrew

```bash
brew services start mysql
```

Check service status

```bash
brew services list
```

Log in

```bash
mysql -u root -p
```

Create database if it does not already exist

```sql
CREATE DATABASE campussense CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

Default backend database configuration

```text
Database: campussense
Host: localhost
Port: 3306
Username: root
Password: password
```

---

### 12.3 Start the backend

Open a new terminal

```bash
cd backend
mvn spring-boot:run
```

Expected successful output

```text
Tomcat started on port(s): 8080
Started CampusSenseApplication
```

The backend runs at

```text
http://localhost:8080
```

Health check

```bash
curl http://localhost:8080/api/health
```

Expected response

```json
{
  "status": "UP",
  "service": "campussense-backend",
  "version": "0.1.0"
}
```

---

### 12.4 Run the Flutter mobile app

Open a new terminal

```bash
cd mobile
flutter pub get
flutter devices
flutter run
```

If multiple devices are shown, choose the Android Emulator.

---

## 13. Testing

### 13.1 Flutter tests

Run in the mobile folder

```bash
cd mobile
flutter test
```

### 13.2 Flutter static analysis

```bash
cd mobile
flutter analyze
```

### 13.3 Backend tests

Run in the backend folder

```bash
cd backend
mvn test
```

### 13.4 Manual user testing scenario

1. Start MySQL and the backend.
2. Start Android Emulator.
3. Set backend URL to `http://10.0.2.2:8080`.
4. Perform Health check.
5. Open Dashboard and observe comfort score.
6. Submit a report from the Report page.
7. Open History and confirm the new report appears.
8. Open Nearby and confirm nearby reports are shown.
---

## 14. Demo Video and Release APK

### Demo video

Place the final demo video in the repository root or provide a link here:

```text
demo-video.mp4
```

### Release APK

Build release APK

```bash
cd mobile
flutter build apk --release
```
---

## 15. Design Process

The design started from a dashboard-first approach. The most important information, the comfort score, is placed at the top of the interface so the user can immediately understand the current space. The report flow was then added to close the feedback loop: the user does not only consume environmental information but also contributes subjective comfort data. History and Nearby pages were added to turn single reports into longitudinal and spatial insight.

### Design goals

- Make the comfort score immediately visible
- Combine objective and subjective data
- Keep reporting lightweight
- Support repeated interactions
- Show both personal history and nearby context

---

## 16. Limitations


- Android Emulator GPS is simulated and may not match the user's real physical location unless manually configured.
- AMap weather lookup may not return live weather for every overseas location, so fallback demo data may be shown.
- The current version uses anonymous device IDs rather than full user accounts.
- The nearby map is a lightweight spatial representation rather than a full interactive map SDK.
- The verified local reproduction target is Android Emulator.


---

## 17. Future Improvements


- Replace weather lookup with a global weather API for stronger overseas support.
- Improve reverse geocoding for London and campus-specific place names.
- Add a full interactive map view.
- Add optional user accounts and privacy controls.
- Add richer comfort analytics and longer-term trend summaries.
- Deploy the backend to a stable cloud environment.
- Improve iOS build support and test on physical hardware.


---

## 18. Use of Generative AI

Generative AI tools were used in an assistive role to help interpret assessment requirements, debug local environment setup, structure the README, and improve explanatory text. The project design, implementation decisions, code review, testing, and final submission remain my own responsibility.




