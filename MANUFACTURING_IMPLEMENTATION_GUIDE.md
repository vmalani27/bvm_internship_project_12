# BVM Manual Inspection Station — Smart Manufacturing Implementation Guide

> **Audience**: Quality Engineers, Process Engineers, and Manufacturing IT professionals on a smart manufacturing line.

---

## 1. System Overview

The **BVM Manual Inspection Station** is a digital, cloud-connected operator guidance and measurement capture system for manual dimensional inspection of bearing components — specifically **shafts** and **bearing housings**.

It replaces paper-based inspection sheets with a structured, video-guided digital workflow that:
- Drives the operator through each measurement step with on-screen instructional videos.
- Captures dimensional data directly from a **USB digital caliper** (zero manual keyboard entry).
- Persists every measurement to a centralised cloud database with full **operator and part traceability**.
- Allows supervisors to pull CSV exports of historical measurement data per operator.

### Component Topology

```
┌─────────────────────────────────────────────┐
│  Shop-Floor Workstation (Windows/Linux PC)   │
│  ┌──────────────────────────────────────────┐│
│  │  Flutter Web App (Chrome / Native)       ││
│  │  Served from AWS S3 Static Website       ││
│  └────────────────┬─────────────────────────┘│
│                   │  USB HID (keyboard emu.)  │
│  ┌────────────────▼────────────────────────┐ │
│  │  USB Digital Caliper (Mitutoyo / generic)│ │
│  └──────────────────────────────────────────┘ │
└─────────────────────┬───────────────────────┘
                      │ HTTPS / JSON REST API
                      ▼
        ┌─────────────────────────────┐
        │  AWS Application Load       │
        │  Balancer (internet-facing) │
        └────────────┬────────────────┘
                     │
        ┌────────────▼────────────────┐
        │  AWS ECS Fargate            │
        │  (FastAPI container, ECR)   │
        └────────────┬────────────────┘
                     │  IAM Role (S3 access)
        ┌────────────▼────────────────┐
        │  AWS S3 (two buckets)       │
        │  pcbias-videos  (private)   │
        │  pcbias-frontend (public)   │
        └─────────────────────────────┘
```

---

## 2. Part Catalogue and Measurement Parameters

### 2.1 Shaft

| Parameter | Field Name | Instrument | Method |
|---|---|---|---|
| Shaft Height | `shaft_height` | Depth bar of digital caliper | Depth bar inserted axially between shaft ends |
| Shaft Radius | `shaft_radius` | Outside jaws of digital caliper | Jaws closed around the shaft diameter, value halved internally |

### 2.2 Housing (Three Variants)

The system supports three distinct housing geometries loaded dynamically from the backend `/housing_types` endpoint:

| Housing Type | Geometry | Measured Parameters |
|---|---|---|
| **Oval** | Elliptical cross-section | Height (`housing_height`), Radius (`housing_radius`) |
| **Square** | Rectangular cross-section | Height (`housing_height`), Radius (`housing_radius`) |
| **Angular** | Angled/bracket cross-section | Height (`housing_height`), Radius (`housing_radius`) |

Each housing type has its own dedicated Blender-rendered instructional video stored in the S3 videos bucket, with filenames following the convention `{type}_housing_depth.mkv` and `{type}_housing_radius.mkv`.

---

## 3. Inspection Workflow (Process Flow)

