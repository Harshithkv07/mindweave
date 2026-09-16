import { useEffect, useState } from 'react'
import Blob from '../components/Blob'
import { useStore } from '../lib/store'
import { CARE_FLOWS, speak, stop, speechSupported } from '../lib/speech'
import {
  Screen, TopBar, RingButton, Display, Muted, Card, Tappable, Waveform, SectionTitle,
} from '../components/ui'
import { Play, Stop, Wave } from '../components/Icons'

/* The voice companion. Uses the browser's own speech synthesis — no keys, no network. */

export default function Voice({ onBack, initialFlow }) {
  const s = useStore()
  const [active, setActive] = useState(null)
  const [rate, setRate] = useState(0.85)
  const [custom, setCustom] = useState('')
  const supported = speechSupported()

  useEffect(() => () => stop(), [])

  const run = (flow) => {
    if (active === flow.id) {
      stop()
      setActive(null)
      return
    }
    const text = flow.script(s.name)
    speak(text, { rate, onStart: () => setActive(flow.id), onEnd: () => setActive(null) })
  }

  /* deep-link: arriving here from a distressed mood check runs the calming flow */
  useEffect(() => {
    if (!initialFlow) return
    const flow = CARE_FLOWS.find((f) => f.id === initialFlow)
    if (flow) run(flow)
  }, [initialFlow]) // eslint-disable-line react-hooks/exhaustive-deps

  const speakCustom = () => {
    if (!custom.trim()) return
    if (active === 'custom') {
      stop()
      setActive(null)
      return
    }
    speak(custom, { rate, onStart: () => setActive('custom'), onEnd: () => setActive(null) })
  }

  return (
    <Screen>
      <div className="pb-36">
        <TopBar
          onBack={onBack}
          right={
            <RingButton tone="sky" label="Voice" active={Boolean(active)}>
              <Wave size={21} />
            </RingButton>
          }
        />

        <div className="mt-3 flex flex-col items-center text-center">
          <Blob mood={active ? 'happy' : 'calm'} size={200} />
          <Display className="mt-4 text-[32px]">
            Shall I talk you
            <br />
            through it?
          </Display>
          <Muted className="mt-3 max-w-[290px]">
            Pick a moment below and I&rsquo;ll read it aloud, slowly.
          </Muted>
        </div>

        <div className="mt-4">
          <Waveform active={Boolean(active)} />
        </div>

        {!supported ? (
          <Card className="mt-2 p-5">
            <Muted>
              This browser has no speech voice available, so the scripts are shown as
              text instead. They still work read on-screen.
            </Muted>
          </Card>
        ) : null}

        {/* pace */}
        <Card className="mt-3 flex items-center gap-4 p-5">
          <span className="text-[14px] font-medium text-ink-soft">Pace</span>
          <input
            type="range"
            min="0.5"
            max="1.2"
            step="0.05"
            value={rate}
            onChange={(e) => setRate(Number(e.target.value))}
            aria-label="Speaking pace"
            className="h-2 flex-1 cursor-pointer appearance-none rounded-full bg-black/10 accent-sky-500"
          />
          <span className="w-[46px] text-right text-[14px] font-semibold text-sky-600">
            {Math.round(rate * 100)}%
          </span>
        </Card>

        <SectionTitle>Moments</SectionTitle>
        <div className="space-y-3">
          {CARE_FLOWS.map((flow, i) => {
            const on = active === flow.id
            return (
              <Tappable
                key={flow.id}
                onClick={() => run(flow)}
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
                    <span className="block text-[16.5px] font-semibold text-ink">{flow.title}</span>
                    <span className="mt-0.5 block text-[13.5px] leading-snug text-ink-muted">
                      {flow.blurb}
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

        <SectionTitle>Say something else</SectionTitle>
        <Card className="p-5">
          <textarea
            value={custom}
            onChange={(e) => setCustom(e.target.value)}
            rows={3}
            placeholder="Type anything and I will read it out…"
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
              Clear
            </button>
            <button
              onClick={speakCustom}
              disabled={!custom.trim()}
              className="h-12 flex-[1.4] rounded-full bg-ink text-[15px] font-semibold text-white disabled:opacity-35"
            >
              {active === 'custom' ? 'Stop' : 'Read aloud'}
            </button>
          </div>
        </Card>
      </div>
    </Screen>
  )
}
