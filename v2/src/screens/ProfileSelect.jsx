import Blob from '../components/Blob'
import { useT } from '../lib/i18n'
import { Screen, Display, Muted, Card, Tappable } from '../components/ui'
import { User, Shield } from '../components/Icons'

/* Two tiles, no password. The first decision is a picture, not a credential. */

export default function ProfileSelect({ onPatient, onCaretaker, name }) {
  const { t } = useT()

  return (
    <Screen>
      <div className="flex min-h-[100dvh] flex-col justify-center pb-10">
        <div className="mb-8 flex flex-col items-center text-center rise">
          <Blob mood="calm" size={140} />
          <Display className="mt-5 text-[34px]">{t('profile.title')}</Display>
          <Muted className="mt-3 max-w-[300px]">{t('profile.body')}</Muted>
        </div>

        <div className="space-y-4">
          <Tappable onClick={onPatient} className="block w-full rise" style={{ animationDelay: '90ms' }}>
            <Card variant="glass-solid" className="flex items-center gap-5 p-6">
              <span className="grid h-[70px] w-[70px] shrink-0 place-items-center rounded-full bg-gradient-to-br from-sky-300 to-sky-500 text-white shadow-[0_12px_26px_-12px_rgba(56,163,224,0.9)]">
                <User size={32} />
              </span>
              <span className="min-w-0">
                <span className="block text-[21px] font-semibold tracking-[-0.01em] text-ink">
                  {name}
                </span>
                <span className="mt-1 block text-[14.5px] text-ink-muted">
                  {t('profile.patientSub')}
                </span>
              </span>
            </Card>
          </Tappable>

          <Tappable onClick={onCaretaker} className="block w-full rise" style={{ animationDelay: '170ms' }}>
            <Card variant="glass-solid" className="flex items-center gap-5 p-6">
              <span className="grid h-[70px] w-[70px] shrink-0 place-items-center rounded-full bg-gradient-to-br from-mint-400 to-mint-600 text-white shadow-[0_12px_26px_-12px_rgba(47,165,116,0.9)]">
                <Shield size={32} />
              </span>
              <span className="min-w-0">
                <span className="block text-[21px] font-semibold tracking-[-0.01em] text-ink">
                  {t('profile.caretaker')}
                </span>
                <span className="mt-1 block text-[14.5px] text-ink-muted">
                  {t('profile.caretakerSub')}
                </span>
              </span>
            </Card>
          </Tappable>
        </div>
      </div>
    </Screen>
  )
}
