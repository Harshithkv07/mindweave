from pydantic import BaseModel, EmailStr, ConfigDict
from typing import Optional
from datetime import datetime

class LoginRequest(BaseModel):
    email: EmailStr
    password: str

class UserOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    email: EmailStr
    role: str
    name: str

class TokenOut(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserOut

class SessionCreate(BaseModel):
    patient_id: int
    game_type: str
    difficulty: int
    accuracy: float
    response_time: float
    mistakes: int
    completed: bool = True

class SessionOut(SessionCreate):
    model_config = ConfigDict(from_attributes=True)
    id: int
    started_at: Optional[datetime] = None

class ReminderCreate(BaseModel):
    patient_id: int
    title: str
    body: str
    reminder_time: str
    active: bool = True

class ReminderOut(ReminderCreate):
    model_config = ConfigDict(from_attributes=True)
    id: int

class AlertOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    patient_id: int
    severity: str
    message: str
    created_at: Optional[datetime] = None
    acknowledged: bool

class RecommendationOut(BaseModel):
    game_type: str
    difficulty: int
    reason: str
