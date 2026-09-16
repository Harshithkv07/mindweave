import Blob from './Blob'
import { Card } from './ui'
import { Back } from './Icons'

/* Shared furniture for the three activities. */

export function GameTop({ onBack, title, tier }) {
  return (
    <div className="flex items-center justify-between pt-3">
      <button onClick={onBack} className="ring-btn text-ink" aria-label="Leave activity">
        <Back size={21} />
      </button>
      <span className="text-[15px] font-semibold text-ink-soft">{title}</span>
      <span className="grid h-[46px] min-w-[46px] place-items-center rounded-full bg-white px-3 text-[12.5px] font-semibold text-mint-600 shadow-[0_6px_18px_-8px_rgba(26,78,88,0.4)]">
        {tier}
      </span>
    </div>
  )
}

export function LiveStats({ items }) {
  return (
    <div className="mt-4 grid grid-cols-3 gap-3">
      {items.map((it) => (
        <Card key={it.label} className="px-2 py-3 text-center">
          <p className="display text-[23px] text-ink">{it.value}</p>
          <p className="mt-0.5 text-[12px] font-medium text-ink-muted">{it.label}</p>
        </Card>
      ))}
    </div>
  )
}

export function Prompt({ children, sub }) {
  return (
    <div className="mt-6 text-center">
      <h2 className="display text-[28px] leading-[1.14] text-ink">{children}</h2>
      {sub ? <p className="mt-2 text-[14.5px] text-ink-muted">{sub}</p> : null}
    </div>
  )
}

export function ResultSheet({ open, result, onAgain, onDone }) {
  if (!open) return null

  const { accuracy, seconds, errors, difficulty } = result
  const warm = accuracy >= 75

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-ink/35 px-4 pb-4 backdrop-blur-sm fade">
      <div
        className="glass-solid w-full max-w-[430px] rounded-[34px] px-7 pb-7 pt-8 text-center"
        style={{ animation: 'mw-rise .45s cubic-bezier(.2,.8,.3,1) both' }}
        role="dialog"
        aria-modal="true"
      >
        <div className="flex justify-center">
          <Blob mood={warm ? 'happy' : 'calm'} size={120} drift={false} />
        </div>

        <h2 className="display mt-4 text-[30px] text-ink">
          {warm ? 'Beautifully done' : 'That was a good try'}
        </h2>
        <p className="mt-2 text-[14.5px] leading-relaxed text-ink-muted">
          {warm
            ? 'That sat comfortably above your usual pattern.'
            : 'Every attempt counts — this one is saved too.'}
        </p>

        <div className="mt-6 grid grid-cols-3 gap-3">
          <Figure value={`${Math.round(accuracy)}%`} label="Accuracy" />
          <Figure value={`${seconds}s`} label="Time" />
          <Figure value={errors} label="Missteps" />
        </div>

        <p className="mt-4 text-[12.5px] font-medium text-ink-faint">
          Played at {difficulty} · saved to your progress
        </p>

        <button onClick={onAgain} className="pill-cta mt-7">
          Play again
        </button>
        <button
          onClick={onDone}
          className="mx-auto mt-3 block px-6 py-3 text-[15px] font-medium text-ink-soft"
        >
          Finish for now
        </button>
      </div>
    </div>
  )
}

function Figure({ value, label }) {
  return (
    <div className="rounded-[20px] bg-white/70 px-2 py-4">
      <p className="display text-[24px] text-ink">{value}</p>
      <p className="mt-0.5 text-[11.5px] font-medium text-ink-muted">{label}</p>
    </div>
  )
}
