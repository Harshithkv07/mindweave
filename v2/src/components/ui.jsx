import { Back } from './Icons'
import { useT } from '../lib/i18n'

/* ==========================================================================
   Shared surfaces and controls.
   ========================================================================== */

export function Screen({ children, wash = 'wash', pad = true, className = '' }) {
  return (
    // 100dvh rather than a percentage: the ancestors are auto-height, so a
    // percentage min-height would collapse and leave the wash short of the fold.
    <div className={`min-h-[100dvh] ${wash} ${className}`}>
      <div
        className={`mx-auto w-full max-w-[430px] ${pad ? 'px-5' : ''}`}
        style={{ paddingTop: 'max(14px, env(safe-area-inset-top))' }}
      >
        {children}
      </div>
    </div>
  )
}

export function TopBar({ onBack, right, title }) {
  const { t } = useT()

  return (
    <div className="flex items-center justify-between pt-2 pb-1">
      {onBack ? (
        <button onClick={onBack} className="ring-btn text-ink" aria-label={t('common.back')}>
          <Back size={21} />
        </button>
      ) : (
        <span className="w-[46px]" />
      )}

      {title ? (
        <span className="text-[15px] font-semibold text-ink-soft">{title}</span>
      ) : (
        <span />
      )}

      {right ?? <span className="w-[46px]" />}
    </div>
  )
}

/* The white circle with a colored ring, top-right on most screens. */
export function RingButton({ children, tone = 'sky', onClick, label, active }) {
  const ring = tone === 'mint' ? 'ring-mint-500 text-mint-600' : 'ring-sky-500 text-sky-600'
  return (
    <button
      onClick={onClick}
      aria-label={label}
      aria-pressed={active}
      className={`ring-btn ring-2 ${ring}`}
    >
      {children}
    </button>
  )
}

export function Card({ children, className = '', variant = 'glass', ...rest }) {
  return (
    <div
      className={`${variant} rounded-[28px] ${className}`}
      {...rest}
    >
      {children}
    </div>
  )
}

export function Tappable({ children, className = '', ...rest }) {
  return (
    <button
      className={`text-left transition-transform duration-200 active:scale-[0.975] ${className}`}
      {...rest}
    >
      {children}
    </button>
  )
}

export function Display({ children, className = '' }) {
  return <h1 className={`display ${className}`}>{children}</h1>
}

export function Muted({ children, className = '' }) {
  return <p className={`text-[15px] leading-[1.55] text-ink-muted ${className}`}>{children}</p>
}

export function Meta({ children }) {
  return <span className="text-[12.5px] font-medium text-ink-faint">{children}</span>
}

/* Accessible toggle, 48px tall so it clears the senior touch-target floor. */
export function Toggle({ on, onChange, label }) {
  return (
    <button
      role="switch"
      aria-checked={on}
      aria-label={label}
      onClick={onChange}
      className="grid h-12 w-[62px] shrink-0 place-items-center"
    >
      <span
        className={`relative flex h-[32px] w-[56px] items-center rounded-full transition-colors duration-300 ${
          on ? 'bg-mint-500' : 'bg-black/12'
        }`}
      >
        <span
          className={`absolute h-[26px] w-[26px] rounded-full bg-white shadow-md transition-transform duration-300 ${
            on ? 'translate-x-[27px]' : 'translate-x-[3px]'
          }`}
        />
      </span>
    </button>
  )
}

/* A soft horizontal meter used for the cognitive domains. */
export function Meter({ value, tone = 'mint' }) {
  const bar =
    tone === 'sky'
      ? 'from-sky-400 to-sky-500'
      : tone === 'warm'
        ? 'from-[#f2c98a] to-[#dd9a4b]'
        : 'from-mint-400 to-mint-500'
  return (
    <div className="h-[10px] w-full overflow-hidden rounded-full bg-black/7">
      <div
        className={`h-full rounded-full bg-gradient-to-r ${bar} transition-[width] duration-700 ease-out`}
        style={{ width: `${Math.max(3, Math.min(100, value))}%` }}
      />
    </div>
  )
}

/* The thin gradient bar visualiser under the blob. */
export function Waveform({ active = false, bars = 26 }) {
  return (
    <div className="flex h-14 items-end justify-center gap-[3px]" aria-hidden="true">
      {Array.from({ length: bars }, (_, i) => {
        const mid = Math.abs(i - (bars - 1) / 2)
        const h = 8 + (1 - mid / (bars / 2)) ** 1.7 * 46
        return (
          <span
            key={i}
            className="w-[3px] origin-bottom rounded-full bg-gradient-to-t from-sky-500/15 to-sky-500"
            style={{
              height: `${Math.max(6, h)}px`,
              animation: active ? `mw-bars ${620 + (i % 5) * 130}ms ease-in-out ${i * 28}ms infinite` : 'none',
              opacity: active ? 1 : 0.5,
            }}
          />
        )
      })}
    </div>
  )
}

export function Tag({ children }) {
  return <span className="tag">{children}</span>
}

/* Renders a translated string that carries one <b>…</b> span.

   The alternative was splicing a bolded count into JSX around the text, which
   leaves translators with sentence fragments and no way to move the emphasis —
   and word order genuinely differs across the four languages here. */
export function Rich({ text, className = '' }) {
  const m = /^(.*?)<b>(.*?)<\/b>(.*)$/s.exec(text)
  if (!m) return <span className={className}>{text}</span>
  return (
    <span className={className}>
      {m[1]}
      <b className="font-semibold text-ink">{m[2]}</b>
      {m[3]}
    </span>
  )
}

/* `tone="light"` for sections sitting on a saturated wash, where the default
   ink-faint aside all but disappears. */
export function SectionTitle({ children, aside, tone = 'dark' }) {
  const light = tone === 'light'
  return (
    <div className="mb-3 mt-7 flex items-baseline justify-between">
      <h2
        className={`text-[19px] font-semibold tracking-[-0.01em] ${light ? 'text-white' : 'text-ink'}`}
      >
        {children}
      </h2>
      {aside ? (
        <span
          className={`text-[12.5px] font-medium ${light ? 'text-white/75' : 'text-ink-faint'}`}
        >
          {aside}
        </span>
      ) : null}
    </div>
  )
}

export function Empty({ icon, children }) {
  return (
    <Card className="px-6 py-9 text-center">
      <div className="mb-3 text-[34px]">{icon}</div>
      <Muted>{children}</Muted>
    </Card>
  )
}
