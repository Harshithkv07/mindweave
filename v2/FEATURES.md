# MindWeave — Feature Inventory (extracted from v1)

Source of truth: `v1/mindweave/`. Three overlapping implementations existed:

| Layer | Path | Role |
|---|---|---|
| Flutter shell (current) | `lib/` | The live app — 3 games, patient home, caretaker dashboard, offline Hive storage |
| Flutter prototype (legacy) | `patient_app/lib/main.dart` (5.8k lines) | Earlier, wider build — 4 games, login flow, 4-language i18n, alarms |
| Python/React stack (unused by the app) | `backend/`, `caregiver_dashboard/` | FastAPI + SQLite + a Recharts caregiver web dashboard |

---

## 1. Entry & identity

- **Netflix-style profile picker** — exactly two tiles: *Patient View* and *Caretaker*. No passwords, no forms. First decision is a picture, not a credential.
- **Legacy prototype also had:** email/password login split into separate Patient and Caretaker login pages, plus a **language selection screen** (English / Tamil / Hindi / Telugu) with a `T.text(key, language)` translation table.
- **Backend also had:** JWT bearer auth, `patient` vs `caregiver` roles, row-level access checks (a patient can't read another patient's sessions).

## 2. Patient home dashboard

- Time-aware greeting (Good Morning / Afternoon / Evening / Night) with avatar initial.
- **Live stat row** — Games Played · Best Accuracy · Baseline score, all computed from real stored sessions.
- **Quick-action grid (5 tiles)** — Memory Games · Medication · Hydration · Voice Assistant · My Progress.
- **Medication & Hydration modal dialogs** that also speak the prompt aloud via TTS.
- **Today's Schedule** — inline list of the next routines with per-row enable/disable toggles.

## 3. Cognitive games (3 live, 4 in the legacy prototype)

| Game | Mechanic | Domain trained |
|---|---|---|
| **Memory Match** | Flip cards, find matching emoji pairs | Memory |
| **Remember Objects** | Objects shown for N seconds, then recall them from options | Pattern recognition |
| **Sequence Memory** | Symbols flash in order, patient repeats the sequence; length grows per level | Attention & focus |
| *Pattern Recognition* (legacy only) | Identify a familiar pattern | Recognition |
| *Routine Recall* (legacy only) | Recall the next step in a daily routine | Routine & sequencing |

Shared per-game behaviour:
- Adaptive difficulty banner showing the current tier.
- Live stats row during play (attempts, errors, timer, level).
- Per-card/per-tap **response-speed tracking**.
- Completion dialog with accuracy, time, errors, difficulty tag, and *Play Again* / *Done*.
- Every finished round is persisted as a `CognitiveSession`.

## 4. Adaptive difficulty engine (rule-based, fully local)

Reads the last 5 sessions **for that specific game**, computes average accuracy and average errors, and picks a tier:

- **Easy** — accuracy < 70% **or** avg errors ≥ 3.5
- **Hard** — accuracy ≥ 85% **and** avg errors ≤ 1.5
- **Medium** — everything else (also the default for a brand-new user)

Each tier emits a concrete game config, not just a label:

- *Memory Match* — pair count (2 / 4 / 6), grid columns, flip-back delay (1200 / 800 / 600 ms)
- *Remember Objects* — objects to remember (3 / 4 / 5), option count, display duration (6 / 4 / 3 s)
- *Sequence Memory* — symbol pool (4 / 6 / 9), starting sequence length (2 / 3 / 4), flash interval (1200 / 800 / 500 ms)

Backend variant used a different rule: bump difficulty if accuracy ≥ 85% and response time ≤ 8s; drop it if accuracy < 50% or response time > 20s.

## 5. Cognitive profile & four domain baselines

A `PatientProfile` carries four independently-tracked scores plus a composite baseline:

- **Memory** ← Memory Match
- **Attention & Focus** ← Sequence Memory
- **Pattern Recognition** ← Remember Objects
- **Routine & Sequential** ← everything else

After each session the matching domain moves by `(accuracy − 70) × 0.05`, clamped to 50–100, and the baseline is re-derived as the mean of the four.

## 6. Progress screen (patient-facing)

- Metric cards — Sessions · Best Accuracy · Best Time · Total Attempts · Total Errors.
- Domain baseline bars for all four cognitive domains.
- Recent session history (last 8) with game icon, timestamp, errors, duration, difficulty, and a colour-coded accuracy figure (green ≥ 70%, amber below).
- Manual refresh from local storage.

## 7. Caretaker analytics dashboard

- **Clinical overview banner** — baseline score, total sessions, average accuracy.
- **Daily Adherence card**, deliberately split into two subsections:
  - *Medication* — routine list with large (≥ 48px) toggle switches.
  - *Hydration* — visual glass indicators with a daily target, **+1 Glass Logged** and **Undo** actions.
