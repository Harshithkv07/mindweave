/* ==========================================================================
   Adaptive difficulty — the rule-based engine carried over from v1.

   Reads the last 5 sessions *for that specific game*, averages accuracy and
   errors, and picks a tier. Each tier emits a real game config, not a label.
   ========================================================================== */

export const SYMBOLS = ['🍎', '🐱', '🌸', '⭐', '🚗', '🍌', '🏠', '🐶', '⚽', '🌳', '🍇', '🎈']

export const OBJECTS = [
  { icon: '🍎', name: 'Apple' },
  { icon: '🔑', name: 'Key' },
  { icon: '☂️', name: 'Umbrella' },
  { icon: '🕐', name: 'Clock' },
  { icon: '👓', name: 'Glasses' },
  { icon: '☕', name: 'Cup' },
  { icon: '📖', name: 'Book' },
  { icon: '🌷', name: 'Flower' },
  { icon: '🪑', name: 'Chair' },
  { icon: '🧦', name: 'Socks' },
  { icon: '🍞', name: 'Bread' },
  { icon: '📞', name: 'Telephone' },
]

function tierFor(sessions) {
  if (!sessions.length) return 'Medium'

  const avgAccuracy = sessions.reduce((n, s) => n + s.accuracy, 0) / sessions.length
  const avgErrors = sessions.reduce((n, s) => n + s.errors, 0) / sessions.length

  if (avgAccuracy < 70 || avgErrors >= 3.5) return 'Easy'
  if (avgAccuracy >= 85 && avgErrors <= 1.5) return 'Hard'
  return 'Medium'
}

function recentFor(allSessions, game) {
  const own = allSessions.filter((s) => s.game === game).slice(0, 5)
  return own.length ? own : allSessions.slice(0, 5)
}

export function matchConfig(sessions) {
  const tier = tierFor(recentFor(sessions, 'match'))
  const table = {
    Easy: { pairs: 3, cols: 2, flipBackMs: 1200 },
    Medium: { pairs: 4, cols: 2, flipBackMs: 800 },
    Hard: { pairs: 6, cols: 3, flipBackMs: 600 },
  }
  return { tier, ...table[tier], symbols: SYMBOLS.slice(0, table[tier].pairs) }
}

export function objectsConfig(sessions) {
  const tier = tierFor(recentFor(sessions, 'objects'))
  const table = {
    Easy: { remember: 3, options: 6, showSeconds: 6 },
    Medium: { remember: 4, options: 8, showSeconds: 4 },
    Hard: { remember: 5, options: 10, showSeconds: 3 },
  }
  return { tier, ...table[tier] }
}

export function sequenceConfig(sessions) {
  const tier = tierFor(recentFor(sessions, 'sequence'))
  const table = {
    Easy: { pool: 4, cols: 2, startLength: 2, flashMs: 1200 },
    Medium: { pool: 6, cols: 3, startLength: 3, flashMs: 800 },
    Hard: { pool: 9, cols: 3, startLength: 4, flashMs: 500 },
  }
  return { tier, ...table[tier] }
}

/* Narrative insight for the caretaker — last 3 sessions vs the previous 3. */
export function insight(sessions) {
  if (sessions.length < 2) {
    return 'Not enough activity yet. A few more sessions will establish a personal baseline.'
  }
  const recent = sessions.slice(0, 3)
  const older = sessions.slice(3, 6)
  const mean = (xs) => xs.reduce((n, s) => n + s.accuracy, 0) / xs.length

  if (!older.length) {
    return 'Early days. Keep sessions short and regular to build a reliable baseline.'
  }

  const delta = mean(recent) - mean(older)
  if (delta <= -20) {
    return 'Recent sessions are running below the usual personal pattern. Easier activities and a check-in may help.'
  }
  if (delta >= 20) {
    return 'Recent sessions are running above the usual personal pattern. Gradually increasing challenge looks appropriate.'
  }
  return 'Performance is broadly consistent with the recent personal pattern.'
}

/* A caretaker attention flag, mirroring the v1 backend rule. */
export function attentionAlerts(sessions) {
  if (sessions.length < 3) return []
  return sessions
    .slice(0, 6)
    .filter((s) => s.accuracy < 45)
    .map((s) => ({
      id: s.id,
      at: s.at,
      message: 'A session scored well below the usual pattern. Consider checking in.',
    }))
}

export const shuffle = (xs) => {
  const a = [...xs]
  for (let i = a.length - 1; i > 0; i -= 1) {
    const j = Math.floor(Math.random() * (i + 1))
    ;[a[i], a[j]] = [a[j], a[i]]
  }
  return a
}
