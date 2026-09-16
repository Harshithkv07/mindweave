import Blob from '../components/Blob'
import { useT } from '../lib/i18n'
import { Screen, Display, Muted, RingButton } from '../components/ui'
import { Heart, Compass } from '../components/Icons'

/* The first screen: stacked frosted cards, a serif promise, one black pill. */

const CARDS = [
  { k: 'card1', rot: -13, x: -44, y: 34, z: 1, o: 0.55 },
  { k: 'card2', rot: 8, x: 40, y: 6, z: 2, o: 0.75 },
  { k: 'card3', rot: -3, x: -6, y: -22, z: 3, o: 1 },
]

export default function Welcome({ onStart, onSkip }) {
  const { t } = useT()

  return (
    <Screen>
      <div className="flex min-h-[100dvh] flex-col pb-8">
        <div className="flex items-start justify-between pt-3">
          <RingButton tone="sky" label={t('welcome.explore')}>
            <Compass size={21} />
          </RingButton>
          <RingButton tone="mint" label={t('welcome.saved')}>
            <Heart size={21} />
          </RingButton>
        </div>

        {/* The stacked card cluster.
            Positioning lives on the outer node and the entrance animation on the
            inner one — the keyframes end at `transform: none`, so sharing a node
            would wipe the offset out. */}
        <div className="relative mt-4 mb-2 h-[340px]">
          {CARDS.map((c, i) => (
            <div
              key={i}
              className="absolute left-1/2 top-1/2 min-h-[210px] w-[250px]"
              style={{
                transform: `translate(-50%,-50%) translate(${c.x}px, ${c.y}px) rotate(${c.rot}deg)`,
                zIndex: c.z,
                opacity: c.o,
              }}
            >
              <div
                className="glass-ghost flex h-full w-full flex-col justify-between rounded-[30px] p-6 rise"
                style={{ animationDelay: `${i * 110}ms` }}
              >
                <p className="display text-[23px] text-ink/85">{t(`welcome.${c.k}`)}</p>
                <span className="text-[12px] font-medium text-ink-faint">
                  {t(`welcome.${c.k}meta`)}
                </span>
              </div>
            </div>
          ))}

          <div className="absolute -left-[2%] -top-[6%] z-[4]">
            <div className="pop" style={{ animationDelay: '380ms' }}>
              <Blob mood="happy" size={98} />
            </div>
          </div>
        </div>

        <div className="mt-auto rise" style={{ animationDelay: '260ms' }}>
          <Display className="text-[38px] leading-[1.06]">{t('welcome.title')}</Display>

          <Muted className="mt-4 max-w-[330px] text-[15.5px]">{t('welcome.body')}</Muted>

          <button onClick={onStart} className="pill-cta mt-8">
            {t('welcome.start')}
          </button>

          <button
            onClick={onSkip}
            className="mx-auto mt-4 block px-6 py-3 text-[15px] font-medium text-ink-soft"
          >
            {t('common.skip')}
          </button>
        </div>
      </div>
    </Screen>
  )
}
