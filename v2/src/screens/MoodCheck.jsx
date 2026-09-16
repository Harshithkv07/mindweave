import { useState } from 'react'
import Blob, { MOODS } from '../components/Blob'
import { useT } from '../lib/i18n'
import { Screen, TopBar, RingButton, Display, Muted, Waveform } from '../components/ui'
import { Compass } from '../components/Icons'

/* "How are you feeling right now?" — the emotional check-in. */

export default function MoodCheck({ onBack, onLog, onCalm }) {
  const { t } = useT()
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
            <RingButton tone="sky" label={t('mood.companion')}>
              <Compass size={21} />
            </RingButton>
          }
        />

        <div className="mt-6 flex justify-center fade">
          <Blob
            mood={mood ?? 'calm'}
            size={280}
            label={t('mood.lookingLike', { mood: t(`mood.${mood ?? 'calm'}`) })}
          />
        </div>

        <div className="mt-7 text-center rise">
          <Display className="text-[34px]">{t('mood.title')}</Display>
          <Muted className="mt-3">{t('mood.body')}</Muted>
        </div>

        <div className="mt-5">
          <Waveform active={Boolean(mood)} />
        </div>

        {mood ? (
          <p className="mt-1 px-4 text-center text-[15px] leading-relaxed text-ink-soft fade">
            {t(`mood.reply${mood[0].toUpperCase()}${mood.slice(1)}`)}
          </p>
        ) : null}

        <div className="-mx-5 mt-auto overflow-x-auto px-5 pt-8 pb-1">
          <div className="flex gap-3">
            {MOODS.map((m) => (
              <button
                key={m}
                onClick={() => setMood(m)}
                className={`chip ${mood === m ? 'chip-on' : ''}`}
              >
                {t(`mood.${m}`)}
              </button>
            ))}
          </div>
        </div>

        <button onClick={commit} disabled={!mood} className="pill-cta mt-6">
          {mood === 'anxious' || mood === 'upset' ? t('mood.breathe') : t('mood.save')}
        </button>
      </div>
    </Screen>
  )
}
