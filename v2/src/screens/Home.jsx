import Blob from '../components/Blob'
import { useStore } from '../lib/store'
import { useT } from '../lib/i18n'
import {
  Screen, RingButton, Display, Card, Tappable, SectionTitle, Meta, Rich,
} from '../components/ui'
import { Grid, Pill, Drop, Wave, Chart, Check, Clock, Walk, Brain, Spark, Globe } from '../components/Icons'

const greetKey = () => {
  const h = new Date().getHours()
  if (h < 12) return 'home.greetMorning'
  if (h < 17) return 'home.greetAfternoon'
  if (h < 21) return 'home.greetEvening'
  return 'home.greetNight'
}

const CATEGORY = {
  medication: { Icon: Pill, tint: 'bg-[#fdeceb] text-[#c2413c]' },
  hydration: { Icon: Drop, tint: 'bg-sky-100 text-sky-600' },
  cognitive: { Icon: Brain, tint: 'bg-mint-100 text-mint-600' },
  activity: { Icon: Walk, tint: 'bg-[#fdf1e0] text-[#c4761f]' },
}

export default function Home({ go, onSwitchProfile }) {
  const s = useStore()
  const { t } = useT()

  /* Seeded routines render from their catalog key so they rename with the
     language; ones the patient added keep their own wording. */
  const titleOf = (r) => (r.titleKey ? t(r.titleKey) : r.title)
  const mood = s.moods[0]?.mood ?? 'calm'
  const upcoming = [...s.reminders].filter((r) => r.on).sort((a, b) => a.time.localeCompare(b.time))
  const nextUp = upcoming.find((r) => r.time >= new Date().toTimeString().slice(0, 5)) ?? upcoming[0]

  const actions = [
    { id: 'games', label: t('home.actionActivities'), sub: t('home.actionActivitiesSub'), Icon: Grid, tint: 'from-mint-300 to-mint-500' },
    { id: 'voice', label: t('home.actionVoice'), sub: t('home.actionVoiceSub'), Icon: Wave, tint: 'from-sky-300 to-sky-500' },
    { id: 'reminders', label: t('home.actionRoutines'), sub: t('home.actionRoutinesSub', { count: upcoming.length }), Icon: Clock, tint: 'from-[#f6d9a8] to-[#dd9a4b]' },
    { id: 'progress', label: t('home.actionProgress'), sub: t('home.actionProgressSub'), Icon: Chart, tint: 'from-[#b6c8f0] to-[#7f9ee0]' },
  ]

  return (
    <Screen>
      <div className="pb-36">
        {/* ---- header ---- */}
        <div className="flex items-start justify-between pt-3">
          <div className="min-w-0 rise">
            <Meta>{t(greetKey())}</Meta>
            <Display className="mt-1 text-[33px]">{s.name}</Display>
          </div>
          <div className="flex gap-2.5">
            <RingButton
              tone="mint"
              label={t('language.change')}
              onClick={() => go('changeLanguage')}
            >
              <Globe size={21} />
            </RingButton>
            <button
              onClick={onSwitchProfile}
              aria-label={t('home.switchProfile')}
              className="ring-btn text-ink-soft"
            >
              <span className="text-[15px] font-semibold">
                {s.name.slice(0, 1).toUpperCase()}
              </span>
            </button>
          </div>
        </div>

        {/* ---- companion + next routine ---- */}
        <Tappable onClick={() => go('mood')} className="mt-5 block w-full rise" style={{ animationDelay: '70ms' }}>
          <Card variant="glass-solid" className="flex items-center gap-4 overflow-hidden p-5">
            <Blob mood={mood} size={92} drift={false} />
            <div className="min-w-0 flex-1">
              <p className="display text-[19px] leading-[1.2] text-ink">
                {s.moods.length ? t('home.moodPrompt') : t('home.moodPromptFirst')}
              </p>
              <p className="mt-1.5 text-[13.5px] text-ink-muted">
                {nextUp
                  ? t('home.nextUp', { title: titleOf(nextUp), time: nextUp.time })
                  : t('home.nothingScheduled')}
              </p>
            </div>
          </Card>
        </Tappable>

        {/* ---- live stats ---- */}
        <div className="mt-4 grid grid-cols-3 gap-3 rise" style={{ animationDelay: '130ms' }}>
          <Stat value={s.played} label={t('home.statSessions')} />
          <Stat value={s.bestAccuracy ? `${Math.round(s.bestAccuracy)}%` : '—'} label={t('home.statBest')} />
          <Stat value={`${Math.round(s.baseline)}%`} label={t('home.statBaseline')} />
        </div>

        {/* ---- quick actions ---- */}
        <SectionTitle>{t('home.whatNext')}</SectionTitle>
        <div className="grid grid-cols-2 gap-3.5">
          {actions.map(({ id, label, sub, Icon, tint }, i) => (
            <Tappable
              key={id}
              onClick={() => go(id)}
              className="block rise"
              style={{ animationDelay: `${180 + i * 55}ms` }}
            >
              <Card className="flex min-h-[148px] flex-col justify-between gap-3 p-5">
                <span
                  className={`grid h-[52px] w-[52px] place-items-center rounded-full bg-gradient-to-br ${tint} text-white shadow-[0_10px_22px_-12px_rgba(26,78,88,0.9)]`}
                >
                  <Icon size={25} />
                </span>
                <span>
                  <span className="block text-[17px] font-semibold tracking-[-0.01em] text-ink">
                    {label}
                  </span>
                  <span className="mt-0.5 block text-[13px] text-ink-muted">{sub}</span>
                </span>
              </Card>
            </Tappable>
          ))}
        </div>

        {/* ---- today ---- */}
        <SectionTitle aside={t('home.routineCount', { count: upcoming.length })}>
          {t('home.today')}
        </SectionTitle>
        <Card className="overflow-hidden">
          {upcoming.slice(0, 5).map((r, i) => {
            const { Icon, tint } = CATEGORY[r.category] ?? CATEGORY.activity
            const done = s.today.taken.includes(r.id)
            return (
              <div
                key={r.id}
                className={`flex items-center gap-4 px-5 py-4 ${i ? 'border-t border-white/70' : ''}`}
              >
                <span className={`grid h-11 w-11 shrink-0 place-items-center rounded-full ${tint}`}>
                  <Icon size={21} />
                </span>
                <div className="min-w-0 flex-1">
                  <p
                    className={`text-[16px] font-medium leading-snug ${done ? 'text-ink-faint line-through' : 'text-ink'}`}
                  >
                    {titleOf(r)}
                  </p>
                  <Meta>{r.time}</Meta>
                </div>
                <button
                  onClick={() => s.markTaken(r.id)}
                  aria-label={
                    done
                      ? t('home.undoDone', { title: titleOf(r) })
                      : t('home.markDone', { title: titleOf(r) })
                  }
                  className={`grid h-12 w-12 shrink-0 place-items-center rounded-full transition-colors ${
                    done ? 'bg-mint-500 text-white' : 'bg-black/6 text-ink-faint'
                  }`}
                >
                  <Check size={21} />
                </button>
              </div>
            )
          })}
          {!upcoming.length && (
            <p className="px-5 py-8 text-center text-[15px] text-ink-muted">
              {t('home.noRoutines')}
            </p>
          )}
        </Card>

        {s.streak > 1 ? (
          <Card className="mt-4 flex items-center gap-3.5 p-5">
            <span className="grid h-11 w-11 shrink-0 place-items-center rounded-full bg-mint-100 text-mint-600">
              <Spark size={21} />
            </span>
            <Rich
              className="text-[15px] text-ink-soft"
              text={t('home.streak', { count: s.streak })}
            />
          </Card>
        ) : null}
      </div>
    </Screen>
  )
}

function Stat({ value, label }) {
  return (
    <Card className="px-3 py-4 text-center">
      <p className="display text-[27px] text-ink">{value}</p>
      <p className="mt-0.5 text-[12.5px] font-medium text-ink-muted">{label}</p>
    </Card>
  )
}
