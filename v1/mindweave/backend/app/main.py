from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session as DBSession
from sqlalchemy import desc
from .database import Base, engine, get_db
from .models import User, Session, Reminder, Alert
from .schemas import *
from .security import hash_password, verify_password, create_access_token, decode_token
from .ai import build_profile, next_difficulty, insight, domain_for_game

app = FastAPI(title="MindWeave API", version="0.1.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
Base.metadata.create_all(bind=engine)
bearer = HTTPBearer(auto_error=False)

def current_user(
    credentials: HTTPAuthorizationCredentials = Depends(bearer),
    db: DBSession = Depends(get_db),
):
    if not credentials:
        raise HTTPException(401, "Authentication required")
    try:
        payload = decode_token(credentials.credentials)
        user = db.get(User, int(payload["sub"]))
    except Exception:
        raise HTTPException(401, "Invalid or expired token")
    if not user:
        raise HTTPException(401, "User not found")
    return user

def seed(db: DBSession):
    if db.query(User).count():
        return
    patient = User(
        email="patient@example.com",
        password_hash=hash_password("password123"),
        role="patient",
        name="Demo Patient",
    )
    caregiver = User(
        email="caregiver@example.com",
        password_hash=hash_password("password123"),
        role="caregiver",
        name="Demo Caregiver",
    )
    db.add_all([patient, caregiver])
    db.commit()
    db.refresh(patient)
    for r in [
        Reminder(patient_id=patient.id, title="Hydration", body="Time to drink some water.", reminder_time="10:00"),
        Reminder(patient_id=patient.id, title="Cognitive activity", body="Let's do today's activity.", reminder_time="11:00"),
    ]:
        db.add(r)
    db.commit()

@app.on_event("startup")
def startup():
    db = next(get_db())
    try:
        seed(db)
    finally:
        db.close()

@app.get("/health")
def health():
    return {"status": "ok", "service": "mindweave"}

@app.post("/auth/login", response_model=TokenOut)
def login(data: LoginRequest, db: DBSession = Depends(get_db)):
    user = db.query(User).filter(User.email == data.email).first()
    if not user or not verify_password(data.password, user.password_hash):
        raise HTTPException(401, "Incorrect email or password")
    token = create_access_token(user.id, user.role)
    return {"access_token": token, "user": user}

@app.get("/me", response_model=UserOut)
def me(user: User = Depends(current_user)):
    return user

@app.get("/games")
def games(user: User = Depends(current_user)):
    return [
        {"id": "memory_match", "name": "Memory Match", "description": "Remember and match familiar objects."},
        {"id": "sequence_recall", "name": "Sequence Recall", "description": "Remember an ordered sequence."},
        {"id": "pattern_recognition", "name": "Pattern Recognition", "description": "Identify a familiar pattern."},
        {"id": "routine_recall", "name": "Daily Routine Recall", "description": "Recall the next step in a routine."},
    ]

@app.post("/sessions", response_model=SessionOut)
def create_session(data: SessionCreate, db: DBSession = Depends(get_db), user: User = Depends(current_user)):
    if user.role == "patient" and user.id != data.patient_id:
        raise HTTPException(403, "Cannot create a session for another patient")
    row = Session(**data.model_dump())
    db.add(row)
    db.commit()
    db.refresh(row)

    recent = db.query(Session).filter(Session.patient_id == data.patient_id).order_by(desc(Session.started_at)).limit(12).all()
    if len(recent) >= 3 and data.accuracy < 0.45:
        db.add(Alert(
            patient_id=data.patient_id,
            severity="attention",
            message="Recent activity shows lower performance on this session than the user's usual pattern. Consider checking in with the user.",
        ))
        db.commit()
    return row

@app.get("/patients/{patient_id}/sessions", response_model=list[SessionOut])
def patient_sessions(patient_id: int, db: DBSession = Depends(get_db), user: User = Depends(current_user)):
    if user.role == "patient" and user.id != patient_id:
        raise HTTPException(403, "Forbidden")
    return db.query(Session).filter(Session.patient_id == patient_id).order_by(desc(Session.started_at)).all()

@app.get("/patients/{patient_id}/profile")
def patient_profile(patient_id: int, db: DBSession = Depends(get_db), user: User = Depends(current_user)):
    if user.role == "patient" and user.id != patient_id:
        raise HTTPException(403, "Forbidden")
    sessions = db.query(Session).filter(Session.patient_id == patient_id).order_by(desc(Session.started_at)).all()
    p = build_profile(sessions)
    return {"patient_id": patient_id, "profile": p.__dict__, "baseline_note": "Baseline is personal and longitudinal; this is not a diagnosis."}

@app.get("/patients/{patient_id}/insights")
def patient_insights(patient_id: int, db: DBSession = Depends(get_db), user: User = Depends(current_user)):
    sessions = db.query(Session).filter(Session.patient_id == patient_id).order_by(desc(Session.started_at)).all()
    return {"patient_id": patient_id, "insight": insight(sessions)}

@app.get("/patients/{patient_id}/alerts", response_model=list[AlertOut])
def patient_alerts(patient_id: int, db: DBSession = Depends(get_db), user: User = Depends(current_user)):
    return db.query(Alert).filter(Alert.patient_id == patient_id).order_by(desc(Alert.created_at)).all()

@app.get("/patients/{patient_id}/recommendation", response_model=RecommendationOut)
def recommendation(patient_id: int, db: DBSession = Depends(get_db), user: User = Depends(current_user)):
    sessions = db.query(Session).filter(Session.patient_id == patient_id).order_by(desc(Session.started_at)).all()
    if not sessions:
        return {"game_type": "memory_match", "difficulty": 1, "reason": "Start with a gentle baseline activity."}
    last = sessions[0]
    difficulty = next_difficulty(last.accuracy, last.response_time, last.difficulty)
    return {
        "game_type": last.game_type,
        "difficulty": difficulty,
        "reason": "Difficulty adjusted from the latest interaction using transparent personalization rules.",
    }

@app.get("/patients/{patient_id}/reminders", response_model=list[ReminderOut])
def reminders(patient_id: int, db: DBSession = Depends(get_db), user: User = Depends(current_user)):
    return db.query(Reminder).filter(Reminder.patient_id == patient_id).all()

@app.post("/reminders", response_model=ReminderOut)
def create_reminder(data: ReminderCreate, db: DBSession = Depends(get_db), user: User = Depends(current_user)):
    if user.role == "patient" and user.id != data.patient_id:
        raise HTTPException(403, "Forbidden")
    row = Reminder(**data.model_dump())
    db.add(row)
    db.commit()
    db.refresh(row)
    return row

@app.post("/sync")
def sync(payload: dict, db: DBSession = Depends(get_db), user: User = Depends(current_user)):
    # Idempotency can be strengthened later with client_event_id + unique constraint.
    accepted = 0
    for item in payload.get("sessions", []):
        item["patient_id"] = user.id if user.role == "patient" else item["patient_id"]
        db.add(Session(**item))
        accepted += 1
    db.commit()
    return {"accepted": accepted}
