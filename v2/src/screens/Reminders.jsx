import { useState } from 'react'
import { useStore } from '../lib/store'
import { useT } from '../lib/i18n'
import {
  Screen, TopBar, RingButton, Display, Muted, Card, Toggle, SectionTitle, Meta,
} from '../components/ui'
import { Bell, Pill, Drop, Brain, Walk, Plus, Trash, Check } from '../components/Icons'

const CATEGORY = {
  medication: { Icon: Pill, tint: 'bg-[#fdeceb] text-[#c2413c]' },
  hydration: { Icon: Drop, tint: 'bg-sky-100 text-sky-600' },
  cognitive: { Icon: Brain, tint: 'bg-mint-100 text-mint-600' },
  activity: { Icon: Walk, tint: 'bg-[#fdf1e0] text-[#c4761f]' },
}

export default function Reminders({ onBack }) {
  const s = useStore()
  const { t } = useT()
  const titleOf = (r) => (r.titleKey ? t(r.titleKey) : r.title)
  const [adding, setAdding] = useState(false)
  const [draft, setDraft] = useState({ title: '', time: '09:00', category: 'medication' })

  const sorted = [...s.reminders].sort((a, b) => a.time.localeCompare(b.time))
  const onCount = sorted.filter((r) => r.on).length

  const save = () => {
    if (!draft.title.trim()) return
    s.addReminder({ ...draft, title: draft.title.trim() })
    setDraft({ title: '', time: '09:00', category: 'medication' })
    setAdding(false)
  }

  return (
    <Screen>
      <div className="pb-36">
        <TopBar
          onBack={onBack}
          right={
            <RingButton tone="mint" label={t('reminders.add')} onClick={() => setAdding((a) => !a)}>
              <Plus size={22} />
            </RingButton>
          }
        />

        <div className="mt-3">
          <Display className="text-[34px]">{t('reminders.title')}</Display>
          <Muted className="mt-3 max-w-[320px]">{t('reminders.body')}</Muted>
        </div>

        {/* add form */}
        {adding ? (
          <Card variant="glass-solid" className="mt-5 space-y-4 p-6 rise">
            <input
              autoFocus
              value={draft.title}
              onChange={(e) => setDraft({ ...draft, title: e.target.value })}
              placeholder={t('reminders.addTitle')}
              className="w-full rounded-[18px] bg-white/80 px-4 py-3.5 text-[16px] text-ink placeholder:text-ink-faint focus:outline-none focus:ring-2 focus:ring-mint-400"
            />

            <div className="flex gap-3">
              <input
                type="time"
                value={draft.time}
                onChange={(e) => setDraft({ ...draft, time: e.target.value })}
                aria-label={t('reminders.time')}
                className="rounded-[18px] bg-white/80 px-4 py-3.5 text-[16px] text-ink focus:outline-none focus:ring-2 focus:ring-mint-400"
              />
              <select
                value={draft.category}
                onChange={(e) => setDraft({ ...draft, category: e.target.value })}
                aria-label={t('reminders.kind')}
                className="flex-1 rounded-[18px] bg-white/80 px-4 py-3.5 text-[16px] text-ink focus:outline-none focus:ring-2 focus:ring-mint-400"
              >
                {Object.keys(CATEGORY).map((k) => (
                  <option key={k} value={k}>
                    {t(`category.${k}`)}
                  </option>
                ))}
              </select>
            </div>

            <div className="flex gap-3">
              <button
                onClick={() => setAdding(false)}
                className="h-12 flex-1 rounded-full bg-black/6 text-[15px] font-medium text-ink-soft"
              >
                {t('common.cancel')}
              </button>
              <button
                onClick={save}
                disabled={!draft.title.trim()}
                className="h-12 flex-[1.4] rounded-full bg-ink text-[15px] font-semibold text-white disabled:opacity-35"
              >
                {t('reminders.addConfirm')}
              </button>
            </div>
          </Card>
        ) : null}

        <SectionTitle aside={t('reminders.onOf', { on: onCount, total: sorted.length })}>
          {t('reminders.daily')}
        </SectionTitle>

        <div className="space-y-3">
          {sorted.map((r, i) => {
            const meta = CATEGORY[r.category] ?? CATEGORY.activity
            const { Icon } = meta
            const done = s.today.taken.includes(r.id)
            return (
              <Card
                key={r.id}
                className={`p-4 rise ${r.on ? '' : 'opacity-55'}`}
                style={{ animationDelay: `${i * 45}ms` }}
              >
                {/* Title gets the full row width — cramming the controls alongside
                    it truncated every routine name. */}
                <div className="flex items-center gap-3.5">
                  <span className={`grid h-12 w-12 shrink-0 place-items-center rounded-full ${meta.tint}`}>
                    <Icon size={22} />
                  </span>

                  <div className="min-w-0 flex-1">
                    <p className={`text-[16px] font-medium leading-snug ${done ? 'text-ink-faint line-through' : 'text-ink'}`}>
                      {titleOf(r)}
                    </p>
                    <Meta>
                      {r.time} · {t(`category.${r.category}`)}
                    </Meta>
                  </div>

                  <Toggle
                    on={r.on}
                    onChange={() => s.toggleReminder(r.id)}
                    label={t('reminders.toggle', { title: titleOf(r) })}
                  />
                </div>

                <div className="mt-3 flex items-center gap-2 border-t border-white/70 pt-3">
                  {r.on ? (
                    <button
                      onClick={() => s.markTaken(r.id)}
                      className={`flex h-11 flex-1 items-center justify-center gap-2 rounded-full text-[14px] font-medium transition-colors ${
                        done ? 'bg-mint-100 text-mint-700' : 'bg-black/5 text-ink-soft'
                      }`}
                    >
                      <Check size={18} />
                      {done ? t('reminders.doneToday') : t('reminders.markDone')}
                    </button>
                  ) : (
                    <span className="flex-1 pl-1 text-[13.5px] text-ink-faint">
                      {t('reminders.switchedOff')}
                    </span>
                  )}

                  <button
                    onClick={() => s.removeReminder(r.id)}
                    aria-label={t('reminders.remove', { title: titleOf(r) })}
                    className="grid h-11 w-11 shrink-0 place-items-center rounded-full text-ink-faint"
                  >
                    <Trash size={18} />
                  </button>
                </div>
              </Card>
            )
          })}
        </div>

        <Card className="mt-5 flex items-start gap-3.5 p-5">
          <Bell size={19} className="mt-0.5 shrink-0 text-ink-muted" />
          <p className="text-[13.5px] leading-[1.55] text-ink-muted">{t('reminders.note')}</p>
        </Card>
      </div>
    </Screen>
  )
}
