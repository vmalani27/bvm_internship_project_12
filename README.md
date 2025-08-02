# BVM Manual Inspection Station

A modern, cross-platform application for manual inspection workflows with video-guided measurement instructions.

## Project Structure

```
bvm_internship_project_12/
├── backend/           # Python FastAPI server
├── frontend/          # Flutter application
└── README.md         # This file
```

## Backend (Python FastAPI)

### Features
- ✅ FastAPI server setup with CORS enabled
- ✅ CSV-based data storage for user entries and measurements
- ✅ User entry endpoints with duplicate roll number handling
- ✅ "Welcome back" logic with last_login tracking
- ✅ Should calibrate endpoint for returning users
- ✅ Shaft and housing measurement endpoints (CRUD operations)
- ✅ Get measured units by roll number endpoint
- ✅ Video streaming endpoints for instructional videos
- ✅ Error handling for missing fields, duplicates, and file issues

### Setup & Installation

1. Navigate to the backend directory:
```bash
cd backend
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Run the server:
```bash
python main.py
```

The server will start on `http://127.0.0.1:8000`

### API Endpoints

#### User Entry
- `POST /user_entry` - Add user entry
- `GET /user_entry` - Get all user entries
- `PUT /user_entry` - Update user entry
- `DELETE /user_entry` - Delete all user entries
- `GET /user_entry/should_calibrate` - Check if user should calibrate

#### Measurements
- `POST /shaft_measurement` - Add shaft measurement
- `GET /shaft_measurement` - Get all shaft measurements
- `PUT /shaft_measurement` - Update shaft measurement
- `DELETE /shaft_measurement` - Delete all shaft measurements

- `POST /housing_measurement` - Add housing measurement
- `GET /housing_measurement` - Get all housing measurements
- `PUT /housing_measurement` - Update housing measurement
- `DELETE /housing_measurement` - Delete all housing measurements

- `GET /measured_units/{roll_number}` - Get measured units by roll number

#### Video Streaming
- `GET /video/list/{category}` - Get video list for category
- `GET /video/{category}/{filename}` - Stream video with range support

### Data Storage
CSV files are stored in `backend/logs/`:
- `user_entry.csv` - User registration data
- `measured_shafts.csv` - Shaft measurement data
- `measured_housings.csv` - Housing measurement data

## Frontend (Flutter)

### Features
- ✅ Global Material 3 theme with modern color scheme
- ✅ Complete onboarding workflow with step progress indicator
- ✅ User entry form with validation and "welcome back" toast
- ✅ Device connection and calibration steps
- ✅ Step-by-step measurement workflow with video instructions
- ✅ Category selection (shaft/housing)
- ✅ Product ID entry and review summary
- ✅ Past measurements viewing page
- ✅ Cross-platform support (Windows, Android, iOS, Web)

### Setup & Installation

1. Navigate to the frontend directory:
```bash
cd frontend
```

2. Get Flutter dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run
```

### Key Dependencies
- `flutter` - UI framework
- `http` - HTTP client for API communication
- `media_kit` - Video player for instructional content
- `google_fonts` - Typography
- `shared_preferences` - Local data storage

### Application Flow

1. **Onboarding**
   - User entry form with roll number and name
   - Device connection verification
   - Optional calibration step

2. **Measurement Workflow**
   - Category selection (shaft or housing)
   - Product ID entry
   - Step-by-step measurements with video guidance
   - Review and submit summary

3. **Additional Features**
   - Past measurements viewing
   - User session management
   - Modern, accessible UI design

## Getting Started

1. **Start the Backend:**
```bash
cd backend
pip install -r requirements.txt
python main.py
```

2. **Start the Frontend:**
```bash
cd frontend
flutter pub get
flutter run
```

3. **Access the Application:**
   - Backend API: `http://127.0.0.1:8000`
   - Frontend: Available on your selected device/platform

## Project Status

✅ **PRODUCTION READY** - The BVM Manual Inspection Station is fully functional with complete backend API, full frontend application, video instruction system, user management, and modern UI design.

## Technology Stack

- **Backend:** Python, FastAPI, Pandas, Uvicorn
- **Frontend:** Flutter, Dart
- **Data Storage:** CSV files
- **Video Streaming:** Custom FastAPI endpoints
- **UI Framework:** Material 3 Design
