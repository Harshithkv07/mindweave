# MindWeave — SIH 2026 Starter

Offline-first cognitive companion prototype for elderly users, with a caregiver dashboard, FastAPI backend, adaptive difficulty, reminders, and sync.

## Stack

- Patient app: Flutter + Dart
- Backend: FastAPI + SQLite for zero-config local development
- Caregiver dashboard: React + TypeScript + Vite
- Optional production DB: PostgreSQL can replace SQLite later
- AI: transparent rule-based personalization starter

## Quick start

### 1. Backend

```bash
cd backend
python -m venv .venv
# Windows: .venv\Scripts\activate
# macOS/Linux: source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

API: http://127.0.0.1:8000
Docs: http://127.0.0.1:8000/docs

Demo credentials:
- patient@example.com / password123
- caregiver@example.com / password123

### 2. Caregiver dashboard

```bash
cd caregiver_dashboard
npm install
npm run dev
```

Open the Vite URL shown in the terminal.

### 3. Patient app

Install Flutter, then:

```bash
cd patient_app
flutter pub get
flutter run
```

The app defaults to the local backend. On Android emulator, `10.0.2.2` points to your host machine. For a physical phone, change `baseUrl` in `lib/core/config.dart` to your computer's LAN IP.

## Demo flow

1. Login as the demo patient.
2. Start Memory Match.
3. Complete a session.
4. Results are saved locally first and queued for sync.
5. Sync when the API is reachable.
6. Open the caregiver dashboard and inspect sessions, trends, and insights.

## Important prototype boundary

This project is a wellness/support prototype. Scores and alerts are NOT medical diagnoses. Do not market them as diagnosing dementia or predicting disease.

## Six-member split

- IT1: patient_app UI/games
- IT2: backend/database/sync
- IT3: caregiver_dashboard
- AI1: analytics/profile/baseline
- AI2: adaptive/recommendation engine
- AI3: voice/language/NER content
