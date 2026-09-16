import { useEffect, useState } from 'react'
import Blob from '../components/Blob'
import { useStore } from '../lib/store'
import { useT } from '../lib/i18n'
import { LOCALES, ttsLocale, formatLongDate } from '../lib/i18n/locales'
import { CARE_FLOWS } from '../lib/careFlows'
import { speak, stop, speechSupported, isLanguageAvailable, openVoiceInstall } from '../lib/speech'
import {
  Screen, TopBar, RingButton, Display, Muted, Card, Tappable, Waveform, SectionTitle,
} from '../components/ui'
import { Play, Stop, Wave } from '../components/Icons'

/* The voice companion.

   Speech goes through the native Android engine when running in the APK —
   see lib/speech.js for why the Web Speech API cannot be used there. */

export default function Voice({ onBack, initialFlow }) {
  const s = useStore()
  const { t, language } = useT()

  const [active, setActive] = useState(null)
  const [rate, setRate] = useState(0.9)
  const [custom, setCustom] = useState('')
  const [voiceMissing, setVoiceMissing] = useState(false)
  const [fallbackEnglish, setFallbackEnglish] = useState(false)

  const supported = speechSupported()
  const lang = fallbackEnglish ? 'en-US' : ttsLocale(language)

  useEffect(() => () => stop(), [])

  /* Tamil and Telugu voice data is often absent on Android. Check up front so
     the patient gets an explanation rather than silence. */
  useEffect(() => {
    let cancelled = false
    setFallbackEnglish(false)
    isLanguageAvailable(ttsLocale(language)).then((ok) => {
      if (!cancelled) setVoiceMissing(!ok)
    })
    return () => {
      cancelled = true
    }
  }, [language])

  const say = (id, text) => {
    if (active === id) {
      stop()
      setActive(null)
      return
    }
    speak(text, {
      lang,
      rate,
      onStart: () => setActive(id),
      onEnd: (err) => {
        setActive(null)
        if (err) setVoiceMissing(true)
      },
    })
  }

  const runFlow = (flow) =>
    say(
      flow.id,
      t(`voice.${flow.id}Script`, {
        name: s.name,
        date: formatLongDate(Date.now(), language),
      }),
    )

  /* Arriving here from a distressed mood check runs the calming script. */
  useEffect(() => {
    if (!initialFlow) return
    const flow = CARE_FLOWS.find((f) => f.id === initialFlow)
    if (flow) runFlow(flow)
  }, [initialFlow]) // eslint-disable-line react-hooks/exhaustive-deps

  return (
    <Screen>
      <div className="pb-36">
        <TopBar
          onBack={onBack}
          right={
            <RingButton tone="sky" label={t('voice.label')} active={Boolean(active)}>
              <Wave size={21} />
            </RingButton>
          }
        />

        <div className="mt-3 flex flex-col items-center text-center">
          <Blob mood={active ? 'happy' : 'calm'} size={200} />
          <Display className="mt-4 text-[32px]">{t('voice.title')}</Display>
          <Muted className="mt-3 max-w-[300px]">{t('voice.body')}</Muted>
        </div>

        <div className="mt-4">
          <Waveform active={Boolean(active)} />
        </div>

        {!supported ? (
          <Card className="mt-2 p-5">
            <Muted>{t('voice.unsupported')}</Muted>
          </Card>
        ) : null}

        {/* Missing voice data for the chosen language. */}
        {supported && voiceMissing && !fallbackEnglish ? (
          <Card variant="glass-solid" className="mt-2 border-l-[5px] border-l-[#dd9a4b] p-5">
            <p className="text-[15.5px] font-semibold text-ink">{t('voice.missingTitle')}</p>
            <p className="mt-1.5 text-[14px] leading-[1.5] text-ink-muted">
              {t('voice.missingBody', { language: LOCALES[language].native })}
            </p>
            <div className="mt-4 flex flex-wrap gap-3">
              <button
                onClick={openVoiceInstall}
                className="h-11 flex-1 rounded-full bg-ink px-4 text-[14.5px] font-semibold text-white"
              >
                {t('voice.installVoice')}
              </button>
              <button
                onClick={() => setFallbackEnglish(true)}
                className="h-11 flex-1 rounded-full bg-black/6 px-4 text-[14.5px] font-medium text-ink-soft"
              >
                {t('voice.useEnglish')}
              </button>
            </div>
          </Card>
        ) : null}

        {/* pace */}
        <Card className="mt-3 flex items-center gap-4 p-5">
          <span className="text-[14px] font-medium text-ink-soft">{t('voice.pace')}</span>
          <input
            type="range"
            min="0.5"
            max="1.3"
            step="0.05"
            value={rate}
            onChange={(e) => setRate(Number(e.target.value))}
            aria-label={t('voice.pace')}
            className="h-2 flex-1 cursor-pointer appearance-none rounded-full bg-black/10 accent-sky-500"
          />
          <span className="w-[46px] text-right text-[14px] font-semibold text-sky-600">
            {Math.round(rate * 100)}%
          </span>
        </Card>

        <SectionTitle>{t('voice.moments')}</SectionTitle>
        <div className="space-y-3">
          {CARE_FLOWS.map((flow, i) => {
            const on = active === flow.id
            return (
              <Tappable
                key={flow.id}
                onClick={() => runFlow(flow)}
                className="block w-full rise"
                style={{ animationDelay: `${i * 60}ms` }}
              >
                <Card
                  variant={on ? 'glass-solid' : 'glass'}
                  className={`flex items-center gap-4 p-5 ${on ? 'ring-2 ring-sky-400' : ''}`}
                >
                  <span className="grid h-[54px] w-[54px] shrink-0 place-items-center rounded-full bg-white/80 text-[24px]">
                    {flow.icon}
                  </span>
                  <span className="min-w-0 flex-1">
                    <span className="block text-[16.5px] font-semibold leading-snug text-ink">
                      {t(`voice.${flow.id}Title`)}
                    </span>
                    <span className="mt-0.5 block text-[13.5px] leading-snug text-ink-muted">
                      {t(`voice.${flow.id}Blurb`)}
                    </span>
                  </span>
                  <span
                    className={`grid h-12 w-12 shrink-0 place-items-center rounded-full ${
                      on ? 'bg-sky-500 text-white' : 'bg-black/6 text-ink-soft'
                    }`}
                  >
                    {on ? <Stop size={20} /> : <Play size={20} />}
                  </span>
                </Card>
              </Tappable>
            )
          })}
        </div>

        <SectionTitle>{t('voice.sayElse')}</SectionTitle>
        <Card className="p-5">
          <textarea
            value={custom}
            onChange={(e) => setCustom(e.target.value)}
            rows={3}
            placeholder={t('voice.customPlaceholder')}
            className="w-full resize-none rounded-[20px] bg-white/70 p-4 text-[15.5px] leading-relaxed text-ink placeholder:text-ink-faint focus:outline-none focus:ring-2 focus:ring-sky-400"
          />
          <div className="mt-3 flex gap-3">
            <button
              onClick={() => {
                setCustom('')
                stop()
                setActive(null)
              }}
              className="h-12 flex-1 rounded-full bg-black/6 text-[15px] font-medium text-ink-soft"
            >
              {t('common.clear')}
            </button>
            <button
              onClick={() => say('custom', custom)}
              disabled={!custom.trim()}
              className="h-12 flex-[1.4] rounded-full bg-ink text-[15px] font-semibold text-white disabled:opacity-35"
            >
              {active === 'custom' ? t('voice.stop') : t('voice.readAloud')}
            </button>
          </div>
        </Card>
      </div>
    </Screen>
  )
}
