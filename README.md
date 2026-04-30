# CampusSense

>  CampusSense is a Flutter mobile application for sensing, reporting, and reviewing campus micro-environment comfort. It combines mobile GPS, accelerometer-based movement context, weather data, air quality data, and anonymous user feedback to calculate a location-based comfort score.

---

## Table of Contents｜目录

- [1. Project Overview｜项目概述](#1-project-overview项目概述)
- [2. Problem Statement｜问题陈述](#2-problem-statement问题陈述)
- [3. Target Users and Persona｜目标用户与用户画像](#3-target-users-and-persona目标用户与用户画像)
- [4. User Journey and Storyboard｜用户旅程与故事板](#4-user-journey-and-storyboard用户旅程与故事板)
- [5. Key Features｜主要功能](#5-key-features主要功能)
- [6. Screens and Interaction Design｜页面与交互设计](#6-screens-and-interaction-design页面与交互设计)
- [7. System Architecture｜系统架构](#7-system-architecture系统架构)
- [8. Sensors, APIs and Services｜传感器、API 与服务](#8-sensors-apis-and-services传感器api-与服务)
- [9. Data Collection and Handling｜数据收集与处理](#9-data-collection-and-handling数据收集与处理)
- [10. Comfort Score Logic｜舒适度评分逻辑](#10-comfort-score-logic舒适度评分逻辑)
- [11. Project Structure｜项目结构](#11-project-structure项目结构)
- [12. How to Run Locally｜本地运行方法](#12-how-to-run-locally本地运行方法)
- [13. Android Emulator Notes｜Android 模拟器说明](#13-android-emulator-notesandroid-模拟器说明)
- [14. Testing｜测试](#14-testing测试)
- [15. Demo Video and Release APK｜演示视频与 Release APK](#15-demo-video-and-release-apk演示视频与-release-apk)
- [16. Design Process｜设计过程](#16-design-process设计过程)
- [17. Limitations｜当前限制](#17-limitations当前限制)
- [18. Future Improvements｜未来改进方向](#18-future-improvements未来改进方向)
- [19. Use of Generative AI｜生成式 AI 使用说明](#19-use-of-generative-ai生成式-ai-使用说明)
- [20. Credits｜致谢](#20-credits致谢)

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

## 11. Project Structure｜项目结构

Recommended final repository layout｜建议最终 GitHub 仓库结构：

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

中文说明：实际压缩包中的目录名称可能略有不同，但本地复现时最重要的是根目录下的 `backend/` 和 `mobile/` 两个文件夹。

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

## 14. Demo Video and Release APK｜演示视频与 Release APK

### Demo video｜演示视频

Please place the final demo video in the repository root or provide a link here:

```text
demo-video.mp4
```

中文说明：请将最终演示视频放在仓库根目录，或在此处提供链接：

```text
demo-video.mp4
```

Suggested demo flow｜建议视频流程：

1. Show backend running.
2. Show `/api/health` returning `UP`.
3. Open CampusSense in Android Emulator.
4. Show Settings and backend URL.
5. Show Dashboard comfort score.
6. Submit a report.
7. Show History.
8. Show Nearby reports.

### Release APK｜Release 安装包

Build release APK｜构建 release APK：

```bash
cd mobile
flutter build apk --release
```

Generated file｜生成文件位置：

```text
mobile/build/app/outputs/flutter-apk/app-release.apk
```

Recommended final name｜建议最终命名：

```text
campussense-release.apk
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