```
Operator arrives at workstation
         │
         ▼
┌─────────────────────────────────┐
│ STEP 1 — Operator Sign-in       │
│  • Enter Roll Number + Name     │
│  • POST /user_entry             │
│  • "Welcome back" detection     │
│  • Session ID issued by backend │
└──────────────┬──────────────────┘
               │
               ▼
┌─────────────────────────────────┐
│ STEP 2 — Hardware Verification  │
│  • Plug in USB digital caliper  │
│  • App requests focus on hidden │
│    HID input field              │
│  • Operator presses DATA button │
│  • 10-second connection timeout │
│  • Float validation of received │
│    value confirms live signal   │
└──────────────┬──────────────────┘
               │
               ▼
┌─────────────────────────────────┐
│ STEP 3 — Tool Calibration       │
│  • 4-point calibration sequence │
│    at 0.00 / 10.00 / 25.00 /    │
│    50.00 mm gauge blocks        │
│  • App captures caliper reading │
│    at each point                │
│  • Computes absolute error per  │
│    step; pass threshold <0.05 mm│
│  • POST /user_entry/            │
│    complete_calibration         │
│    finalises session on backend │
└──────────────┬──────────────────┘
               │
               ▼
┌─────────────────────────────────┐
│ DASHBOARD — Task Selection      │
│  [1] Housing Measurement        │
│  [2] Shaft Measurement          │
│  [3] Past Measurements / Export │
│  [4] System Diagnostics (re-cal)│
│  Keyboard shortcuts 1–4         │
└──────────────┬──────────────────┘
               │
               ▼
┌─────────────────────────────────┐
│ PRODUCT ID ENTRY                │
│  • Operator scans / types Part# │
│  • Backend checks for duplicate │
│    (GET /product_exists)        │
│  • Duplicate → warning prompt   │
└──────────────┬──────────────────┘
               │
               ▼
┌─────────────────────────────────┐
│ MEASUREMENT STEPS (per step):   │
│  a) Instructional video plays   │
│     automatically from S3       │
│     (presigned URL, time-limited│
│      access, bucket stays priv.)│
│  b) Caliper dialog opens        │
│  c) Operator positions tool,    │
│     presses DATA button         │
│  d) HID stream captured,        │
│     debounced (100 ms), parsed  │
│  e) Measurement value displayed │
│     for operator confirmation   │
└──────────────┬──────────────────┘
               │  (repeat for each measurement parameter)
               ▼
┌─────────────────────────────────┐
│ REVIEW & SUBMIT SUMMARY         │
│  • All measurements shown       │
│  • Operator verifies values     │
│  • POST /shaft_measurement  or  │
│    POST /housing_measurement    │
│  • Submission result screen     │
│  • Returns to Dashboard         │
└─────────────────────────────────┘
```

---

## 4. Digital Caliper Integration (HID Keyboard Emulation)

### How it works

Most USB digital calipers ship with a **USB HID (Human Interface Device) interface** that emulates a keyboard. When the operator presses the **DATA / SEND** button on the caliper, the device streams the current reading as a string of numeric characters (e.g. `"25.48\n"`) directly to whatever application has keyboard focus.

The Flutter app exploits this by placing an **invisible `TextField`** widget in the widget tree. During measurement capture:

1. The app calls `FocusScope.of(context).requestFocus(_caliperFocusNode)` — routing all keyboard events to the hidden field.
2. A `TextEditingController` listener fires on every character received.
3. A **100 ms debounce timer** restarts on each character. When no new character arrives within 100 ms the transmission is considered complete.
4. The complete string is validated with `double.tryParse()`. A non-null result means a valid measurement was received; null means noise or an accidental keypress — the field is cleared and the system waits again.
5. On success the value is surfaced to the operator UI and the field is cleared for the next measurement.

```
Caliper DATA button pressed
        │
        │  USB HID stream (keyboard events)
        ▼
Hidden TextField (opacity 0, focus held)
        │
        │  TextEditingController listener
        ▼
100 ms debounce timer
        │
        ▼
double.tryParse(input)
    ├── null  → clear field, keep waiting
    └── valid → surface value to operator, clear field
```

### Connection Verification (Step 2)
A **10-second overall timeout** guards the connection check. If no valid number arrives within 10 seconds an `AlertDialog` is shown ("Caliper Not Detected — ensure it's connected, powered on, and press the data button again"). A "Retry Check" button re-initiates the same sequence.

