# Trackly

**Trackly** is a city bus tracking system designed for real-time bus visibility and location-based “nearest bus” discovery for a mobile app, plus a manager web dashboard to maintain routes, buses, and view logs.

The repository is organized as a simple two-part project:
- **trackly_backend** — Node.js + Express backend (MongoDB, dashboard UI, hardware ingestion endpoints, public APIs)
- **trackly_mobile** — Flutter mobile application

---

## Features

### Mobile (Flutter)
- View available routes and active buses
- Get the **nearest active bus** to a given latitude/longitude
- Consume backend public APIs

### Backend (Node/Express)
- Session-based web dashboard (EJS)
- MongoDB models for companies, routes, buses, and location logs
- Hardware ingestion endpoint for receiving live bus location updates
- Optional Telegram messaging test endpoint
- Public read-only API endpoints for the mobile app

---

## Repository Layout

- `trackly_backend/`
  - Express app, routes, controllers, services, and EJS views
- `trackly_mobile/`
  - Flutter app source code and assets
- `README.md` (this file)
- `.gitignore` (root)

---

## Requirements

### Backend
- Node.js (LTS recommended)
- MongoDB (local or remote)
- Environment variables (see `trackly_backend/.env.example`)
- (Optional) Telegram bot token if you use the Telegram test endpoint

### Mobile
- Flutter SDK (recommended)
- Android Studio / Xcode depending on your target platform

---

## Setup & Run

> Run each part separately.

### 1) Backend Setup

```bat
cd "c:/Users/Admin/Desktop/MY GRADUATION/Software/Trackly/trackly_backend"
npm install
```

Create a `.env` file based on `trackly_backend/.env.example`:

```bat
copy .env.example .env
```

Then start the server:

```bat
npm run dev
```

The backend will run on:
- `http://localhost:${PORT}` (where `PORT` is read from `.env`)

### 2) Mobile Setup (Flutter)

```bat
cd "c:/Users/Admin/Desktop/MY GRADUATION/Software/Trackly/trackly_mobile"
flutter pub get
flutter run
```

> Ensure the mobile app is configured to call the correct backend base URL.

---

## Backend Usage (High Level)

1. Open the manager dashboard pages (EJS) to create/manage routes and view bus logs.
2. Register a company manager and obtain the **apiSecret** used by hardware requests.
3. Send location updates using the provided REST file:
   - `trackly_backend/api-testing.rest`

Common endpoints include:
- `POST /api/hardware/location` (hardware ingestion)
- `POST /api/test/telegram` (optional Telegram test)
- Public read APIs under `GET /api/public/...` for the mobile app

---

## Models (Data Layer)

The backend uses Mongoose models. The main collections include:
- `User`
- `Company`
- `Route`
- `Bus`
- `LocationLog`

---

## Development Notes

This repo includes `.rest` examples for testing and uses a layered structure in the backend:
- controllers → services → models

---

## License

Add a license file (MIT/Apache/etc.) when you prepare the project for public release.

