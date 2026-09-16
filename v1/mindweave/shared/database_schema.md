# Database entities

User
- id
- email
- password_hash
- role
- name

Session
- id
- patient_id
- game_type
- difficulty
- accuracy
- response_time
- mistakes
- completed
- started_at

Reminder
- id
- patient_id
- title
- body
- reminder_time
- active

Alert
- id
- patient_id
- severity
- message
- created_at
- acknowledged
