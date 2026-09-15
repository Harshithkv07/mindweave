from dataclasses import dataclass
from statistics import mean

@dataclass
class Profile:
    memory: float
    attention: float
    recognition: float
    routine: float

def domain_for_game(game_type: str) -> str:
    return {
        "memory_match": "memory",
        "sequence_recall": "attention",
        "pattern_recognition": "recognition",
        "routine_recall": "routine",
    }.get(game_type, "memory")

def build_profile(sessions) -> Profile:
    buckets = {"memory": [], "attention": [], "recognition": [], "routine": []}
    for s in sessions:
        buckets[domain_for_game(s.game_type)].append(max(0, min(1, s.accuracy)) * 100)
    return Profile(**{
        k: round(mean(v), 1) if v else 0
        for k, v in buckets.items()
    })

def next_difficulty(accuracy: float, response_time: float, current: int) -> int:
    if accuracy >= 0.85 and response_time <= 8:
        return min(5, current + 1)
    if accuracy < 0.50 or response_time > 20:
        return max(1, current - 1)
    return current

def insight(sessions) -> str:
    if not sessions:
        return "Not enough activity yet. Complete a few sessions to establish a personal baseline."
    recent = sessions[:3]
    older = sessions[3:6]
    recent_avg = mean(s.accuracy for s in recent)
    if older:
        older_avg = mean(s.accuracy for s in older)
        delta = recent_avg - older_avg
        if delta <= -0.20:
            return "Recent performance is below the user's recent personal pattern. Consider offering easier activities and caregiver attention."
        if delta >= 0.20:
            return "Recent performance is above the user's recent personal pattern. Gradually increasing challenge may be appropriate."
    return "Performance is broadly consistent with the user's recent personal pattern."
