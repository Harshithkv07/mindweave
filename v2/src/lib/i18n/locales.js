/* ==========================================================================
   The four supported languages.

   v1 duplicated this mapping across four call sites in the Flutter prototype
   and they drifted — one passed the display name ("English") straight into
   setLanguage() as if it were a locale code. One table here, derived from
   everywhere.
   ========================================================================== */

export const LOCALES = {
  en: { native: 'English', english: 'English', tts: 'en-US', date: 'en-US', script: 'latin' },
  ta: { native: 'தமிழ்', english: 'Tamil', tts: 'ta-IN', date: 'ta-IN', script: 'tamil' },
  hi: { native: 'हिन्दी', english: 'Hindi', tts: 'hi-IN', date: 'hi-IN', script: 'devanagari' },
  te: { native: 'తెలుగు', english: 'Telugu', tts: 'te-IN', date: 'te-IN', script: 'telugu' },
}

export const LANGUAGES = Object.keys(LOCALES)

export const DEFAULT_LANGUAGE = 'en'

export const isLanguage = (code) => Object.hasOwn(LOCALES, code)

export const ttsLocale = (code) => (LOCALES[code] ?? LOCALES.en).tts

export const dateLocale = (code) => (LOCALES[code] ?? LOCALES.en).date

/** Format a timestamp in the active language. Caretaker screens pass 'en'
    explicitly — that screen is deliberately English-only. */
export function formatDate(ts, code = DEFAULT_LANGUAGE, opts = { day: 'numeric', month: 'short' }) {
  try {
    return new Date(ts).toLocaleDateString(dateLocale(code), opts)
  } catch {
    return new Date(ts).toLocaleDateString('en-US', opts)
  }
}

export function formatLongDate(ts, code = DEFAULT_LANGUAGE) {
  return formatDate(ts, code, { weekday: 'long', month: 'long', day: 'numeric' })
}
