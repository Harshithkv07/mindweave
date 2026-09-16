import { createContext, useContext, useEffect, useMemo, useState } from 'react'

/* ==========================================================================
   MindWeave store — everything lives in localStorage. No backend, no network.
   ========================================================================== */

const KEY = 'mindweave.v2'

const todayKey = () => new Date().toISOString().slice(0, 10)

function seedReminders() {
  const t = Date.now()
  return [
    { id: 'r1', title: 'Morning medication', time: '08:30', category: 'medication', on: true, created: t },
    { id: 'r2', title: 'Glass of water', time: '10:00', category: 'hydration', on: true, created: t },
    { id: 'r3', title: 'Memory training', time: '10:30', category: 'cognitive', on: true, created: t },
    { id: 'r4', title: 'Afternoon hydration', time: '14:00', category: 'hydration', on: true, created: t },
    { id: 'r5', title: 'Gentle walk or stretch', time: '18:00', category: 'activity', on: true, created: t },
    { id: 'r6', title: 'Evening medication', time: '20:00', category: 'medication', on: true, created: t },
    { id: 'r7', title: 'Calming breath & check-in', time: '20:30', category: 'activity', on: true, created: t },
  ]
}

function blank() {
  return {
    name: 'Margaret',
    onboarded: false,
    sessions: [],
    reminders: seedReminders(),
    moods: [],
    // Per-day adherence: { '2026-09-16': { water: 3, taken: ['r1'] } }
    days: {},
    domains: { memory: 82, attention: 76, pattern: 80, routine: 84 },
  }
}

function load() {
  try {
    const raw = localStorage.getItem(KEY)
    if (!raw) return blank()
    return { ...blank(), ...JSON.parse(raw) }
  } catch {
    return blank()
  }
}

const Ctx = createContext(null)