- **Cognitive Trends card** — `fl_chart` line graph of accuracy over the last 7 sessions, with filter chips (All / Memory Match / Remember Objects / Sequence Memory), oversized legible axes, rich touch tooltips, and a **75% baseline reference line**.
- **Recent Sessions table** — Game Type · Accuracy · Mistakes · Duration · Difficulty.
- **Seed Sample Analytics Data** button for demos on an empty dataset.
- Empty state when no sessions exist yet.

## 8. Voice assistant (TTS)

- Speaker hero banner addressed to the patient by name.
- **Five guided care flows**, each a one-tap spoken script:
  1. Daily Orientation & Morning Greeting
  2. Hydration & Water Reminder
  3. Prescribed Medication Routine
  4. Cognitive Game Encouragement
  5. Calming Breath & Relaxation
- **Voice controls** — play/stop, adjustable speech pace slider (rendered as a %).
- **Custom speaker card** — type any text and have it read aloud, with Clear/Speak.
- Speech rate pinned to a slow 0.42 by default for comprehension.

## 9. Reminders & notifications

- Three notification channels: **Medication**, **Hydration**, **General Care**.
- Repeating daily scheduled alerts, with an exact-alarm path and an inexact fallback.
- Preconfigured defaults: hydration at 10:00 / 14:00 / 17:30, medication at 08:30 / 20:00.
- Reminders sync from stored routines into the OS scheduler; disabling a routine cancels its notification.
- Category → emoji mapping (💊 💧 🧠 🚶 ⏰).
- Seeded starter routines on first launch: morning medication, morning water, morning memory game, afternoon hydration, evening medication, evening relaxation & voice check-in.
- Per-reminder CRUD: add, toggle, delete.

## 10. Data & persistence

- **Offline-first** — three Hive boxes (`cognitive_sessions`, `daily_reminders`, `patient_profiles`) with hand-written type adapters. No network required for anything the app does.
- Derived progress metrics computed on read rather than stored.
- First-launch seeding of default routines and a default profile.
- Legacy backend alternative: FastAPI + SQLAlchemy + SQLite with `users` / `sessions` / `reminders` / `alerts` tables, a `/sync` endpoint for offline queue flushing, and a local write queue on the client.

## 11. Caregiver alerting (backend only, never wired into the Flutter app)

- Auto-raises an `attention` alert when a session scores below 45% accuracy and at least 3 sessions exist.
- Narrative insight generator comparing the last 3 sessions against the previous 3: flags a ≥ 20-point drop or rise, otherwise reports "broadly consistent".
- Every output carries the disclaimer that the baseline is personal and longitudinal, **not a diagnosis**.

## 12. Accessibility posture (the strongest through-line in v1)

- Minimum 48×48 touch targets, 56px for primary senior actions.
- Minimum 15px legible font size; large, bold chart axes and tooltips.
- WCAG AAA contrast targets (>7:1) across the palette.
- Generous line heights, heavy font weights, big rounded corners (14–28px).
- Blue/teal/amber clinical palette — explicitly no purple.
- Light and dark theme definitions.
- Emoji used as a redundant, language-independent channel alongside text.

---

## Carry-forward list for v2

Must have:
1. Two-role entry (patient / caretaker) with no password friction
2. Patient home with greeting, live stats, quick actions, today's schedule
3. Three cognitive games with adaptive difficulty
4. Four-domain cognitive profile + composite baseline
5. Patient progress view
6. Caretaker dashboard: adherence + trend chart + session table
7. Voice assistant with guided care flows
8. Reminder list with toggles and categories
9. Accessibility-first sizing and contrast

Worth reviving from the legacy prototype:
10. Multi-language support (English / Tamil / Hindi / Telugu)
11. Two extra games — Pattern Recognition, Routine Recall
12. Caregiver attention alerts with narrative insights

---

# v2 build status

`v2/` is a ground-up React + Vite + Tailwind rebuild. It shares no code with v1 —
only the feature inventory above.

## Built and verified in the browser

| v1 feature | v2 |
|---|---|
| Two-role entry, no password | Profile picker, plus a new onboarding screen |
| Patient home: greeting, live stats, quick actions, today's schedule | ✅ |
| Memory Match | ✅ card-flip with 3D transform |
| Remember Objects | ✅ timed study phase → recall grid |
| Sequence Memory | ✅ flash playback, growing sequence, progress pips |
| Adaptive difficulty engine | ✅ same rules, same tier thresholds, same emitted configs |
| Four-domain profile + composite baseline | ✅ same `(accuracy − 70) × 0.05` nudge |
| Patient progress view | ✅ figures, trend chart, domain meters, session history |
| Caretaker dashboard | ✅ badges, adherence (medication + hydration), filterable trend, domains, session log |
| Caregiver attention alerts + narrative insight | ✅ carried from the v1 backend rules into the client |
| Voice assistant, 5 guided care flows | ✅ via Web Speech synthesis, with a pace slider and free-text reader |
| Reminder CRUD with category toggles | ✅ |
| Hydration glass counter with +1 / Undo | ✅ |
| Offline-first persistence | ✅ `localStorage` in place of Hive |
| Accessibility sizing (48px targets, 15px+ text) | ✅ |

