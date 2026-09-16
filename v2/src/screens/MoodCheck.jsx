import { useState } from 'react'
import Blob, { MOODS } from '../components/Blob'
import { Screen, TopBar, RingButton, Display, Muted, Waveform } from '../components/ui'
import { Compass } from '../components/Icons'

/* "How are you feeling right now?" — the emotional check-in. */

const RESPONSE = {
  happy: 'That is lovely to hear. Let us keep the day gentle and steady.',
  calm: 'Calm is a good place to be. Nothing here is in a hurry.',
  tired: 'Rest is allowed. Perhaps something short and easy today.',
  anxious: 'That feeling will pass. A slow breath together might help.',
  upset: 'Thank you for telling me. You do not have to carry it alone.',
}

export default function MoodCheck({ onBack, onLog, onCalm }) {
  const [mood, setMood] = useState(null)

  const commit = () => {
    if (!mood) return
    onLog(mood)
    if (mood === 'anxious' || mood === 'upset') onCalm()
    else onBack()
  }

  return (
    <Screen>
      <div className="flex min-h-[100dvh] flex-col pb-10">
        <TopBar
          onBack={onBack}
          right={
            <RingButton tone="sky" label="Companion">
              <Compass size={21} />
            </RingButton>
          }
        />

        <div className="mt-6 flex justify-center fade">
          <Blob mood={mood ?? 'calm'} size={280} />
        </div>

        <div className="mt-7 text-center rise">
          <Display className="text-[34px]">
            How are you
            <br />
            feeling right now?
          </Display>
          <Muted className="mt-3">Choose whichever fits best</Muted>
        </div>

        <div className="mt-5">
          <Waveform active={Boolean(mood)} />
        </div>

        {mood ? (
          <p className="mt-1 px-4 text-center text-[15px] leading-relaxed text-ink-soft fade">
            {RESPONSE[mood]}
          </p>
        ) : null}

        <div className="-mx-5 mt-auto overflow-x-auto px-5 pt-8 pb-1">
          <div className="flex gap-3">
            {MOODS.map((m) => (
              <button
                key={m.id}
                onClick={() => setMood(m.id)}
                className={`chip ${mood === m.id ? 'chip-on' : ''}`}
              >
                {m.label}
              </button>
            ))}
          </div>
        </div>

        <button onClick={commit} disabled={!mood} className="pill-cta mt-6">
          {mood === 'anxious' || mood === 'upset' ? 'Breathe with me' : 'Save how I feel'}
        </button>
      </div>
    </Screen>
  )
}
