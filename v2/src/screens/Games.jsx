import { useStore, GAME_LABEL } from '../lib/store'
import { matchConfig, objectsConfig, sequenceConfig } from '../lib/adaptive'
import { Screen, Card, Tappable, Tag } from '../components/ui'
import { Back, Bell, Search } from '../components/Icons'

/* The activity hub, on the deep mint wash — the "Reflections" panel. */

const COPY = {
  match: {
    question: 'Which two belong together?',
    blurb: 'Turn the cards over and find the pairs. Nothing disappears if you are slow.',
    tags: ['memory', 'pairs', 'gentle'],
  },
  objects: {
    question: 'What did you just see?',
    blurb: 'A handful of everyday objects appear, then you pick them out again.',
    tags: ['recall', 'attention', 'everyday'],
  },
  sequence: {
    question: 'Can you follow the order?',
    blurb: 'Shapes light up one by one. Repeat the order back, and it grows a little.',
    tags: ['sequence', 'focus', 'rhythm'],
  },
}

export default function Games({ onBack, onPlay }) {
  const s = useStore()

  const configs = {
    match: matchConfig(s.sessions),
    objects: objectsConfig(s.sessions),
    sequence: sequenceConfig(s.sessions),
  }

  return (
    <Screen wash="wash-deep">
      <div className="pb-36">
        <div className="flex items-center justify-between pt-3">
          <button onClick={onBack} className="ring-btn bg-white/22 text-white" aria-label="Go back">
            <Back size={21} />
          </button>
          <button className="ring-btn bg-white/22 text-white" aria-label="Find an activity">
            <Search size={20} />
          </button>
        </div>

        <div className="mt-7 text-center fade">
          <h1 className="display text-[40px] text-white">Activities</h1>
          <p className="mt-2 text-[14.5px] text-white/80">
            Chosen to match how you have been doing
          </p>
        </div>

        <div className="mt-8 space-y-5">
          {Object.entries(COPY).map(([id, c], i) => {
            const cfg = configs[id]
            const played = s.sessions.filter((x) => x.game === id).length
            return (
              <Tappable
                key={id}
                onClick={() => onPlay(id)}
                className="block w-full rise"
                style={{ animationDelay: `${i * 110}ms` }}
              >
                <Card variant="glass-solid" className="bg-white/94 p-7">
                  <div className="flex items-center justify-between">
                    <span className="text-[13px] font-semibold uppercase tracking-[0.08em] text-mint-600">
                      {GAME_LABEL[id]}
                    </span>
                    <span className="rounded-full bg-mint-100 px-3 py-1 text-[12px] font-semibold text-mint-700">
                      {cfg.tier}
                    </span>
                  </div>

                  <p className="display mt-4 text-[27px] leading-[1.14] text-ink">
                    {c.question}
                  </p>

                  <p className="mt-3 text-[14.5px] leading-[1.5] text-ink-muted">{c.blurb}</p>

                  <div className="mt-5 flex flex-wrap gap-2">
                    {c.tags.map((t) => (
                      <Tag key={t}>{t}</Tag>
                    ))}
                  </div>

                  <p className="mt-5 text-[12.5px] font-medium text-ink-faint">
                    {played ? `${played} session${played > 1 ? 's' : ''} so far` : 'Not tried yet'}
                    {' · '}
                    {describe(id, cfg)}
                  </p>
                </Card>
              </Tappable>
            )
          })}
        </div>

        <div className="mt-8 flex items-start gap-3 rounded-[24px] bg-white/18 p-5 backdrop-blur-md">
          <Bell size={19} className="mt-0.5 shrink-0 text-white/85" />
          <p className="text-[13.5px] leading-[1.5] text-white/85">
            Difficulty moves on its own, based on your last few sessions. There is no
            score to chase and no way to fail.
          </p>
        </div>
      </div>
    </Screen>
  )
}

function describe(id, cfg) {
  if (id === 'match') return `${cfg.pairs} pairs`
  if (id === 'objects') return `${cfg.remember} objects, ${cfg.showSeconds}s`
  return `starts at ${cfg.startLength}`
}