### Calibration Sequence (Step 3)
The calibration dialog runs **four sequential gauge-block checks** at `0.00`, `10.00`, `25.00`, and `50.00 mm`. At each step:
- Operator sets the caliper jaws to a known gauge block dimension.
- Presses DATA to send the reading.
- App records actual vs. target and shows a linear progress bar.
- After all four points, **average absolute error** is computed. If `< 0.05 mm` calibration passes; otherwise the operator is prompted to retry.

---

## 5. Measurement Data Model and Traceability

Every measurement record captured by the system carries:

| Field | Description |
|---|---|
| `product_id` | Part serial number or batch ID entered by the operator |
| `roll_number` | Unique operator identifier (from sign-in) |
| `measurement_type` | `shaft` or housing variant (`oval`, `square`, `angular`) |
| `shaft_height` / `housing_height` | Axial dimension in mm |
| `shaft_radius` / `housing_radius` | Radial dimension in mm |
| `timestamp` | UTC timestamp of record creation |

These records are persisted via the backend (`/shaft_measurement` and `/housing_measurement` endpoints) and stored in the backend's data layer.

### Past Measurements & CSV Export
- Operators can view all their historical measurement records under **Past Measurements** (Dashboard → key `3`).
- Records are fetched via `GET /measured_units/{roll_number}` and rendered in a scrollable data table with column-type-aware widths.
- A **one-click CSV export** triggers `GET /export/shaft/{roll_number}` or `GET /export/housing/{roll_number}`, which causes the backend to generate an export file, upload it to the private S3 `exports/` prefix, and return a **presigned URL** for direct browser download.
- The S3 lifecycle policy automatically deletes export files after **30 days**.

---

## 6. Instructional Video System (Digital Work Instructions)

Each measurement step has a dedicated instructional video stored in the private S3 `pcbias-videos` bucket. The bucket naming convention is:

| Component | Category Folder | Filename Pattern |
|---|---|---|
| Shaft height | `shaft/` | `shaft_height.mkv` |
| Shaft radius | `shaft/` | `shaft_radius.mkv` |
| Oval housing height | `oval_housing/` | `oval_housing_depth.mkv` |
| Oval housing radius | `oval_housing/` | `oval_housing_radius.mkv` |
| Square housing height | `square_housing/` | `square_housing_depth.mkv` |
| Square housing radius | `square_housing/` | `square_housing_radius.mkv` |
| Angular housing height | `angular_housing/` | `angular_housing_depth.mkv` |
| Angular housing radius | `angular_housing/` | `angular_housing_radius.mkv` |

### Secure Delivery
The backend generates a **time-limited presigned URL** for each video via `GET /video/{category}/{filename}/play`. The Flutter app opens this URL in the **MediaKit** video player. The S3 bucket itself has all public access blocked, so videos are never directly accessible from the internet — only through the backend API.

Videos were modelled and animated in **Blender** and exported as MKV files for playback; their `.blend` source files, `.stl` solids, and `.step` CAD files are all committed under `coedmparts/` and `blender_assets/`.

---

## 7. Session Management and Data Integrity

A lightweight **session lifecycle** ensures that only complete, calibrated inspection sessions create permanent operator records:

| Session State | Meaning |
|---|---|
| `pending_calibration` | Operator signed in but has not yet completed calibration |
| `calibrated` | Calibration confirmed; session active for measurement |
| `expired` | Session exceeded 1-hour timeout; no permanent record written |

**On startup**, the app checks `SessionService.getSessionStatus()`. An incomplete session (`pending_calibration`) is flagged so the operator can resume calibration before proceeding. A completed session is cleared from local memory. This design means a power cycle or accidental browser close during sign-in does not pollute the measurement database with phantom operator entries.

Sessions are held **in-memory on the backend** (no disk persistence of partial sessions) and reference the permanent data store only upon `POST /user_entry/complete_calibration`.

---

## 8. Cloud Infrastructure (AWS)

All infrastructure is defined as code in `infrastructure_for_backend_frontend.yaml` (AWS CloudFormation).

