import { useStore, GAME_LABEL, DOMAIN_LABEL } from '../lib/store'
import { insight } from '../lib/adaptive'
import TrendChart from '../components/TrendChart'
import {
  Screen, TopBar, RingButton, Display, Muted, Card, Meter, SectionTitle, Meta, Empty,
} from '../components/ui'
import { Chart, Spark } from '../components/Icons'

const TONE = { memory: 'sky', attention: 'mint', pattern: 'sky', routine: 'warm' }
const ICON = { match: '🃏', objects: '🧩', sequence: '🔢' }

export default function Progress({ onBack }) {
  const s = useStore()

  return (
    <Screen>
      <div className="pb-36">
        <TopBar
          onBack={onBack}
          right={
            <RingButton tone="mint" label="Progress">
              <Chart size={21} />
            </RingButton>
          }
        />

        <div className="mt-3">
          <Display className="text-[34px]">How you&rsquo;re doing</Display>
          <Muted className="mt-3 max-w-[320px]">
            Measured against your own pattern over time — never against anybody else.
          </Muted>
        </div>

        {/* headline figures */}
        <div className="mt-6 grid grid-cols-2 gap-3.5">
          <Figure value={s.played} label="Sessions" />
          <Figure value={s.bestAccuracy ? `${Math.round(s.bestAccuracy)}%` : '—'} label="Best accuracy" />
          <Figure value={s.bestTime ? `${s.bestTime}s` : '—'} label="Quickest round" />
          <Figure value={s.totalErrors} label="Missteps" />
        </div>

        {/* insight */}
        <Card variant="glass-solid" className="mt-4 flex items-start gap-4 p-6">
          <span className="grid h-11 w-11 shrink-0 place-items-center rounded-full bg-mint-100 text-mint-600">
            <Spark size={21} />
          </span>
          <div>
            <p className="text-[15.5px] leading-[1.55] text-ink-soft">{insight(s.sessions)}</p>
            <p className="mt-2 text-[12px] text-ink-faint">
              A personal, longitudinal reading — not a diagnosis.
            </p>
          </div>
        </Card>

        {/* trend */}
        <SectionTitle aside={`${Math.min(7, s.sessions.length)} recent`}>Accuracy trend</SectionTitle>
        <Card className="px-3 py-5">
          <TrendChart sessions={s.sessions} />
        </Card>

        {/* domains */}
        <SectionTitle aside={`baseline ${Math.round(s.baseline)}%`}>Four domains</SectionTitle>
        <Card variant="glass-solid" className="space-y-5 p-6">
          {Object.entries(s.domains).map(([key, value]) => (
            <div key={key}>
              <div className="mb-2 flex items-baseline justify-between">
                <span className="text-[15px] font-medium text-ink">{DOMAIN_LABEL[key]}</span>
                <span className="display text-[19px] text-ink-soft">{Math.round(value)}</span>
              </div>
              <Meter value={value} tone={TONE[key]} />
            </div>
          ))}
        </Card>

        {/* history */}
        <SectionTitle>Recent sessions</SectionTitle>
        {s.sessions.length ? (
          <Card className="overflow-hidden">
            {s.sessions.slice(0, 8).map((x, i) => (
              <div
                key={x.id}
                className={`flex items-center gap-4 px-5 py-4 ${i ? 'border-t border-white/70' : ''}`}
              >
                <span className="grid h-11 w-11 shrink-0 place-items-center rounded-full bg-white/80 text-[20px]">
                  {ICON[x.game]}
                </span>
                <div className="min-w-0 flex-1">
                  <p className="truncate text-[15.5px] font-medium text-ink">{GAME_LABEL[x.game]}</p>
                  <Meta>
                    {new Date(x.at).toLocaleDateString('en-US', { day: 'numeric', month: 'short' })}
                    {' · '}
                    {x.seconds}s · {x.errors} missteps · {x.difficulty}
                  </Meta>
                </div>
                <span
                  className={`display text-[21px] ${x.accuracy >= 70 ? 'text-mint-600' : 'text-[#c4761f]'}`}
                >
                  {Math.round(x.accuracy)}%
                </span>
              </div>
            ))}
          </Card>
        ) : (
          <Empty icon="🌱">
            No sessions yet. Try one activity and the first reading will appear here.
          </Empty>
        )}
      </div>
    </Screen>
  )
}

function Figure({ value, label }) {
  return (
    <Card className="px-5 py-5">
      <p className="display text-[32px] text-ink">{value}</p>
      <p className="mt-1 text-[13px] font-medium text-ink-muted">{label}</p>
    </Card>
  )
}
