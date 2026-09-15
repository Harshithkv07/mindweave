# MindWeave API contract

## Auth
POST /auth/login
- body: `{email,password}`
- returns: `{access_token, token_type, user}`

## Patient
POST /sessions
GET /patients/{patient_id}/sessions
GET /patients/{patient_id}/profile
GET /patients/{patient_id}/insights
GET /patients/{patient_id}/alerts
GET /patients/{patient_id}/recommendation
GET /patients/{patient_id}/reminders

## Sync
POST /sync
- body: `{ "sessions": [SessionCreate, ...] }`

## Design rule
Patient performance is compared primarily with the patient's own longitudinal history. The API never labels an interaction score as a diagnosis.
