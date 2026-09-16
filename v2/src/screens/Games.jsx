import { useStore } from '../lib/store'
import { useT } from '../lib/i18n'
import { matchConfig, objectsConfig, sequenceConfig } from '../lib/adaptive'
import { Screen, Card, Tappable, Tag } from '../components/ui'
import { Back, Bell, Search } from '../components/Icons'

/* The activity hub, on the deep mint wash — the "Reflections" panel. */

const GAMES = [
  { id: 'match', tags: ['tagMemory', 'tagPairs', 'tagGentle'] },
  { id: 'objects', tags: ['tagRecall', 'tagAttention', 'tagEveryday'] },
  { id: 'sequence', tags: ['tagSequence', 'tagFocus', 'tagRhythm'] },
]

export default function Games({ onBack, onPlay }) {
  const s = useStore()
  const { t } = useT()

  const configs = {
    match: matchConfig(s.sessions),
    objects: objectsConfig(s.sessions),
    sequence: sequenceConfig(s.sessions),
  }

  return (
    <Screen wash="wash-deep">
      <div className="pb-36">
        <div className="flex items-center justify-between pt-3">
          <button onClick={onBack} className="ring-btn bg-white/22 text-white" aria-label={t('common.back')}>
            <Back size={21} />
          </button>
          <button className="ring-btn bg-white/22 text-white" aria-label={t('games.find')}>
            <Search size={20} />
          </button>
        </div>

        <div className="mt-7 text-center fade">
          <h1 className="display text-[40px] text-white">{t('games.title')}</h1>
          <p className="mt-2 text-[14.5px] text-white/80">{t('games.subtitle')}</p>
        </div>

        <div className="mt-8 space-y-5">
          {GAMES.map(({ id, tags }, i) => {
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
                    <span className="label-caps text-[13px] font-semibold text-mint-600">
                      {t(`gameName.${id}`)}
                    </span>
                    <span className="rounded-full bg-mint-100 px-3 py-1 text-[12px] font-semibold text-mint-700">
                      {t(`tier.${cfg.tier}`)}
                    </span>
                  </div>

                  <p className="display mt-4 text-[27px] leading-[1.14] text-ink">
                    {t(`games.${id}Question`)}
                  </p>

                  <p className="mt-3 text-[14.5px] leading-[1.5] text-ink-muted">
                    {t(`games.${id}Blurb`)}
                  </p>

                  <div className="mt-5 flex flex-wrap gap-2">
                    {tags.map((tag) => (
                      <Tag key={tag}>{t(`games.${tag}`)}</Tag>
                    ))}
                  </div>

                  {/* Two whole sentences joined by a separator, rather than a
                      sentence assembled from translated fragments. */}
                  <p className="mt-5 text-[12.5px] font-medium text-ink-faint">
                    {played ? t('games.playedCount', { count: played }) : t('games.notTried')}
                    {' · '}
                    {describe(t, id, cfg)}
                  </p>
                </Card>
              </Tappable>
            )
          })}
        </div>

        <div className="mt-8 flex items-start gap-3 rounded-[24px] bg-white/18 p-5 backdrop-blur-md">
          <Bell size={19} className="mt-0.5 shrink-0 text-white/85" />
          <p className="text-[13.5px] leading-[1.5] text-white/85">{t('games.note')}</p>
        </div>
      </div>
    </Screen>
  )
}

function describe(t, id, cfg) {
  if (id === 'match') return t('games.matchDetail', { count: cfg.pairs })
  if (id === 'objects') return t('games.objectsDetail', { count: cfg.remember, seconds: cfg.showSeconds })
  return t('games.sequenceDetail', { count: cfg.startLength })
}