| Resource | Service | Role |
|---|---|---|
| Frontend hosting | AWS S3 (`pcbias-frontend`) | Static website for Flutter Web build |
| Video & export storage | AWS S3 (`pcbias-videos`) | Private; lifecycle deletes exports after 30 days |
| Container registry | AWS ECR (`pcbias-inspection-api`) | Stores versioned Docker images with scan-on-push |
| Backend compute | AWS ECS Fargate | Serverless container runtime; no EC2 to manage |
| Traffic ingress | AWS ALB (internet-facing) | Health checks every 30 s; routes to ECS tasks |
| Networking | AWS VPC | `/16` CIDR; two public subnets across two AZs for HA |
| Logs | AWS CloudWatch Logs | 30-day retention for ECS container stdout |
| IAM | Task Role + Execution Role | Least-privilege S3 access for the ECS task |

### Network Security
- The ECS security group only accepts traffic **from the ALB security group** — workers are never directly reachable from the internet.
- Both S3 buckets enforce **HTTPS-only access** via bucket policies (`aws:SecureTransport: false → Deny`).
- The videos bucket has **all public access blocked** at the account level.

---

## 9. CI/CD Pipelines

### Frontend Pipeline (`.github/workflows/deploy_web.yml`)
```
git push → main
    └── GitHub Actions runner (ubuntu-latest)
         ├── Configure AWS credentials (OIDC role assumption — no static keys)
         ├── Query CloudFormation for ALB DNS name → BACKEND_URL env var
         ├── flutter pub get
         ├── flutter build web --release --dart-define=BACKEND_URL=<alb-url>
         │     (injects backend URL at compile time, zero runtime config needed)
         └── aws s3 sync frontend/build/web s3://<frontend-bucket> --delete
```

### Backend Pipeline
```
git push → main
    └── GitHub Actions runner
         ├── docker build -t inspection-api .
         ├── docker tag + push → ECR
         └── aws ecs update-service --force-new-deployment
               (ECS pulls new image, performs rolling replacement of tasks)
```

Authentication uses **OIDC federation** (`id-token: write` permission + `role-to-assume` secret) — no long-lived AWS credentials are stored in GitHub.

---

## 10. Development and Local Run

### Backend
```bash
pip install fastapi uvicorn pandas boto3
uvicorn app.main:app --reload   # hot-reload on save
```

### Frontend
```bash
cd frontend
flutter pub get
flutter run -d chrome --dart-define=BACKEND_URL=http://localhost:8000
```

To point the frontend at the deployed backend during local development:
```bash
# start_backend_flutter_dev.py / .bat handles this automatically
python start_backend_flutter_dev.py
```

---

## 11. Keyboard Shortcut Reference (Operator UI)

| Key | Action |
|---|---|
| `1` | Navigate to Housing Measurement |
| `2` | Navigate to Shaft Measurement |
| `3` | Open Past Measurements |
| `4` | Open System Diagnostics (re-calibrate) |
| `F11` | Toggle full-screen mode |
| `Esc` | Exit full-screen |

---

## 12. Future Roadmap (Industry 4.0 Improvements)

| Item | Description |
|---|---|
| Amazon CloudFront | CDN layer in front of S3 for lower-latency global access |
| Amazon RDS / DynamoDB | Replace flat-file data storage with a managed relational or document database |
| Statistical Process Control (SPC) | Real-time control charts (Xbar-R, Cpk) visualised in the Past Measurements view |
| Bluetooth caliper support | Replace USB HID with BLE GATT profile for wireless measurement |
| OPC-UA / MQTT integration | Publish measurement data to plant-level MES / SCADA in real time |
| AWS Cognito | Proper authentication with per-operator role assignment |
| Amazon Rekognition | Computer-vision cross-check: verify correct part orientation before measurement |
| AWS IoT Greengrass | Edge computing for offline-capable inspection at sites with poor connectivity |
