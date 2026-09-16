import { useCallback, useEffect, useMemo, useRef, useState } from 'react'
import { useStore } from '../lib/store'
import { useT } from '../lib/i18n'
import { sequenceConfig, SYMBOLS } from '../lib/adaptive'
import { Screen } from '../components/ui'
import { GameTop, LiveStats, Prompt, ResultSheet } from '../components/GameChrome'

/* Sequence Memory — shapes light up in order, the player repeats it back. */

export default function SequenceMemory({ onBack }) {
  const store = useStore()
  const { t } = useT()
  const cfg = useMemo(() => sequenceConfig(store.sessions), [])
  const pool = useMemo(() => SYMBOLS.slice(0, cfg.pool), [cfg.pool])

  const [level, setLevel] = useState(1)
  const [sequence, setSequence] = useState([])
  const [lit, setLit] = useState(null)
  const [phase, setPhase] = useState('watch') // watch | repeat | wrong
  const [step, setStep] = useState(0)
  const [errors, setErrors] = useState(0)
  const [taps, setTaps] = useState(0)
  const [startedAt] = useState(() => Date.now())
  const [result, setResult] = useState(null)
  const timers = useRef([])

  const clearTimers = () => {
    timers.current.forEach(clearTimeout)
    timers.current = []
  }

  const play = useCallback(
    (seq) => {
      setPhase('watch')
      setStep(0)
      clearTimers()
      seq.forEach((idx, i) => {
        timers.current.push(setTimeout(() => setLit(idx), cfg.flashMs * (i + 1)))
        timers.current.push(
          setTimeout(() => setLit(null), cfg.flashMs * (i + 1) + cfg.flashMs * 0.55),
        )
      })
      timers.current.push(
        setTimeout(() => setPhase('repeat'), cfg.flashMs * (seq.length + 1) + 180),
      )
    },
    [cfg.flashMs],
  )

  /* build and play each new level */
  useEffect(() => {
    const length = cfg.startLength + (level - 1)
    const seq = Array.from({ length }, () => Math.floor(Math.random() * pool.length))
    setSequence(seq)
    play(seq)
    return clearTimers
  }, [level, cfg.startLength, pool.length, play])

  const finish = (finalErrors) => {
    const seconds = Math.max(1, Math.floor((Date.now() - startedAt) / 1000))
    const reached = level - 1
    const accuracy = Math.max(
      0,
      Math.min(100, taps ? ((taps - finalErrors) / taps) * 100 : 0),
    )
    const payload = {
      accuracy,
      seconds,
      errors: finalErrors,
      attempts: Math.max(1, taps),
      difficulty: cfg.tier,
      reached,
    }
    store.recordSession({ game: 'sequence', ...payload })
    setResult(payload)
  }

  const tap = (idx) => {
    if (phase !== 'repeat') return
    setTaps((t) => t + 1)

    if (sequence[step] === idx) {
      setLit(idx)
      setTimeout(() => setLit(null), 190)

      if (step + 1 === sequence.length) {
        setPhase('watch')
        setTimeout(() => setLevel((l) => l + 1), 700)
      } else {
        setStep((s) => s + 1)
      }
      return
    }

    const next = errors + 1
    setErrors(next)
    setPhase('wrong')
    setTimeout(() => finish(next), 750)
  }

  const replay = () => {
    clearTimers()
    setLevel(1)
    setErrors(0)
    setTaps(0)
    setStep(0)
    setResult(null)
    setPhase('watch')
  }

  const label = {
    watch: t('play.seqWatch'),
    repeat: t('play.seqYourTurn'),
    wrong: t('play.seqWrong'),
  }[phase]

  return (
    <Screen>
      <div className="pb-12">
        <GameTop onBack={onBack} game="sequence" tier={cfg.tier} />

        <LiveStats
          items={[
            { label: t('play.level'), value: level },
            { label: t('play.length'), value: sequence.length },
            { label: t('play.step'), value: phase === 'repeat' ? `${step}/${sequence.length}` : '—' },
          ]}
        />

        <Prompt
          sub={
            phase === 'watch'
              ? t('play.seqWatchSub')
              : phase === 'repeat'
                ? t('play.seqTurnSub')
                : t('play.seqWrongSub')
          }
        >
          {label}
        </Prompt>

        {/* progress pips for the current sequence */}
        <div className="mt-6 flex justify-center gap-2">
          {sequence.map((_, i) => (
            <span
              key={i}
              className={`h-2 rounded-full transition-all duration-300 ${
                phase === 'repeat' && i < step ? 'w-7 bg-mint-500' : 'w-2 bg-black/12'
              }`}
            />
          ))}
        </div>

        <div
          className="mx-auto mt-8 grid gap-3.5"
          style={{
            gridTemplateColumns: `repeat(${cfg.cols}, minmax(0,1fr))`,
            maxWidth: cfg.cols === 2 ? 290 : 350,
          }}
        >
          {pool.map((sym, i) => {
            const on = lit === i
            return (
              <button
                key={sym}
                onClick={() => tap(i)}
                disabled={phase !== 'repeat'}
                aria-label={t('play.shape', { n: i + 1 })}
                className={`grid aspect-square place-items-center rounded-[26px] transition-all duration-200 ${
                  on
                    ? 'scale-[1.06] border border-sky-300 bg-white shadow-[0_0_0_6px_rgba(98,191,230,0.25),0_16px_34px_-16px_rgba(26,78,88,0.7)]'
                    : 'glass active:scale-95'
                } ${phase === 'repeat' ? '' : 'opacity-85'}`}
              >
                <span className={`leading-none transition-transform duration-200 ${on ? 'scale-110' : ''}`}
                  style={{ fontSize: cfg.cols === 2 ? 44 : 34 }}
                >
                  {sym}
                </span>
              </button>
            )
          })}
        </div>
      </div>

      <ResultSheet open={Boolean(result)} result={result ?? {}} onAgain={replay} onDone={onBack} />
    </Screen>
  )
}