## New in v2

- **Mood check-in** — the companion blob, an emotion chip picker, and a
  waveform. Reporting *anxious* or *upset* routes straight into the calming
  breath script.
- **Weave, the companion blob** — five expressions, used as a non-verbal state
  cue on the home card, the result sheets and the voice screen.
- **Onboarding screen** — the stacked-card opener from the reference design.
- **Streak card** on home once two consecutive days are logged.

## Deliberately not carried over

- **OS-scheduled notifications.** v1 used `flutter_local_notifications` to fire
  alerts at 08:30, 10:00, 14:00, 17:30 and 20:00 even when the app was closed. A
  frontend-only web app cannot do that reliably — background scheduling needs a
  service worker plus a push service, i.e. the backend this rebuild is meant to
  avoid. Routines in v2 are a visual schedule with done-marking. **This is the
  one real capability regression from v1.**
- **Multi-language (Tamil / Hindi / Telugu).** The v1 prototype's `T` table
  covered ~11 strings; wiring real i18n is a separate piece of work.
- **Pattern Recognition** and **Routine Recall** — the two games that existed
  only in the legacy prototype, never in the shipped v1 shell.

## Scoring change

Memory Match accuracy is now `√(pairs / turns) × 100` rather than a flat
`pairs / turns`. The flat ratio scored an ordinary trial-and-error round in the
single digits, which contradicts the app's "no way to fail" framing.

---

# Voice + multilingual (added after the first APK)

## Why voice was broken

The first APK shipped with `window.speechSynthesis`. **Android WebView does not
implement Web Speech synthesis** ([crbug.com/487255](https://issues.chromium.org/issues/40417848)),
so every voice feature was dead inside the APK while working perfectly in a
desktop browser — which is exactly why it passed testing.

Replaced with `@capacitor-community/text-to-speech` (MIT) on native, keeping the
Web Speech path for `npm run dev`. Both sit behind one API in `src/lib/speech.js`.

Three things that needed care:
- **`stop()` drops the plugin's pending callbacks**, so an awaited `speak()`
  never settles after a cancel. A generation token discards stale completions.
- **A `<queries>` entry for `TTS_SERVICE` is mandatory** on Android 11+. Without
  it the app cannot see the TTS engine at all and both `isLanguageSupported()`
  and `openInstall()` fail *silently*.
- **Rate is on the same 1.0-is-normal scale** for both engines, since the plugin
  passes `rate` straight to Android's `setSpeechRate()`. No conversion needed.

## Missing voice data

Tamil and Telugu voices are often not installed on Android. Before speaking, the
app checks `isLanguageSupported()` and, if absent, offers either the system
installer (`openInstall()`) or an English fallback — rather than silence.

## Multilingual — English, Tamil, Hindi, Telugu

- **235 keys per language**, hand-rolled runtime in `src/lib/i18n/`. No i18n
  library: catalogs are small, `Intl.PluralRules` is already in the WebView, and
  it must work fully offline.
- **Ids stay English, labels are looked up.** Difficulty tiers, mood ids, game
  ids and domain keys are persisted in localStorage, so translating them in
  place would break both lookups and historical data.
- **Seeded routines carry a `titleKey`**, so they rename with the language.
  Older installs are migrated by id. User-created routines keep their own words.
- **Sentences are whole units.** The bolded-count streak line and the Games
  detail line were assembled from fragments; both are now single catalog entries
  (see the `<Rich>` helper in `components/ui.jsx`).
- **Caretaker screen stays English** by design and reads `en.json` directly.

## Fonts

Noto Sans + Noto Serif for Devanagari, Tamil and Telugu, bundled locally
(+~575 KB; APK went 5.5 → 6.1 MB). Swapped per language by `:root:lang()`
overriding the Tailwind `--font-sans` / `--font-display` tokens, so no component
changed. Keeps the serif display voice in every language.

Also fixed while here: fixed card heights became minimums (translated labels
clipped), `uppercase`/`letter-spacing` is now Latin-only (it breaks Indic
shaping), and pinch-zoom is re-enabled — it was disabled, which is poor for a
senior-facing app rendering dense Indic glyphs at 12px.

## ⚠️ Translation review

The ~30 strings carried over from the v1 Flutter prototype are human-written.
**The remaining ~205 × 3 languages are machine-written and have not been
reviewed by a native speaker.** The medication and hydration scripts, and the
"not a diagnosis" disclaimers, should be checked before this goes in front of
real patients.
