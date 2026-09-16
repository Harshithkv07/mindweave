import { Home, Grid, Wave, Chart, Compass } from './Icons'

/* The floating dark pill, with the companion button riding outside it. */

const TABS = [
  { id: 'home', label: 'Home', Icon: Home },
  { id: 'games', label: 'Activities', Icon: Grid },
  { id: 'voice', label: 'Voice', Icon: Wave },
  { id: 'progress', label: 'Progress', Icon: Chart },
]

export default function BottomNav({ active, onNavigate, onCompanion }) {
  return (
    <div
      className="pointer-events-none fixed inset-x-0 bottom-0 z-40 flex justify-center"
      style={{ paddingBottom: 'max(16px, env(safe-area-inset-bottom))' }}
    >
      <div className="pointer-events-auto flex w-full max-w-[430px] items-center justify-center gap-3 px-5">
        <nav
          className="flex items-center gap-1 rounded-full bg-ink/92 p-[7px] shadow-[0_18px_40px_-16px_rgba(16,20,24,0.85)] backdrop-blur-xl"
          aria-label="Main"
        >
          {TABS.map(({ id, label, Icon }) => {
            const on = active === id
            return (
              <button
                key={id}
                onClick={() => onNavigate(id)}
                aria-label={label}
                aria-current={on ? 'page' : undefined}
                className={`grid h-[50px] w-[50px] place-items-center rounded-full transition-all duration-300 ${
                  on ? 'bg-white text-ink' : 'text-white/65 active:text-white'
                }`}
              >
                <Icon size={22} />
              </button>
            )
          })}
        </nav>

        <button
          onClick={onCompanion}
          aria-label="Mood check-in"
          className="ring-btn h-[56px] w-[56px] shrink-0 ring-2 ring-sky-500 text-sky-600"
        >
          <Compass size={24} />
        </button>
      </div>
    </div>
  )
}
