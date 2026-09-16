import { useEffect, useMemo, useRef, useState } from 'react'
import { useStore } from '../lib/store'
import { matchConfig, shuffle } from '../lib/adaptive'
import { Screen } from '../components/ui'
import { GameTop, LiveStats, Prompt, ResultSheet } from '../components/GameChrome'

/* Memory Match — turn cards, find pairs. Difficulty comes from the engine. */

export default function MemoryMatch({ onBack }) {
  const store = useStore()
  const cfg = useMemo(() => matchConfig(store.sessions), []) // frozen for this round

  const [cards, setCards] = useState(() => deal(cfg))
  const [open, setOpen] = useState([])
  const [matched, setMatched] = useState([])
  const [flips, setFlips] = useState(0)
  const [errors, setErrors] = useState(0)
  const [startedAt] = useState(() => Date.now())
  const [elapsed, setElapsed] = useState(0)
  const [result, setResult] = useState(null)
  const lock = useRef(false)

  useEffect(() => {
    if (result) return
    const t = setInterval(() => setElapsed(Math.floor((Date.now() - startedAt) / 1000)), 1000)
    return () => clearInterval(t)
  }, [result, startedAt])

  const done = matched.length === cards.length && cards.length > 0

  useEffect(() => {
    if (!done || result) return
    const seconds = Math.max(1, Math.floor((Date.now() - startedAt) / 1000))

    // Scored on a curve against a perfect run. A flat pairs/turns ratio punishes
    // the ordinary trial-and-error this game is built on — the square root keeps
    // a good-but-imperfect round in encouraging territory.
    const turns = Math.max(cfg.pairs, Math.floor(flips / 2))
    const accuracy = Math.max(0, Math.min(100, Math.sqrt(cfg.pairs / turns) * 100))
    const payload = { accuracy, seconds, errors, attempts: flips, difficulty: cfg.tier }
    store.recordSession({ game: 'match', ...payload })
    const id = setTimeout(() => setResult(payload), 620)
    return () => clearTimeout(id)
  }, [done]) // eslint-disable-line react-hooks/exhaustive-deps

  const tap = (i) => {
    if (lock.current || open.includes(i) || matched.includes(i)) return

    const next = [...open, i]
    setOpen(next)

    if (next.length < 2) return

    setFlips((f) => f + 2)
    lock.current = true

    const [a, b] = next
    if (cards[a].symbol === cards[b].symbol) {
      setTimeout(() => {
        setMatched((m) => [...m, a, b])
        setOpen([])
        lock.current = false
      }, 380)
    } else {
      setErrors((e) => e + 1)
      setTimeout(() => {
        setOpen([])
        lock.current = false
      }, cfg.flipBackMs)
    }
  }

  const replay = () => {
    setCards(deal(cfg))
    setOpen([])
    setMatched([])
    setFlips(0)
    setErrors(0)
    setElapsed(0)
    setResult(null)
    lock.current = false
  }

  return (
    <Screen>
      <div className="pb-12">
        <GameTop onBack={onBack} title="Memory Match" tier={cfg.tier} />

        <LiveStats
          items={[
            { label: 'Pairs found', value: `${matched.length / 2}/${cfg.pairs}` },
            { label: 'Turns', value: Math.floor(flips / 2) },
            { label: 'Time', value: `${elapsed}s` },
          ]}
        />

        <Prompt sub="Take as long as you like — nothing is timed against you.">
          Find the matching pairs
        </Prompt>

        <div
          className="mx-auto mt-7 grid gap-3.5"
          style={{
            gridTemplateColumns: `repeat(${cfg.cols}, minmax(0,1fr))`,
            maxWidth: cfg.cols === 2 ? 300 : 360,
          }}
        >
          {cards.map((c, i) => {
            const face = open.includes(i) || matched.includes(i)
            const gone = matched.includes(i)
            return (
              <button
                key={c.key}
                onClick={() => tap(i)}
                aria-label={face ? c.symbol : 'Hidden card'}
                className="relative aspect-square"
                style={{ perspective: '900px' }}
              >
                <span
                  className="absolute inset-0 transition-transform duration-500"
                  style={{
                    transformStyle: 'preserve-3d',
                    transform: face ? 'rotateY(180deg)' : 'none',
                  }}
                >
                  {/* back */}
                  <span
                    className="glass absolute inset-0 grid place-items-center rounded-[24px]"
                    style={{ backfaceVisibility: 'hidden' }}
                  >
                    <span className="h-3.5 w-3.5 rounded-full bg-sky-400/50" />
                  </span>

                  {/* face */}
                  <span
                    className={`absolute inset-0 grid place-items-center rounded-[24px] border transition-colors duration-300 ${
                      gone
                        ? 'border-mint-300 bg-mint-100'
                        : 'border-white/90 bg-white shadow-[0_12px_28px_-14px_rgba(26,78,88,0.5)]'
                    }`}
                    style={{ backfaceVisibility: 'hidden', transform: 'rotateY(180deg)' }}
                  >
                    <span className="text-[38px] leading-none">{c.symbol}</span>
                  </span>
                </span>
              </button>
            )
          })}
        </div>
      </div>

      <ResultSheet
        open={Boolean(result)}
        result={result ?? {}}
        onAgain={replay}
        onDone={onBack}
      />
    </Screen>
  )
}

function deal(cfg) {
  return shuffle(
    cfg.symbols.flatMap((symbol, i) => [
      { key: `${i}a`, symbol },
      { key: `${i}b`, symbol },
    ]),
  )
}
