# BVM Manual Inspection Station

A comprehensive, cross-platform manual inspection application featuring video-guided measurement workflows, dynamic housing type support, and modern Material 3 UI design. Built with Flutter frontend and FastAPI backend for robust industrial measurement processes.

![Project Status](https://img.shields.io/badge/Status-Production%20Ready-brightgreen)
![Flutter](https://img.shields.io/badge/Flutter-Cross%20Platform-blue)
![FastAPI](https://img.shields.io/badge/FastAPI-Backend-green)
![Material 3](https://img.shields.io/badge/Material%203-UI%20Design-purple)

## 🚀 Features Overview

### ✨ Core Functionality
- **Multi-Platform Support**: Windows, Android, iOS, and Web
- **Video-Guided Workflows**: Step-by-step measurement instructions with integrated video player
- **Dynamic Housing Types**: Support for multiple housing configurations (standard, oval, square, angular)
- **Real-time Device Integration**: Digital caliper connectivity with automatic data capture
- **Comprehensive Data Management**: CSV-based storage with full CRUD operations
- **Modern UI/UX**: Material 3 design with dark theme and glassmorphism effects

### 🔧 Technical Features
- **RESTful API**: Complete backend API with video streaming capabilities
- **Cross-platform Video Playback**: Advanced media kit integration
- **Responsive Design**: Adaptive layouts for all screen sizes
- **Data Validation**: Comprehensive input validation and error handling
- **Session Management**: User state persistence and "welcome back" functionality
- **Advanced Navigation**: Step-by-step workflow with progress tracking

## 📁 Project Architecture

```
bvm_internship_project_12/
├── 📱 frontend/              # Flutter Application
│   ├── lib/
│   │   ├── 🎨 config/        # App configuration & theming
│   │   ├── 📄 pages/         # Main application screens
│   │   ├── 🧩 elements/      # Reusable UI components
│   │   ├── 📊 models/        # Data models & controllers
│   │   └── 🔧 utils/         # Utility functions
│   ├── assets/               # Frontend assets & fonts
│   └── pubspec.yaml         # Flutter dependencies
│
├── 🖥️ backend/               # Python FastAPI Server
│   ├── main.py              # FastAPI application entry point
│   ├── csv_helper.py        # CSV data management utilities
│   ├── 📊 logs/             # Data storage (CSV files)
│   ├── 🎥 assets/           # Video instruction files
│   │   ├── housing/         # Standard housing videos
│   │   ├── shaft/           # Shaft measurement videos
│   │   ├── oval_housing/    # Oval housing type videos
│   │   ├── sqaure_housing/  # Square housing type videos
│   │   └── angular_housing/ # Angular housing type videos
│   └── requirements.txt     # Python dependencies
│
├── 🏗️ coedmparts/           # CAD files & design assets
├── 🌐 html+css try/         # Web interface prototypes
└── 📚 starter script/       # Setup & utility scripts
```

## 🛠️ Backend (FastAPI Server)

## 🖥️ Software Requirements

### 1. Supported Operating Systems
- Development: Windows 10/11 (x64), macOS 13+, Ubuntu 22.04+ (or equivalent modern Linux)
- Backend Executable (PyInstaller build): Windows 10/11 (x64)
- Frontend Runtime: Windows 10/11 desktop, Android 8.0+, iOS 14+, modern Chromium-based browsers (Chrome/Edge), macOS (if built), Linux (if built)

### 2. Hardware (Minimum / Recommended)
- CPU: Dual‑core 2.0 GHz / Quad‑core 3.0+ GHz
- RAM: 4 GB / 8+ GB (≥8 GB strongly recommended for concurrent Flutter & PyInstaller builds)
- Storage: ~1 GB for source + size of video assets (place in `backend/assets/`)
- GPU: Basic H.264 decoding capability for smooth video playback

### 3. Backend (Source Execution)
- Python: 3.12.x
- Pip packages (from `backend/requirements.txt`): `fastapi`, `uvicorn`, `pandas`, `matplotlib`, `stl`, `streamlit`
- Recommended additional package (if using `.env`): `python-dotenv`
- Build Tool (for .exe): `pyinstaller >= 6.0`

### 4. Backend (Packaged Executable Runtime)
- No system Python required (embedded by PyInstaller)
- Must distribute alongside folders:
  - `assets/` (all video/media content)
  - `logs/` (CSV storage; create empty if shipping fresh)
- Windows VC++ runtime: Usually bundled automatically
- Ensure firewall allows chosen port (default 8000)

### 5. Frontend (Development Environment)
- Flutter SDK: 3.7.x (as constrained in `pubspec.yaml`)
- Windows Desktop: Visual Studio 2022 with “Desktop development with C++” workload
- Android: Android Studio latest + SDK Platform 34+
- iOS (macOS only): Xcode 15+, CocoaPods
- Web: Latest Chrome/Edge for testing

### 6. Frontend Runtime Dependencies
- All Dart & native dependencies bundled at build time
- Video codecs: Use MP4 (H.264 + AAC) for broad compatibility

### 7. Networking & Ports
- Default backend: `http://127.0.0.1:8000`
- Configurable via environment variables (`HOST`, `PORT`)
- If exposing beyond localhost, configure CORS (`ALLOWED_ORIGINS`) and firewall rules

### 8. Environment Variables (Optional `.env`)
```
HOST=127.0.0.1
PORT=8000
DEBUG=True
CSV_BASE_PATH=./logs
VIDEO_BASE_PATH=./assets
ALLOWED_ORIGINS=*
```

### 9. File & Directory Requirements
- Writable `backend/logs/` directory (CSV: `user_entry.csv`, `measured_shafts.csv`, `measured_housings.csv`)
- Structured video folders under `backend/assets/`
- Packaging command (preserves relative paths):
```
pyinstaller --onefile --add-data "assets;assets" --add-data "logs;logs" main.py
```

### 10. Security & Permissions
- Run with filesystem write permissions for logging
- Restrict bind address (`HOST`) for local-only usage or harden perimeter when exposed

### 11. Optional / Future Integrations
- Digital caliper / measurement device drivers (USB/Serial) – document vendor & driver version when integrated
- Compression middleware or caching layer if API scaling demands it

### 12. Production Version Pinning (Example)
```
fastapi==0.111.0
uvicorn[standard]==0.30.0
pandas==2.2.2
matplotlib==3.9.0
numpy==1.26.4
stl==0.0.3
streamlit==1.36.0
pyinstaller==6.6.0
```
(Adjust to the exact versions validated in staging.)

### 13. Diagnostics & Health Checks
- API Docs: `/docs`
- Video access test: `/video/{category}/{filename}` with `Range` header
- Logs: Inspect CSV entries in `backend/logs/`

### 14. Deployment Footprint (Approx.)
- Backend executable: 10–60 MB (excluding assets)
- Video assets: Depends on number & bitrate
- Flutter Windows release: 100–200 MB typical

### 15. Distribution Checklist (Backend EXE)
1. `main.exe` (PyInstaller output)
2. `assets/` (video subfolders intact)
3. `logs/` (existing CSVs or empty folder)
4. Quick start instructions
5. License / internal notice

---
Keep this section updated when adding new external services, device drivers, or environment variables.

### Core Features
- **High-Performance API**: FastAPI with automatic OpenAPI documentation
- **Video Streaming**: Range-request support for efficient video delivery
- **Dynamic Housing Types**: Configurable measurement workflows
- **Data Persistence**: CSV-based storage with atomic operations
- **CORS Support**: Cross-origin resource sharing for web deployment
- **Comprehensive Logging**: Detailed operation logging for debugging

### 🚀 Quick Start

1. **Navigate to backend directory:**
```bash
cd backend
```

2. **Install Python dependencies:**
```bash
pip install -r requirements.txt
```

3. **Start the server:**
```bash
python main.py
```

The server starts on `http://127.0.0.1:8000` with automatic API documentation at `/docs`

### 📡 API Reference

#### 👤 User Management
| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/user_entry` | Retrieve all user entries |
| `POST` | `/user_entry` | Create new user entry |
| `PUT` | `/user_entry` | Update existing user |
| `DELETE` | `/user_entry` | Clear all user data |
| `GET` | `/user_entry/should_calibrate` | Check calibration requirement |

#### 📏 Measurements - Shaft
| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/shaft_measurement` | Record shaft measurement |
| `GET` | `/shaft_measurement` | Get all shaft measurements |
| `PUT` | `/shaft_measurement` | Update shaft measurement |
| `DELETE` | `/shaft_measurement` | Clear shaft measurements |

#### 🏠 Measurements - Housing
| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/housing_measurement` | Record housing measurement |
| `GET` | `/housing_measurement` | Get all housing measurements |
| `PUT` | `/housing_measurement` | Update housing measurement |
| `DELETE` | `/housing_measurement` | Clear housing measurements |

#### 🎥 Video & Media
| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/video/list/{category}` | List videos for category |
| `GET` | `/video/{category}/{filename}` | Stream video with range support |
| `GET` | `/housing_types` | Get available housing types |
| `GET` | `/video/housing_types/{housing_type}` | Get videos for housing type |

#### 📊 Data Analytics
| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/measured_units/{roll_number}` | Get user's measurement history |
| `GET` | `/debug/paths` | System path debugging |

### 💾 Data Storage Structure

**CSV Files Location:** `backend/logs/`

**user_entry.csv**
```csv
roll_number,name,date,time,last_login
12345,John Doe,2024-01-15,14:30:25,2024-01-15 14:30:25
```

**measured_shafts.csv**
```csv
roll_number,product_id,measurement_type,value,step_label,date,time
12345,SHAFT001,diameter,25.4,Shaft Diameter,2024-01-15,14:35:10
```

**measured_housings.csv**
```csv
roll_number,product_id,measurement_type,value,step_label,housing_type,date,time
12345,HSG001,inner_diameter,30.2,Inner Diameter,standard,2024-01-15,14:40:15
```

## 📱 Frontend (Flutter Application)

### Modern Features
- **Material 3 Design**: Latest Google design language implementation
- **Dark Theme**: Eye-friendly color scheme with glassmorphism effects
- **Responsive Layout**: Adaptive design for all screen sizes
- **Advanced Video Player**: Media kit integration with playback controls
- **Form Validation**: Real-time input validation with helpful feedback
- **State Management**: Efficient state handling with ChangeNotifier pattern
- **Navigation Flow**: Intuitive step-by-step measurement workflow

### 🚀 Quick Start

1. **Navigate to frontend directory:**
```bash
cd frontend
```

2. **Install Flutter dependencies:**
```bash
flutter pub get
```

3. **Run the application:**
```bash
# For Windows desktop
flutter run -d windows

# For Android device/emulator
flutter run -d android

# For web browser
flutter run -d chrome

# For iOS (macOS only)
flutter run -d ios
```

### 📦 Key Dependencies

```yaml
# Core Framework
flutter: SDK

# UI & Theming
google_fonts: ^6.2.1           # Typography
cupertino_icons: ^1.0.8        # iOS-style icons

# Media & Video
media_kit: ^1.2.0              # Cross-platform video player
media_kit_video: ^1.3.0        # Video player UI components
video_player: ^2.7.0           # Alternative video player
chewie: ^1.7.0                 # Video player wrapper

# Network & Data
http: ^1.4.0                   # HTTP client for API calls
csv: ^5.0.2                    # CSV file handling
shared_preferences: ^2.2.2     # Local data persistence

# UI Enhancements
another_flushbar:              # Toast notifications
webview_flutter: ^4.7.0       # Web view integration
model_viewer_plus: ^1.9.3     # 3D model viewing

# Development
dotenv: ^4.2.0                 # Environment configuration
```

### 🎨 Application Flow

#### 1. **Onboarding Process**
```
User Entry → Device Check → Calibration (Optional) → Main Menu
```

#### 2. **Measurement Workflow**
```
Category Selection → Housing Type (if applicable) → Product ID → 
Step-by-Step Measurements → Review Summary → Submission
```

#### 3. **Navigation Structure**
- **Welcome Page**: Initial user greeting and navigation
- **User Entry**: Registration/login with duplicate handling
- **Device Connection**: Digital caliper connectivity verification
- **Calibration**: Optional precision calibration step
- **Category Selection**: Shaft vs Housing measurement types
- **Housing Types**: Dynamic selection for housing measurements
- **Measurement Steps**: Video-guided measurement process
- **Summary Review**: Measurement verification before submission
- **Past Measurements**: Historical data viewing with DataTable
- **Results**: Submission confirmation and next actions

### 🎯 UI/UX Features

#### **Design System**
- **Color Scheme**: Sophisticated dark theme with accent colors
- **Typography**: Google Fonts integration for readability
- **Spacing**: Consistent 8px grid system
- **Components**: Reusable widgets with consistent styling

#### **Interactive Elements**
- **Morphing Buttons**: Animated state transitions
- **Glassmorphism Cards**: Translucent design elements
- **Progress Indicators**: Visual workflow guidance
- **Video Integration**: Seamless instruction playback
- **Form Validation**: Real-time feedback and error states

#### **Responsive Design**
- **Breakpoints**: Mobile, tablet, and desktop layouts
- **Adaptive Navigation**: Context-aware menu systems
- **Flexible Grids**: Dynamic content arrangement
- **Accessible UI**: Screen reader and keyboard navigation support

## 🔧 Advanced Configuration

### Backend Configuration

**Environment Variables** (optional `.env` file):
```env
# Server Configuration
HOST=127.0.0.1
PORT=8000
DEBUG=True

# Data Storage
CSV_BASE_PATH=./logs
VIDEO_BASE_PATH=./assets

# CORS Settings
ALLOWED_ORIGINS=*
```

**Video Asset Organization:**
```
backend/assets/
├── housing/
│   ├── step1_outer_diameter.mp4
│   ├── step2_inner_diameter.mp4
│   └── step3_depth.mp4
├── shaft/
│   ├── step1_diameter.mp4
│   └── step2_height.mp4
├── oval_housing/
│   ├── step1_major_axis.mp4
│   └── step2_minor_axis.mp4
├── sqaure_housing/
│   └── step1_side_length.mp4
└── angular_housing/
    └── step1_angle_measurement.mp4
```

### Frontend Configuration

**App Theme Customization** (`lib/config/app_theme.dart`):
```dart
class AppTheme {
  // Primary colors
  static const Color primary = Color(0xFF6366F1);
  static const Color secondary = Color(0xFF8B5CF6);
  
  // Background colors
  static const Color bgColor = Color(0xFF0F1419);
  static const Color cardBg = Color(0xFF1F2937);
  
  // Text colors
  static const Color textDark = Color(0xFFF9FAFB);
  static const Color textMuted = Color(0xFF9CA3AF);
}
```

**API Configuration** (`lib/utils/api_config.dart`):
```dart
class ApiConfig {
  static const String baseUrl = 'http://127.0.0.1:8000';
  static const Duration timeout = Duration(seconds: 30);
}
```

## 🚀 Deployment Guide

### Development Deployment

1. **Start Backend Server:**
```bash
cd backend
python main.py
```

2. **Launch Frontend:**
```bash
cd frontend
flutter run -d windows  # or your target platform
```

### Production Deployment

#### **Backend (FastAPI)**
```bash
# Using Uvicorn with production settings
uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4

# Using Docker (optional)
docker build -t bvm-backend .
docker run -p 8000:8000 bvm-backend
```

#### **Frontend (Flutter)**
```bash
# Windows Desktop
flutter build windows --release

# Android APK
flutter build apk --release

# Web Application
flutter build web --release

# iOS (macOS only)
flutter build ios --release
```

### **Executable Generation**

**Backend Executable:**
```bash
cd backend
pyinstaller --onefile --add-data "assets;assets" --add-data "logs;logs" main.py
```

**Frontend Desktop App:**
- Windows: Built-in with `flutter build windows`
- macOS: Built-in with `flutter build macos`
- Linux: Built-in with `flutter build linux`

## 🧪 Testing & Quality Assurance

### **API Testing**
```bash
# Interactive API documentation
http://127.0.0.1:8000/docs

# Health check endpoint
curl http://127.0.0.1:8000/

# Test video streaming
curl -I http://127.0.0.1:8000/video/housing/step1_outer_diameter.mp4
```

### **Frontend Testing**
```bash
# Run unit tests
flutter test

# Integration tests
flutter test integration_test/

# Performance profiling
flutter run --profile
```

## 🔍 Troubleshooting

### Common Issues

**Backend Issues:**
- **Port already in use**: Change port in `main.py` or kill existing process
- **Video files not found**: Check asset directory structure and file permissions
- **CSV write errors**: Ensure `logs/` directory exists and has write permissions

**Frontend Issues:**
- **Video playback issues**: Verify media kit platform-specific dependencies
- **API connection fails**: Check backend server status and CORS configuration
- **Build failures**: Run `flutter clean && flutter pub get`

**Integration Issues:**
- **Cross-platform compatibility**: Test on target platforms early
- **Video codec support**: Ensure video files use supported formats (MP4/H.264)
- **Performance on lower-end devices**: Consider video quality optimization

### **Debug Commands**
```bash
# Backend logging
python main.py --log-level debug

# Frontend verbose logging
flutter run --verbose

# Network debugging
flutter run --enable-network-logging
```

## 📈 Performance Optimization

### **Backend Optimizations**
- **Video Streaming**: Range request support for efficient bandwidth usage
- **CSV Caching**: In-memory caching for frequently accessed data
- **Async Operations**: Non-blocking I/O for concurrent requests
- **File Compression**: Gzip compression for API responses

### **Frontend Optimizations**
- **Lazy Loading**: On-demand page and asset loading
- **Video Caching**: Local caching of frequently accessed videos
- **State Management**: Efficient rebuild optimization
- **Bundle Size**: Tree shaking and code splitting

## 🤝 Contributing

### **Development Workflow**
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### **Code Standards**
- **Dart**: Follow Dart style guide and use `dart format`
- **Python**: Follow PEP 8 and use `black` formatter
- **Documentation**: Update README for new features
- **Testing**: Add tests for new functionality

## 📄 License & Legal

This project is developed for educational and internal use at BVM. Please respect intellectual property rights and follow your organization's guidelines for code usage and distribution.

## 🆘 Support & Documentation

- **API Documentation**: http://127.0.0.1:8000/docs (when backend is running)
- **Flutter Documentation**: https://docs.flutter.dev
- **FastAPI Documentation**: https://fastapi.tiangolo.com
- **Issue Reporting**: Create GitHub issues for bugs and feature requests

---

## 🏆 Project Status: Production Ready

**Version**: 1.0.0  
**Status**: ✅ **PRODUCTION READY**  
**Last Updated**: August 2025

The BVM Manual Inspection Station is a fully functional, production-ready application with:
- ✅ Complete backend API with video streaming
- ✅ Full-featured Flutter frontend application  
- ✅ Dynamic housing type support
- ✅ Video instruction integration
- ✅ Modern Material 3 UI design
- ✅ Cross-platform compatibility
- ✅ Comprehensive user workflow
- ✅ Data persistence and management
- ✅ Real-time device integration capabilities

**Technology Stack**: Flutter • FastAPI • Material 3 • Media Kit • Python • Dart

## 🆕 Recent Frontend Updates (2025)

### Session Management & Logout
- Added robust session management: user session state is now tracked and cleared on logout.
- Logout button added to the top app bar for all main screens.
- On logout, user session is cleared and navigation returns to the main app widget.
- Session data is not persisted after logout, ensuring privacy and security.

### DataTable & UI Improvements
- Table columns now fit strictly equally within the container for improved readability.
- Reduced space between DataTable columns for a more compact view.
- Timestamp column width capped and uses ellipsis for overflow.
- Option to hide the record count display at the top right of the history table.

### Other UI Tweaks
- Morphing device connection button replaces legacy ADB button.
- Improved navigation and workflow for measurement steps.
- Minor bug fixes and code clean-up for unused variables and imports.
