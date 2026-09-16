/* ==========================================================================
   Weave — the companion blob.

   A soft organic gradient shape that changes expression with the reported
   mood. It is the one piece of the interface that is purely emotional, and
   it doubles as a non-verbal state cue for someone who finds text tiring.
   ========================================================================== */

const SHAPE =
  'M163 18c34-9 74 2 96 27 23 26 21 54 33 79 12 24 38 42 38 72 0 32-31 50-58 64-28 14-52 26-82 26-31 0-58-9-86-22-28-14-57-31-61-62-4-32 20-55 30-84 11-30 7-66 31-85 17-14 39-11 59-15z'

const MOUTH = {
  happy: 'M128 196c11 16 29 25 48 25s37-9 48-25',
  calm: 'M136 202c9 8 22 12 36 12s27-4 36-12',
  anxious: 'M134 208c10-7 22-10 34-10s25 3 35 10',
  upset: 'M132 214c11-14 27-21 44-21s33 7 44 21',
  tired: 'M138 206h68',
}

const EYE = {
  happy: { rx: 15, ry: 17, y: 148 },
  calm: { rx: 15, ry: 7, y: 150 },
  anxious: { rx: 12, ry: 19, y: 146 },
  upset: { rx: 13, ry: 15, y: 150 },
  tired: { rx: 15, ry: 5, y: 152 },
}

export default function Blob({ mood = 'happy', size = 260, drift = true, className = '' }) {
  const eye = EYE[mood] ?? EYE.happy
  const mouth = MOUTH[mood] ?? MOUTH.happy
  const id = `blob-${mood}`

  return (
    <svg
      viewBox="0 0 352 300"
      width={size}
      height={size * (300 / 352)}
      className={`${drift ? 'drift' : ''} ${className}`}
      role="img"
      aria-label={`Companion looking ${mood}`}
    >
      <defs>
        <linearGradient id={id} x1="0" y1="0" x2="0.35" y2="1">
          <stop offset="0%" stopColor="#7cc9ee" />
          <stop offset="48%" stopColor="#9bd8ef" />
          <stop offset="100%" stopColor="#bfe7dd" />
        </linearGradient>
        <filter id={`${id}-soft`} x="-25%" y="-25%" width="150%" height="150%">
          <feGaussianBlur stdDeviation="14" result="b" />
          <feBlend in="SourceGraphic" in2="b" />
        </filter>
      </defs>

      {/* soft halo behind the body */}
      <path d={SHAPE} fill="#a9dcee" opacity="0.32" filter={`url(#${id}-soft)`} />

      <path d={SHAPE} fill={`url(#${id})`} />

      {/* a light sheen across the upper body */}
      <ellipse cx="140" cy="86" rx="66" ry="30" fill="#fff" opacity="0.2" />

      <ellipse cx="141" cy={eye.y} rx={eye.rx} ry={eye.ry} fill="#101418" />
      <ellipse cx="211" cy={eye.y} rx={eye.rx} ry={eye.ry} fill="#101418" />

      <path
        d={mouth}
        stroke="#101418"
        strokeWidth="9"
        strokeLinecap="round"
        fill="none"
      />
    </svg>
  )
}

export const MOODS = [
  { id: 'happy', label: 'Happy' },
  { id: 'calm', label: 'Calm' },
  { id: 'tired', label: 'Tired' },
  { id: 'anxious', label: 'Anxious' },
  { id: 'upset', label: 'Upset' },
]
