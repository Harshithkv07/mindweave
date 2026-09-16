import { Capacitor } from '@capacitor/core'

/* ==========================================================================
   Voice output.

   Android WebView does not implement the Web Speech synthesis API
   (crbug.com/487255), so `window.speechSynthesis` is silently dead inside the
   APK even though it works perfectly in a desktop browser. On a native
   platform we therefore go through @capacitor-community/text-to-speech, and
   keep the Web Speech path for `npm run dev`.

   Both engines sit behind one API so no screen has to know which is running.
   Rate is on the same scale for both — 1.0 is normal — because the plugin
   passes `rate` straight to Android's TextToSpeech.setSpeechRate().
   ========================================================================== */

const native = Capacitor.isNativePlatform()

let plugin = null
let pluginLoad = null

function getPlugin() {
  if (!native) return Promise.resolve(null)
  if (plugin) return Promise.resolve(plugin)
  pluginLoad ??= import('@capacitor-community/text-to-speech')
    .then((m) => {
      plugin = m.TextToSpeech
      return plugin
    })
    .catch(() => null)
  return pluginLoad
}

/* Every stop() or new speak() bumps this. A completion whose token no longer
   matches belongs to an utterance that has since been cancelled, so its onEnd
   must not fire — otherwise the UI clears the indicator for the wrong clip.
   This matters on native especially: the plugin's stop() drops its pending
   callbacks, so those speak() promises never settle at all. */
let generation = 0

export const speechSupported = () =>
  native || (typeof window !== 'undefined' && 'speechSynthesis' in window)

export function stop() {
  generation += 1

  if (native) {
    getPlugin().then((p) => p?.stop().catch(() => {}))
    return
  }
  if (typeof window !== 'undefined' && 'speechSynthesis' in window) {
    window.speechSynthesis.cancel()
  }
}

/**
 * Speak `text`. Resolves once playback finishes (or fails).
 * Callers may fire-and-forget — Voice.jsx does — and drive their UI from
 * onStart/onEnd.
 */
export async function speak(text, { lang = 'en-US', rate = 0.9, onStart, onEnd } = {}) {
  stop()
  const mine = generation

  const settle = (err) => {
    if (mine !== generation) return // superseded by a stop or a newer utterance
    onEnd?.(err)
  }

  if (!text?.trim()) {
    settle()
    return
  }

  onStart?.()

  if (native) {
    const p = await getPlugin()
    if (!p) {
      settle(new Error('tts-unavailable'))
      return
    }
    try {
      await p.speak({ text, lang, rate, pitch: 1.0, volume: 1.0 })
      settle()
    } catch (e) {
      // The plugin rejects with ERROR_UNSUPPORTED_LANGUAGE when the voice data
      // for `lang` is not installed. Surface it so the caller can offer the
      // system installer rather than leaving the patient with silence.
      settle(e instanceof Error ? e : new Error(String(e?.message ?? e)))
    }
    return
  }

  /* ---- web fallback ---- */
  await new Promise((resolve) => {
    const u = new SpeechSynthesisUtterance(text)
    u.lang = lang
    u.rate = rate
    u.pitch = 1
    u.volume = 1

    const voices = window.speechSynthesis.getVoices()
    const base = lang.split('-')[0]
    const preferred =
      voices.find((v) => /natural|premium|enhanced/i.test(v.name) && v.lang.startsWith(base)) ??
      voices.find((v) => v.lang === lang) ??
      voices.find((v) => v.lang.startsWith(base))
    if (preferred) u.voice = preferred

    u.onend = () => {
      settle()
      resolve()
    }
    u.onerror = () => {
      settle(new Error('speech-error'))
      resolve()
    }

    window.speechSynthesis.speak(u)
  })
}

/**
 * Is there a usable voice for this language on this device?
 * Tamil and Telugu voice data in particular is often not installed on Android.
 */
export async function isLanguageAvailable(lang) {
  if (native) {
    const p = await getPlugin()
    if (!p) return false
    try {
      const { supported } = await p.isLanguageSupported({ lang })
      return Boolean(supported)
    } catch {
      return false
    }
  }

  if (typeof window === 'undefined' || !('speechSynthesis' in window)) return false
  const base = lang.split('-')[0]
  const voices = await webVoices()
  // Only claim a language is missing once we have actually seen the list.
  if (!voices.length) return true
  return voices.some((v) => v.lang.startsWith(base))
}

/* getVoices() returns [] until the engine has enumerated, and Chrome only
   signals that through `voiceschanged`. Resolving on the first non-empty read
   avoids telling the patient a voice is missing before we have looked. */
function webVoices() {
  return new Promise((resolve) => {
    const read = () => window.speechSynthesis.getVoices()

    const first = read()
    if (first.length) {
      resolve(first)
      return
    }

    let settled = false
    const done = (list) => {
      if (settled) return
      settled = true
      window.speechSynthesis.removeEventListener('voiceschanged', onChange)
      resolve(list)
    }
    const onChange = () => done(read())

    window.speechSynthesis.addEventListener('voiceschanged', onChange)
    // Some engines never fire the event at all; don't hang on them.
    setTimeout(() => done(read()), 1500)
  })
}

/** Android only: open the system screen for installing TTS voice data. */
export async function openVoiceInstall() {
  if (!native) return false
  const p = await getPlugin()
  if (!p) return false
  try {
    await p.openInstall()
    return true
  } catch {
    return false
  }
}

export const isNativeVoice = () => native
