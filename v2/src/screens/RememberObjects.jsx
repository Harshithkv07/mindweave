import { useEffect, useMemo, useState } from 'react'
import { useStore } from '../lib/store'
import { useT } from '../lib/i18n'
import { objectsConfig, shuffle, OBJECTS } from '../lib/adaptive'
import { Screen, Card } from '../components/ui'
import { GameTop, LiveStats, Prompt, ResultSheet } from '../components/GameChrome'

/* Remember Objects — study a small set, then pick them out of a larger grid. */

export default function RememberObjects({ onBack }) {
  const store = useStore()
  const { t } = useT()
  const cfg = useMemo(() => objectsConfig(store.sessions), [])

  const [round, setRound] = useState(() => build(cfg))
  const [phase, setPhase] = useState('study') // study | recall
  const [countdown, setCountdown] = useState(cfg.showSeconds)
  const [picked, setPicked] = useState([])
  const [wrong, setWrong] = useState([])
  const [startedAt, setStartedAt] = useState(() => Date.now())
  const [result, setResult] = useState(null)

  /* study countdown */
  useEffect(() => {
    if (phase !== 'study') return
    if (countdown <= 0) {
      setPhase('recall')
      setStartedAt(Date.now())
      return
    }
    const t = setTimeout(() => setCountdown((c) => c - 1), 1000)
    return () => clearTimeout(t)
  }, [phase, countdown])

  const correctPicks = picked.filter((n) => round.target.some((o) => o.name === n))
  const finished = correctPicks.length === cfg.remember

  useEffect(() => {
    if (!finished || result) return
    const seconds = Math.max(1, Math.floor((Date.now() - startedAt) / 1000))
    const attempts = picked.length
    const accuracy = Math.max(0, Math.min(100, (cfg.remember / Math.max(cfg.remember, attempts)) * 100))
    const payload = { accuracy, seconds, errors: wrong.length, attempts, difficulty: cfg.tier }
    store.recordSession({ game: 'objects', ...payload })
    const id = setTimeout(() => setResult(payload), 560)
    return () => clearTimeout(id)
  }, [finished]) // eslint-disable-line react-hooks/exhaustive-deps

  const pick = (o) => {
    if (phase !== 'recall' || picked.includes(o.name)) return
    setPicked((p) => [...p, o.name])
    if (!round.target.some((t) => t.name === o.name)) setWrong((w) => [...w, o.name])
  }

  const replay = () => {
    const next = build(cfg)
    setRound(next)
    setPhase('study')
    setCountdown(cfg.showSeconds)
    setPicked([])
    setWrong([])
    setResult(null)
    setStartedAt(Date.now())
  }

  return (
    <Screen>
      <div className="pb-12">
        <GameTop onBack={onBack} game="objects" tier={cfg.tier} />

        <LiveStats
          items={[
            { label: t('play.found'), value: `${correctPicks.length}/${cfg.remember}` },
            { label: t('play.missteps'), value: wrong.length },
            {
              label: phase === 'study' ? t('play.look') : t('play.phase'),
              value: phase === 'study' ? `${countdown}s` : t('play.phaseRecall'),
            },
          ]}
        />

        {phase === 'study' ? (
          <>
            <Prompt sub={t('play.objectsStudySub', { count: countdown })}>
              {t('play.objectsStudy')}
            </Prompt>

            <div className="mt-8 flex flex-wrap justify-center gap-4">
              {round.target.map((o, i) => (
                <Card
                  key={o.name}
                  variant="glass-solid"
                  className="grid min-h-[112px] w-[112px] place-items-center px-1 py-2 pop"
                  style={{ animationDelay: `${i * 90}ms` }}
                >
                  <span className="text-[44px] leading-none">{o.icon}</span>
                  <span className="mt-1 px-1 text-center text-[12.5px] font-medium leading-tight text-ink-muted">
                    {t(`object.${o.name}`)}
                  </span>
                </Card>
              ))}
            </div>

            <div className="mx-auto mt-9 h-[6px] w-[190px] overflow-hidden rounded-full bg-black/8">
              <div
                className="h-full rounded-full bg-gradient-to-r from-sky-400 to-mint-500 transition-[width] duration-1000 ease-linear"
                style={{ width: `${(countdown / cfg.showSeconds) * 100}%` }}
              />
            </div>
          </>
        ) : (
          <>
            <Prompt sub={t('play.objectsRecallSub')}>{t('play.objectsRecall')}</Prompt>

            <div className="mt-7 grid grid-cols-3 gap-3.5">
              {round.options.map((o) => {
                const chosen = picked.includes(o.name)
                const isTarget = round.target.some((t) => t.name === o.name)
                const tone = !chosen
                  ? 'glass'
                  : isTarget
                    ? 'border border-mint-400 bg-mint-100'
                    : 'border border-[#eec4c2] bg-[#fdeceb] opacity-60'
                return (
                  <button
                    key={o.name}
                    onClick={() => pick(o)}
                    disabled={chosen}
                    aria-label={t(`object.${o.name}`)}
                    className={`grid aspect-square place-items-center rounded-[24px] transition-all duration-300 active:scale-95 ${tone}`}
                  >
                    <span className="text-[34px] leading-none">{o.icon}</span>
                    <span className="mt-1 px-1 text-center text-[11.5px] font-medium leading-tight text-ink-muted">
                      {t(`object.${o.name}`)}
                    </span>
                  </button>
                )
              })}
            </div>
          </>
        )}
      </div>

      <ResultSheet open={Boolean(result)} result={result ?? {}} onAgain={replay} onDone={onBack} />
    </Screen>
  )
}

function build(cfg) {
  const pool = shuffle(OBJECTS)
  const target = pool.slice(0, cfg.remember)
  const fillers = pool.slice(cfg.remember, cfg.options)
  return { target, options: shuffle([...target, ...fillers]) }
}
