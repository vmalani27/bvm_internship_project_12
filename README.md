# BVM Manual Inspection Station

The BVM Manual Inspection Station is an industrial application designed to guide operators through manual measurement tasks using real-time video instructions and automated data capture.

## System Architecture

The application is built on a split-architecture:

1. **Frontend**: A Flutter-based application that provides the user interface for Windows, Android, and Web platforms.
2. **Backend**: A FastAPI server that handles data persistence in CSV format, manages instructional video distribution, and provides API endpoints for measurement submission.

## Workflow

The application follows a linear industrial workflow to ensure data integrity:

1. **Operator Sign-in**: Users enter their name and roll number to initialize a session.
2. **Setup and Hardware Check**: The system verifies connectivity with measurement devices (e.g., digital calipers) and performs calibration if required.
3. **Category Selection**: Operators choose between measurement categories such as Housing or Shaft.
4. **Inspections**: 
   - Enter the unique Product ID for the part.
   - Follow step-by-step video instructions for each measurement point.
   - Captured values are entered into the system.
5. **Data Submission**: Completed measurement sets are reviewed and submitted to the backend.
6. **Data History**: Operators can access, view, and export historical measurement data from the database.

## Static Web Hosting

The Flutter frontend is optimized for deployment as a static web application.

### Build Process

To generate the distribution files for web hosting:
1. Navigate to the `frontend/` directory.
2. Run the build command:
   ```bash
   flutter build web --release
   ```
3. The build artifacts will be generated in `frontend/build/web/`.

### Deployment

The contents of `frontend/build/web/` can be served from any static hosting environment, including Amazon S3, GitHub Pages, or dedicated web servers like Nginx.

### Configuration

- **Backend Connection**: The application connects to the backend via the URL defined in `lib/config/app_config.dart`. 
- **CORS**: The FastAPI backend must have CORS (Cross-Origin Resource Sharing) headers enabled to allow requests from the hosting domain.
- **Fallback Routing**: Configure your static host to serve `index.html` for all 404 responses to support client-side routing.

## Development Setup

### Backend

1. Install dependencies:
   ```bash
   pip install fastapi uvicorn pandas
   ```
2. Start the server:
   ```bash
   python main.py
   ```

### Frontend

1. Install dependencies:
   ```bash
   flutter pub get
   ```
2. Start the application:
   ```bash
   flutter run -d chrome
   ```
