/* ==========================================================================
   Voice — the browser's own speech synthesis. Works offline, no API key.
   ========================================================================== */

let current = null

export const speechSupported = () =>
  typeof window !== 'undefined' && 'speechSynthesis' in window

export function speak(text, { rate = 0.85, onEnd, onStart } = {}) {
  if (!speechSupported()) {
    onEnd?.()
    return
  }

  stop()

  const u = new SpeechSynthesisUtterance(text)
  u.rate = rate
  u.pitch = 1
  u.volume = 1
  u.lang = 'en-US'

  // Prefer a natural-sounding English voice when the platform offers one.
  const voices = window.speechSynthesis.getVoices()
  const preferred =
    voices.find((v) => /natural|premium|enhanced/i.test(v.name) && v.lang.startsWith('en')) ??
    voices.find((v) => v.lang === 'en-US') ??
    voices.find((v) => v.lang.startsWith('en'))
  if (preferred) u.voice = preferred

  u.onstart = () => onStart?.()
  u.onend = () => {
    current = null
    onEnd?.()
  }
  u.onerror = () => {
    current = null
    onEnd?.()
  }

  current = u
  window.speechSynthesis.speak(u)
}

export function stop() {
  if (!speechSupported()) return
  window.speechSynthesis.cancel()
  current = null
}

export const isSpeaking = () =>
  speechSupported() && window.speechSynthesis.speaking

/* The five guided care flows carried over from v1's voice assistant. */
export const CARE_FLOWS = [
  {
    id: 'orientation',
    title: 'Morning orientation',
    blurb: 'Grounds the day, the date and what comes next.',
    icon: '🌅',
    script: (name) =>
      `Good morning ${name}. Today is ${new Date().toLocaleDateString('en-US', {
        weekday: 'long',
        month: 'long',
        day: 'numeric',
      })}. You are safe and you are at home. In a little while there will be breakfast, and then some gentle memory activities. There is nothing you need to worry about right now.`,
  },
  {
    id: 'hydration',
    title: 'Hydration prompt',
    blurb: 'A gentle nudge toward a glass of water.',
    icon: '💧',
    script: (name) =>
      `${name}, this is a gentle reminder to have some water. A full glass now will help you feel clearer and more comfortable. Take your time, there is no rush.`,
  },
  {
    id: 'medication',
    title: 'Medication routine',
    blurb: 'Walks through taking the scheduled dose.',
    icon: '💊',
    script: (name) =>
      `${name}, it is time for your scheduled medication. Find your pill box, take the dose for this time of day, and drink a full glass of water with it. When you have finished, you can mark it as taken.`,
  },
  {
    id: 'encouragement',
    title: 'Before a memory game',
    blurb: 'Explains the activity and takes the pressure off.',
    icon: '🌱',
    script: (name) =>
      `${name}, you are about to do a short memory activity. There is no score to worry about and no way to fail. Simply look, take your time, and choose what feels right. Every attempt helps.`,
  },
  {
    id: 'calming',
    title: 'Calming breath',
    blurb: 'A guided breath for restless moments.',
    icon: '🫧',
    script: () =>
      `Let us take a moment together. Breathe in slowly through your nose, two, three, four. Hold gently, two, three. And breathe out slowly through your mouth, two, three, four, five. Again. In, two, three, four. Hold. And out, slowly. You are doing beautifully. Let your shoulders drop, and rest here as long as you like.`,
  },
]
