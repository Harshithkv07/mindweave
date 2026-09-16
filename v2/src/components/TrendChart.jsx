import { useId } from 'react'

/* ==========================================================================
   Accuracy trend — hand-drawn SVG so it inherits the glass palette exactly
   and stays legible at senior-friendly type sizes.
   ========================================================================== */

export default function TrendChart({ sessions, height = 190 }) {
  const gid = useId().replace(/:/g, '')
  const points = sessions.slice(0, 7).reverse()

  if (points.length < 2) {
    return (
      <div className="grid h-[190px] place-items-center rounded-[22px] bg-white/45 text-center">
        <p className="px-8 text-[14.5px] leading-relaxed text-ink-muted">
          Two or more sessions are needed before a trend can be drawn.
        </p>
      </div>
    )
  }

  const W = 340
  const H = height
  const padX = 30
  const padTop = 16
  const padBottom = 34
  const plotW = W - padX * 2
  const plotH = H - padTop - padBottom

  const x = (i) => padX + (i * plotW) / (points.length - 1)
  const y = (v) => padTop + plotH - (Math.max(0, Math.min(100, v)) / 100) * plotH

  const line = points.map((p, i) => `${i === 0 ? 'M' : 'L'}${x(i).toFixed(1)},${y(p.accuracy).toFixed(1)}`).join(' ')
  const area = `${line} L${x(points.length - 1).toFixed(1)},${padTop + plotH} L${padX},${padTop + plotH} Z`
  const baselineY = y(75)

  return (
    <svg viewBox={`0 0 ${W} ${H}`} className="w-full" role="img" aria-label="Accuracy across recent sessions">
      <defs>
        <linearGradient id={`fill-${gid}`} x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor="#3dbe8b" stopOpacity="0.30" />
          <stop offset="100%" stopColor="#3dbe8b" stopOpacity="0" />
        </linearGradient>
        <linearGradient id={`stroke-${gid}`} x1="0" y1="0" x2="1" y2="0">
          <stop offset="0%" stopColor="#62bfe6" />
          <stop offset="100%" stopColor="#3dbe8b" />
        </linearGradient>
      </defs>

      {/* horizontal guides */}
      {[0, 25, 50, 75, 100].map((v) => (
        <g key={v}>
          <line x1={padX} x2={W - padX} y1={y(v)} y2={y(v)} stroke="#101418" strokeOpacity="0.07" strokeWidth="1" />
          <text x={padX - 8} y={y(v) + 4} textAnchor="end" fontSize="11" fill="#a8b1b9" fontWeight="500">
            {v}
          </text>
        </g>
      ))}

      {/* the 75% personal baseline reference */}
      <line
        x1={padX}
        x2={W - padX}
        y1={baselineY}
        y2={baselineY}
        stroke="#2fa574"
        strokeWidth="1.4"
        strokeDasharray="5 5"
        strokeOpacity="0.55"
      />

      <path d={area} fill={`url(#fill-${gid})`} />
      <path
        d={line}
        fill="none"
        stroke={`url(#stroke-${gid})`}
        strokeWidth="3"
        strokeLinecap="round"
        strokeLinejoin="round"
      />

      {points.map((p, i) => (
        <g key={p.id}>
          <circle cx={x(i)} cy={y(p.accuracy)} r="6.5" fill="#fff" />
          <circle cx={x(i)} cy={y(p.accuracy)} r="4" fill={p.accuracy >= 75 ? '#2fa574' : '#c4761f'} />
          <text
            x={x(i)}
            y={H - 12}
            textAnchor="middle"
            fontSize="11"
            fill="#a8b1b9"
            fontWeight="500"
          >
            {new Date(p.at).toLocaleDateString('en-US', { day: 'numeric', month: 'short' })}
          </text>
        </g>
      ))}
    </svg>
  )
}
