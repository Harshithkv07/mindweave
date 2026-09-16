/* Rounded stroke icons, drawn inline so the app ships with no icon dependency. */

const base = {
  fill: 'none',
  stroke: 'currentColor',
  strokeWidth: 1.8,
  strokeLinecap: 'round',
  strokeLinejoin: 'round',
}

const Svg = ({ children, size = 22, ...rest }) => (
  <svg viewBox="0 0 24 24" width={size} height={size} {...base} {...rest}>
    {children}
  </svg>
)

export const Back = (p) => (
  <Svg {...p}>
    <path d="M15 5l-7 7 7 7" />
  </Svg>
)

export const Heart = (p) => (
  <Svg {...p}>
    <path d="M12 20s-7-4.4-7-9.2A4 4 0 0112 8.6 4 4 0 0119 10.8C19 15.6 12 20 12 20z" />
  </Svg>
)

export const Compass = (p) => (
  <Svg {...p}>
    <circle cx="12" cy="12" r="8.5" />
    <path d="M14.8 9.2l-1.6 4-4 1.6 1.6-4z" />
  </Svg>
)

export const Home = (p) => (
  <Svg {...p}>
    <path d="M4 10.5L12 4l8 6.5V19a1.5 1.5 0 01-1.5 1.5h-13A1.5 1.5 0 014 19z" />
  </Svg>
)

export const Grid = (p) => (
  <Svg {...p}>
    <rect x="4" y="4" width="7" height="7" rx="2.2" />
    <rect x="13" y="4" width="7" height="7" rx="2.2" />
    <rect x="4" y="13" width="7" height="7" rx="2.2" />
    <rect x="13" y="13" width="7" height="7" rx="2.2" />
  </Svg>
)

export const Chart = (p) => (
  <Svg {...p}>
    <path d="M4 19h16" />
    <path d="M7 19v-5" />
    <path d="M12 19V7" />
    <path d="M17 19v-8" />
  </Svg>
)

export const Wave = (p) => (
  <Svg {...p}>
    <path d="M4 12h1.6M8 7.5v9M11.6 5v14M15.2 9v6M18.8 11.5h1.2" />
  </Svg>
)

export const Bell = (p) => (
  <Svg {...p}>
    <path d="M18 15.5V11a6 6 0 10-12 0v4.5L4.5 18h15z" />
    <path d="M10 20.5a2 2 0 004 0" />
  </Svg>
)

export const User = (p) => (
  <Svg {...p}>
    <circle cx="12" cy="8.5" r="3.6" />
    <path d="M5 20c.9-3.6 3.6-5.4 7-5.4s6.1 1.8 7 5.4" />
  </Svg>
)

export const Shield = (p) => (
  <Svg {...p}>
    <path d="M12 3.5l7 2.6v5.4c0 4.3-2.9 7.6-7 9.1-4.1-1.5-7-4.8-7-9.1V6.1z" />
    <path d="M9.2 12.1l2 2 3.6-3.8" />
  </Svg>
)

export const Drop = (p) => (
  <Svg {...p}>
    <path d="M12 3.5s5.5 5.9 5.5 9.6a5.5 5.5 0 11-11 0C6.5 9.4 12 3.5 12 3.5z" />
  </Svg>
)

export const Pill = (p) => (
  <Svg {...p}>
    <rect x="3" y="8.5" width="18" height="7" rx="3.5" transform="rotate(-38 12 12)" />
    <path d="M9.2 7.6l5.6 5.6" />
  </Svg>
)

export const Spark = (p) => (
  <Svg {...p}>
    <path d="M12 3.5l1.9 4.9 4.9 1.9-4.9 1.9L12 17.1l-1.9-4.9L5.2 10.3l4.9-1.9z" />
    <path d="M18.5 16.5l.8 2 2 .8-2 .8-.8 2-.8-2-2-.8 2-.8z" />
  </Svg>
)

export const Check = (p) => (
  <Svg {...p}>
    <path d="M5 12.5l4.5 4.5L19 7.5" />
  </Svg>
)

export const Plus = (p) => (
  <Svg {...p}>
    <path d="M12 5.5v13M5.5 12h13" />
  </Svg>
)

export const Minus = (p) => (
  <Svg {...p}>
    <path d="M5.5 12h13" />
  </Svg>
)

export const Play = (p) => (
  <Svg {...p}>
    <path d="M8 5.6l10 6.4-10 6.4z" />
  </Svg>
)

export const Stop = (p) => (
  <Svg {...p}>
    <rect x="6.5" y="6.5" width="11" height="11" rx="2.6" />
  </Svg>
)

export const Clock = (p) => (
  <Svg {...p}>
    <circle cx="12" cy="12" r="8.5" />
    <path d="M12 7.5V12l3 1.8" />
  </Svg>
)

export const Walk = (p) => (
  <Svg {...p}>
    <circle cx="13" cy="4.8" r="1.8" />
    <path d="M11 20l1.4-5.2-2.4-2.2.9-4.1 2.6.9 1.9 2.6 2.3.8" />
    <path d="M9.4 12.4L7 15.2 6 20" />
  </Svg>
)

export const Brain = (p) => (
  <Svg {...p}>
    <path d="M12 5.2a2.7 2.7 0 00-5 1.4 2.6 2.6 0 00-1.3 4.5A2.8 2.8 0 007 16a2.7 2.7 0 005 .8z" />
    <path d="M12 5.2a2.7 2.7 0 015 1.4 2.6 2.6 0 011.3 4.5A2.8 2.8 0 0117 16a2.7 2.7 0 01-5 .8z" />
    <path d="M12 5.2v11.6" />
  </Svg>
)

export const Trash = (p) => (
  <Svg {...p}>
    <path d="M5 7h14M10 7V5.5A1.5 1.5 0 0111.5 4h1A1.5 1.5 0 0114 5.5V7" />
    <path d="M6.5 7l.8 12A1.5 1.5 0 008.8 20.4h6.4a1.5 1.5 0 001.5-1.4l.8-12" />
  </Svg>
)

export const Undo = (p) => (
  <Svg {...p}>
    <path d="M4 9h9.5a5 5 0 110 10H9" />
    <path d="M7.5 5.5L4 9l3.5 3.5" />
  </Svg>
)

export const Search = (p) => (
  <Svg {...p}>
    <circle cx="11" cy="11" r="6.5" />
    <path d="M16 16l4 4" />
  </Svg>
)
