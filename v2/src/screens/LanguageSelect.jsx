import Blob from '../components/Blob'
import { useT } from '../lib/i18n'
import { LOCALES } from '../lib/i18n/locales'
import { Screen, Display, Muted, Card, Tappable, TopBar } from '../components/ui'
import { Check } from '../components/Icons'

/* Language picker.

   Each option is written in its own script — somebody who reads only Tamil
   cannot pick the row labelled "Tamil". The heading re-translates the instant
   you tap, so the choice previews itself before you commit; v1 did this and it
   is worth keeping. */

export default function LanguageSelect({ onContinue, onBack }) {
  const { language, setLanguage, t } = useT()

  return (
    <Screen>
      <div className="flex min-h-[100dvh] flex-col pb-10">
        {onBack ? <TopBar onBack={onBack} /> : <div className="h-4" />}

        <div className="mt-4 flex flex-col items-center text-center rise">
          <Blob mood="calm" size={128} />
          <Display className="mt-5 text-[32px]">{t('language.title')}</Display>
          <Muted className="mt-3 max-w-[310px]">{t('language.body')}</Muted>
        </div>

        <div className="mt-8 space-y-3">
          {Object.entries(LOCALES).map(([code, meta], i) => {
            const on = language === code
            return (
              <Tappable
                key={code}
                onClick={() => setLanguage(code)}
                className="block w-full rise"
                style={{ animationDelay: `${i * 70}ms` }}
              >
                <Card
                  variant={on ? 'glass-solid' : 'glass'}
                  className={`flex items-center gap-4 p-5 ${on ? 'ring-2 ring-mint-500' : ''}`}
                >
                  <span
                    className="min-w-0 flex-1 text-left text-[22px] leading-tight text-ink"
                    lang={code}
                  >
                    {meta.native}
                  </span>
                  <span className="shrink-0 text-[13.5px] font-medium text-ink-faint">
                    {meta.english}
                  </span>
                  <span
                    className={`grid h-9 w-9 shrink-0 place-items-center rounded-full transition-colors ${
                      on ? 'bg-mint-500 text-white' : 'bg-black/6 text-transparent'
                    }`}
                  >
                    <Check size={18} />
                  </span>
                </Card>
              </Tappable>
            )
          })}
        </div>

        <button onClick={onContinue} className="pill-cta mt-auto">
          {t('language.continue')}
        </button>
      </div>
    </Screen>
  )
}
