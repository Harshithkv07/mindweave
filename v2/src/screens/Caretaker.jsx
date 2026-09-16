import { useState } from 'react'
import { useStore, GAME_LABEL, DOMAIN_LABEL } from '../lib/store'
import { insightKey, attentionAlerts } from '../lib/adaptive'
import en from '../lib/i18n/en.json'
import TrendChart from '../components/TrendChart'
import {
  Screen, Card, Meter, SectionTitle, Meta, Muted, Toggle,
} from '../components/ui'
import { Back, Bell, Drop, Pill, Plus, Undo, Spark, Check } from '../components/Icons'

/* The caretaker side: adherence, trend, alerts, session log.

   Deliberately English-only — the caregiver or clinician reading this is not
   assumed to share the patient's language. So it reads the English catalog
   directly rather than going through useT(). */

const enText = (key) => key.split('.').reduce((n, k) => n?.[k], en) ?? key

const FILTERS = [
  { id: 'all', label: 'All' },
  { id: 'match', label: 'Match' },
  { id: 'objects', label: 'Objects' },
  { id: 'sequence', label: 'Sequence' },
]

const WATER_TARGET = 8

export default function Caretaker({ onBack }) {
  const s = useStore()
  const [filter, setFilter] = useState('all')

  const filtered = filter === 'all' ? s.sessions : s.sessions.filter((x) => x.game === filter)
  const alerts = attentionAlerts(s.sessions)
  const meds = s.reminders.filter((r) => r.category === 'medication')
  const takenMeds = meds.filter((r) => s.today.taken.includes(r.id)).length
  const water = s.today.water

  return (
    <Screen wash="wash-sky">
      <div className="pb-16">
        <div className="flex items-center justify-between pt-3">
          <button onClick={onBack} className="ring-btn bg-white/25 text-white" aria-label="Go back">
            <Back size={21} />
          </button>
          <button className="ring-btn bg-white/25 text-white" aria-label="Alerts">
            <Bell size={20} />
          </button>
        </div>

        <div className="mt-6 text-center fade">
          <h1 className="display text-[38px] text-white">Care overview</h1>
          <p className="mt-2 text-[14.5px] text-white/85">
            {s.name} · updated just now
          </p>
        </div>

        {/* headline badges */}
        <div className="mt-7 grid grid-cols-3 gap-3">
          <Badge value={`${Math.round(s.baseline)}%`} label="Baseline" />
          <Badge value={s.played} label="Sessions" />
          <Badge value={s.avgAccuracy ? `${Math.round(s.avgAccuracy)}%` : '—'} label="Avg accuracy" />
        </div>

        {/* insight */}
        <Card variant="glass-solid" className="mt-4 flex items-start gap-4 p-6">
          <span className="grid h-11 w-11 shrink-0 place-items-center rounded-full bg-mint-100 text-mint-600">
            <Spark size={21} />
          </span>
          <div>
            <p className="text-[15.5px] leading-[1.55] text-ink-soft">
              {enText(insightKey(s.sessions))}
            </p>
            <p className="mt-2 text-[12px] text-ink-faint">
              Personal and longitudinal. Not a diagnosis.
            </p>
          </div>
        </Card>

        {/* alerts */}
        {alerts.length ? (
          <Card variant="glass-solid" className="mt-4 border-l-[5px] border-l-[#dd9a4b] p-6">
            <p className="text-[13px] font-semibold uppercase tracking-[0.07em] text-[#c4761f]">
              Worth a look
            </p>
            <p className="mt-2 text-[15px] leading-[1.55] text-ink-soft">{alerts[0].message}</p>
            <Meta>
              {alerts.length} session{alerts.length > 1 ? 's' : ''} flagged in the last six
            </Meta>
          </Card>
        ) : null}

        {/* ---------- adherence ---------- */}
        <SectionTitle aside="today" tone="light">
          Daily adherence
        </SectionTitle>

        {/* medication */}
        <Card variant="glass-solid" className="p-6">
          <div className="flex items-center gap-3">
            <span className="grid h-10 w-10 place-items-center rounded-full bg-[#fdeceb] text-[#c2413c]">
              <Pill size={20} />
            </span>
            <div className="flex-1">
              <p className="text-[16.5px] font-semibold text-ink">Medication</p>
              <Meta>
                {takenMeds} of {meds.length} taken today
              </Meta>
            </div>
            <span className="display text-[26px] text-ink">
              {meds.length ? Math.round((takenMeds / meds.length) * 100) : 0}%
            </span>
          </div>

          <div className="mt-5 space-y-3">
            {meds.map((r) => {
              const done = s.today.taken.includes(r.id)
              return (
                <div key={r.id} className="rounded-[20px] bg-white/65 p-3">
                  <div className="flex items-center gap-3">
                    <button
                      onClick={() => s.markTaken(r.id)}
                      aria-label={done ? `Mark ${r.title} not taken` : `Mark ${r.title} taken`}
                      className={`grid h-12 w-12 shrink-0 place-items-center rounded-full transition-colors ${
                        done ? 'bg-mint-500 text-white' : 'bg-black/7 text-ink-faint'
                      }`}
                    >
                      <Check size={20} />
                    </button>
                    <div className="min-w-0 flex-1">
                      <p className={`text-[15.5px] font-medium leading-snug ${done ? 'text-ink-faint line-through' : 'text-ink'}`}>
                        {r.title}
                      </p>
                      <Meta>{r.time}</Meta>
                    </div>
                  </div>
                  <div className="mt-2.5 flex items-center justify-between border-t border-black/6 pt-1">
                    <span className="pl-1 text-[13px] text-ink-muted">Scheduled daily</span>
                    <Toggle on={r.on} onChange={() => s.toggleReminder(r.id)} label={`${r.title} scheduled`} />
                  </div>
                </div>
              )
            })}
            {!meds.length && <Muted>No medication routines set.</Muted>}
          </div>
        </Card>

        {/* hydration */}
        <Card variant="glass-solid" className="mt-4 p-6">
          <div className="flex items-center gap-3">
            <span className="grid h-10 w-10 place-items-center rounded-full bg-sky-100 text-sky-600">
              <Drop size={20} />
            </span>
            <div className="flex-1">
              <p className="text-[16.5px] font-semibold text-ink">Hydration</p>
              <Meta>
                {water} of {WATER_TARGET} glasses
              </Meta>
            </div>
            <span className="display text-[26px] text-ink">
              {Math.round((water / WATER_TARGET) * 100)}%
            </span>
          </div>

          <div className="mt-5 flex flex-wrap gap-2.5">
            {Array.from({ length: WATER_TARGET }, (_, i) => (
              <span
                key={i}
                className={`grid h-11 w-9 place-items-end rounded-b-[10px] rounded-t-[4px] border-2 pb-1 transition-colors duration-300 ${
                  i < water ? 'border-sky-400 bg-sky-200' : 'border-black/10 bg-white/50'
                }`}
              >
                <span className={`h-1.5 w-1.5 rounded-full ${i < water ? 'bg-sky-600' : 'bg-transparent'}`} />
              </span>
            ))}
          </div>

          <div className="mt-5 flex gap-3">
            <button
              onClick={() => s.logWater(1)}
              className="flex h-12 flex-[1.5] items-center justify-center gap-2 rounded-full bg-sky-500 text-[15px] font-semibold text-white"
            >
              <Plus size={19} /> Log a glass
            </button>
            <button
              onClick={() => s.logWater(-1)}
              disabled={!water}
              className="flex h-12 flex-1 items-center justify-center gap-2 rounded-full bg-black/6 text-[15px] font-medium text-ink-soft disabled:opacity-35"
            >
              <Undo size={18} /> Undo
            </button>
          </div>
        </Card>

        {/* ---------- cognitive trend ---------- */}
        <SectionTitle tone="light">Cognitive trend</SectionTitle>

        <Card variant="glass-solid" className="px-4 py-5">
          <div className="-mx-1 mb-4 flex gap-2 overflow-x-auto px-1 pb-1">
            {FILTERS.map((f) => (
              <button
                key={f.id}
                onClick={() => setFilter(f.id)}
                className={`h-10 shrink-0 rounded-full px-4 text-[13.5px] font-medium transition-colors ${
                  filter === f.id ? 'bg-ink text-white' : 'bg-black/6 text-ink-soft'
                }`}
              >
                {f.label}
              </button>
            ))}
          </div>

          <TrendChart sessions={filtered} lang="en" />

          <div className="mt-3 flex items-center justify-center gap-5 text-[12px] text-ink-muted">
            <span className="flex items-center gap-1.5">
              <span className="h-2 w-2 rounded-full bg-mint-600" /> at or above baseline
            </span>
            <span className="flex items-center gap-1.5">
              <span className="h-[2px] w-5 border-t-2 border-dashed border-mint-600" /> 75% target
            </span>
          </div>
        </Card>

        {/* ---------- domains ---------- */}
        <SectionTitle tone="light">Domains</SectionTitle>
        <Card variant="glass-solid" className="space-y-5 p-6">
          {Object.entries(s.domains).map(([key, value]) => (
            <div key={key}>
              <div className="mb-2 flex items-baseline justify-between">
                <span className="text-[15px] font-medium text-ink">{DOMAIN_LABEL[key]}</span>
                <span className="display text-[19px] text-ink-soft">{Math.round(value)}</span>
              </div>
              <Meter value={value} tone={key === 'routine' ? 'warm' : key === 'attention' ? 'mint' : 'sky'} />
            </div>
          ))}
        </Card>

        {/* ---------- session log ---------- */}
        <SectionTitle aside={`${filtered.length} rows`} tone="light">
          Session log
        </SectionTitle>

        {filtered.length ? (
          <Card variant="glass-solid" className="overflow-hidden">
            <div className="grid grid-cols-[1.5fr_0.8fr_0.7fr_0.8fr] gap-2 border-b border-black/7 px-5 py-3 text-[11.5px] font-semibold uppercase tracking-[0.05em] text-ink-faint">
              <span>Activity</span>
              <span className="text-right">Acc.</span>
              <span className="text-right">Miss</span>
              <span className="text-right">Time</span>
            </div>
            {filtered.slice(0, 10).map((x, i) => (
              <div
                key={x.id}
                className={`grid grid-cols-[1.5fr_0.8fr_0.7fr_0.8fr] gap-2 px-5 py-3.5 text-[14px] ${
                  i ? 'border-t border-white/70' : ''
                }`}
              >
                <span className="min-w-0">
                  <span className="block truncate font-medium text-ink">{GAME_LABEL[x.game]}</span>
                  <Meta>
                    {new Date(x.at).toLocaleDateString('en-US', { day: 'numeric', month: 'short' })} · {x.difficulty}
                  </Meta>
                </span>
                <span className={`text-right font-semibold ${x.accuracy >= 70 ? 'text-mint-600' : 'text-[#c4761f]'}`}>
                  {Math.round(x.accuracy)}%
                </span>
                <span className="text-right text-ink-soft">{x.errors}</span>
                <span className="text-right text-ink-soft">{x.seconds}s</span>
              </div>
            ))}
          </Card>
        ) : (
          <Card variant="glass-solid" className="px-6 py-9 text-center">
            <p className="mb-4 text-[34px]">📋</p>
            <Muted>Nothing recorded for this filter yet.</Muted>
            <button
              onClick={s.seedDemo}
              className="mx-auto mt-5 h-12 rounded-full bg-ink px-6 text-[15px] font-semibold text-white"
            >
              Load sample data
            </button>
          </Card>
        )}
      </div>
    </Screen>
  )
}

function Badge({ value, label }) {
  return (
    <div className="rounded-[22px] bg-white/25 px-3 py-4 text-center backdrop-blur-md">
      <p className="display text-[26px] text-white">{value}</p>
      <p className="mt-0.5 text-[12px] font-medium text-white/80">{label}</p>
    </div>
  )
}
