import { useCallback, useEffect, useState } from 'react'
import { StoreProvider, useStore } from './lib/store'
import { LanguageProvider } from './lib/i18n'
import BottomNav from './components/BottomNav'

import Welcome from './screens/Welcome'
import LanguageSelect from './screens/LanguageSelect'
import ProfileSelect from './screens/ProfileSelect'
import Home from './screens/Home'
import MoodCheck from './screens/MoodCheck'
import Games from './screens/Games'
import MemoryMatch from './screens/MemoryMatch'
import RememberObjects from './screens/RememberObjects'
import SequenceMemory from './screens/SequenceMemory'
import Voice from './screens/Voice'
import Progress from './screens/Progress'
import Reminders from './screens/Reminders'
import Caretaker from './screens/Caretaker'

/* A small navigation stack — push/pop, so Back always means "where I came from". */

const TAB_SCREENS = ['home', 'games', 'voice', 'progress']

function Shell() {
  const store = useStore()
  const [stack, setStack] = useState(() => (store.onboarded ? ['profile'] : ['welcome']))
  const [voiceFlow, setVoiceFlow] = useState(null)

  const screen = stack[stack.length - 1]

  const push = useCallback((s) => setStack((k) => [...k, s]), [])
  const pop = useCallback(() => setStack((k) => (k.length > 1 ? k.slice(0, -1) : k)), [])
  const reset = useCallback((s) => setStack([s]), [])

  /* Tabs replace rather than stack, so the nav never grows unboundedly. */
  const tab = useCallback((id) => {
    setStack((k) => {
      const base = k.filter((s) => !TAB_SCREENS.includes(s))
      const root = base.length ? base : ['profile']
      return id === 'home' ? [...root, 'home'] : [...root, 'home', id]
    })
  }, [])

  /* Scroll to the top whenever the screen changes. */
  useEffect(() => {
    window.scrollTo({ top: 0 })
  }, [screen])

  /* Browser back (when running as a web page) maps onto the stack. */
  useEffect(() => {
    const onPop = (e) => {
      e.preventDefault?.()
      pop()
    }
    window.addEventListener('popstate', onPop)
    return () => window.removeEventListener('popstate', onPop)
  }, [pop])

  /* Android's hardware back button.
     Capacitor's default is history.back(), and since this app never pushes
     history entries that would quit on the first press from any screen. Pop
     our own stack instead, and only exit when there is nothing left to pop. */
  useEffect(() => {
    let remove
    let cancelled = false

    import('@capacitor/app')
      .then(({ App: CapApp }) => {
        if (cancelled) return
        return CapApp.addListener('backButton', () => {
          setStack((k) => {
            if (k.length > 1) return k.slice(0, -1)
            CapApp.exitApp()
            return k
          })
        }).then((handle) => {
          if (cancelled) handle.remove()
          else remove = () => handle.remove()
        })
      })
      .catch(() => {
        /* running in a plain browser — no native back button to bind */
      })

    return () => {
      cancelled = true
      remove?.()
    }
  }, [])

  const showNav = TAB_SCREENS.includes(screen) || screen === 'reminders'

  const go = (id) => {
    if (id === 'mood') return push('mood')
    if (id === 'reminders') return push('reminders')
    if (id === 'changeLanguage') return push('changeLanguage')
    return tab(id)
  }

  const view = () => {
    switch (screen) {
      case 'welcome':
        return (
          <Welcome
            onStart={() => reset('language')}
            onSkip={() => {
              store.finishOnboarding()
              reset('profile')
            }}
          />
        )

      case 'language':
        return (
          <LanguageSelect
            onContinue={() => {
              store.finishOnboarding()
              reset('profile')
            }}
          />
        )

      /* Reached from the home screen, so it pops back instead of continuing. */
      case 'changeLanguage':
        return <LanguageSelect onBack={pop} onContinue={pop} />

      case 'profile':
        return (
          <ProfileSelect
            name={store.name}
            onPatient={() => push('home')}
            onCaretaker={() => push('caretaker')}
          />
        )

      case 'home':
        return <Home go={go} onSwitchProfile={() => reset('profile')} />

      case 'mood':
        return (
          <MoodCheck
            onBack={pop}
            onLog={store.logMood}
            onCalm={() => {
              setVoiceFlow('calming')
              setStack((k) => [...k.slice(0, -1), 'voice'])
            }}
          />
        )

      case 'games':
        return <Games onBack={pop} onPlay={(id) => push(`game:${id}`)} />

      case 'game:match':
        return <MemoryMatch onBack={pop} />

      case 'game:objects':
        return <RememberObjects onBack={pop} />

      case 'game:sequence':
        return <SequenceMemory onBack={pop} />

      case 'voice':
        return (
          <Voice
            onBack={() => {
              setVoiceFlow(null)
              pop()
            }}
            initialFlow={voiceFlow}
          />
        )

      case 'progress':
        return <Progress onBack={pop} />

      case 'reminders':
        return <Reminders onBack={pop} />

      case 'caretaker':
        return <Caretaker onBack={pop} />

      default:
        return <Home go={go} onSwitchProfile={() => reset('profile')} />
    }
  }

  return (
    <div className="min-h-[100dvh]">
      <div key={screen} className="fade">
        {view()}
      </div>

      {showNav ? (
        <BottomNav
          active={TAB_SCREENS.includes(screen) ? screen : 'home'}
          onNavigate={tab}
          onCompanion={() => push('mood')}
        />
      ) : null}
    </div>
  )
}

export default function App() {
  return (
    <LanguageProvider>
      <StoreProvider>
        <Shell />
      </StoreProvider>
    </LanguageProvider>
  )
}