export function StoreProvider({ children }) {
  const [state, setState] = useState(load)

  useEffect(() => {
    try {
      localStorage.setItem(KEY, JSON.stringify(state))
    } catch {
      /* private mode / quota — the app still works for this session */
    }
  }, [state])

  const api = useMemo(() => {
    const patch = (fn) => setState((s) => ({ ...s, ...fn(s) }))

    return {
      /* ---------------- identity ---------------- */
      setName: (name) => patch(() => ({ name })),
      finishOnboarding: () => patch(() => ({ onboarded: true })),

      /* ---------------- sessions ---------------- */
      recordSession: ({ game, accuracy, errors, seconds, attempts, difficulty }) =>
        patch((s) => {
          const session = {
            id: `s_${Date.now()}`,
            game,
            accuracy: Math.round(accuracy * 10) / 10,
            errors,
            seconds,
            attempts,
            difficulty,
            at: Date.now(),
          }

          // Nudge the matching cognitive domain, exactly as v1 did:
          // (accuracy - 70) * 0.05, clamped to 50..100.
          const domainOf = {
            match: 'memory',
            sequence: 'attention',
            objects: 'pattern',
          }
          const key = domainOf[game] ?? 'routine'
          const delta = (accuracy - 70) * 0.05
          const domains = { ...s.domains }
          domains[key] = Math.round(Math.min(100, Math.max(50, domains[key] + delta)) * 10) / 10

          return { sessions: [session, ...s.sessions].slice(0, 200), domains }
        }),

      /* ---------------- mood ---------------- */
      logMood: (mood) =>
        patch((s) => ({
          moods: [{ mood, at: Date.now() }, ...s.moods].slice(0, 120),
        })),

      /* ---------------- reminders ---------------- */
      toggleReminder: (id) =>
        patch((s) => ({
          reminders: s.reminders.map((r) => (r.id === id ? { ...r, on: !r.on } : r)),
        })),

      addReminder: ({ title, time, category }) =>
        patch((s) => ({
          reminders: [
            ...s.reminders,
            { id: `r_${Date.now()}`, title, time, category, on: true, created: Date.now() },
          ].sort((a, b) => a.time.localeCompare(b.time)),
        })),

      removeReminder: (id) =>
        patch((s) => ({ reminders: s.reminders.filter((r) => r.id !== id) })),

      /* ---------------- daily adherence ---------------- */
      logWater: (delta) =>
        patch((s) => {
          const k = todayKey()
          const day = s.days[k] ?? { water: 0, taken: [] }
          const water = Math.min(12, Math.max(0, day.water + delta))
          return { days: { ...s.days, [k]: { ...day, water } } }
        }),

      markTaken: (reminderId) =>
        patch((s) => {
          const k = todayKey()
          const day = s.days[k] ?? { water: 0, taken: [] }
          const taken = day.taken.includes(reminderId)
            ? day.taken.filter((x) => x !== reminderId)
            : [...day.taken, reminderId]
          return { days: { ...s.days, [k]: { ...day, taken } } }
        }),

      /* ---------------- demo data ---------------- */
      seedDemo: () =>
        patch((s) => {
          const games = ['match', 'objects', 'sequence']
          const tiers = ['Easy', 'Medium', 'Hard']
          const now = Date.now()
          const made = Array.from({ length: 12 }, (_, i) => {
            const accuracy = Math.round((58 + i * 2.6 + (i % 3) * 4) * 10) / 10
            return {
              id: `s_demo_${now}_${i}`,
              game: games[i % 3],
              accuracy: Math.min(97, accuracy),
              errors: Math.max(0, 5 - Math.floor(i / 3)),
              seconds: 70 - i * 2,
              attempts: 8 + (i % 4),
              difficulty: tiers[Math.min(2, Math.floor(i / 4))],
              at: now - (11 - i) * 86400000,
            }
          })
          return { sessions: [...made.reverse(), ...s.sessions] }
        }),

      reset: () => setState(blank()),
    }
  }, [])

  /* ---------------- derived values ---------------- */
  const derived = useMemo(() => {
    const s = state.sessions
    const best = s.reduce((m, x) => Math.max(m, x.accuracy), 0)
    const attempts = s.reduce((n, x) => n + x.attempts, 0)
    const errors = s.reduce((n, x) => n + x.errors, 0)
    const times = s.filter((x) => x.seconds > 0).map((x) => x.seconds)
    const avg = s.length ? s.reduce((n, x) => n + x.accuracy, 0) / s.length : 0
    const d = state.domains
    const baseline = (d.memory + d.attention + d.pattern + d.routine) / 4
    const today = state.days[todayKey()] ?? { water: 0, taken: [] }

    return {
      played: s.length,
      bestAccuracy: best,
      avgAccuracy: Math.round(avg * 10) / 10,
      bestTime: times.length ? Math.min(...times) : 0,
      totalAttempts: attempts,
      totalErrors: errors,
      baseline: Math.round(baseline * 10) / 10,
      today,
      streak: computeStreak(s),
    }
  }, [state])

  return <Ctx.Provider value={{ ...state, ...api, ...derived }}>{children}</Ctx.Provider>
}

function computeStreak(sessions) {
  if (!sessions.length) return 0
  const days = new Set(sessions.map((s) => new Date(s.at).toISOString().slice(0, 10)))
  let n = 0
  const cursor = new Date()
  for (;;) {
    const k = cursor.toISOString().slice(0, 10)
    if (!days.has(k)) break
    n += 1
    cursor.setDate(cursor.getDate() - 1)
  }
  return n
}

export const useStore = () => {
  const v = useContext(Ctx)
  if (!v) throw new Error('useStore must be used inside <StoreProvider>')
  return v
}

export const GAME_LABEL = {
  match: 'Memory Match',
  objects: 'Remember Objects',
  sequence: 'Sequence Memory',
}

export const DOMAIN_LABEL = {
  memory: 'Memory',
  attention: 'Attention & focus',
  pattern: 'Pattern recognition',
  routine: 'Routine & sequence',
}
