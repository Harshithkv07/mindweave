import { createContext, useCallback, useContext, useEffect, useMemo, useState } from 'react'
import { DEFAULT_LANGUAGE, LOCALES, isLanguage } from './locales'

import en from './en.json'
import ta from './ta.json'
import hi from './hi.json'
import te from './te.json'

/* ==========================================================================
   Translation runtime.

   Hand-rolled rather than react-i18next: the catalogs are small, there are
   only a handful of plural sites, and the app must work offline inside a
   WebView. `Intl.PluralRules` is already in the runtime, which is the only
   part of ICU we actually need.
   ========================================================================== */

const CATALOGS = { en, ta, hi, te }

const KEY = 'mindweave.language'

const Ctx = createContext(null)

function readStored() {
  try {
    const v = localStorage.getItem(KEY)
    return isLanguage(v) ? v : DEFAULT_LANGUAGE
  } catch {
    return DEFAULT_LANGUAGE
  }
}

/** Resolve a dotted key against a catalog. */
function lookup(catalog, key) {
  return key.split('.').reduce((node, part) => (node == null ? undefined : node[part]), catalog)
}

function interpolate(template, vars) {
  if (!vars) return template
  return template.replace(/\{(\w+)\}/g, (whole, name) =>
    Object.hasOwn(vars, name) ? String(vars[name]) : whole,
  )
}

export function LanguageProvider({ children }) {
  const [language, setLanguageState] = useState(readStored)

  /* Drives the per-script font stacks in index.css via :root:lang(...) and
     tells the browser which language the document is in, which matters for
     line breaking and for screen readers. */
  useEffect(() => {
    document.documentElement.lang = language
    try {
      localStorage.setItem(KEY, language)
    } catch {
      /* private mode — the choice just won't survive a restart */
    }
  }, [language])

  const setLanguage = useCallback((code) => {
    if (isLanguage(code)) setLanguageState(code)
  }, [])

  const t = useCallback(
    (key, vars) => {
      const catalog = CATALOGS[language] ?? en
      let entry = lookup(catalog, key)

      // Fall back to English for anything not yet translated, so a gap shows
      // as English rather than as a raw key.
      if (entry == null && catalog !== en) {
        entry = lookup(en, key)
        if (entry != null && import.meta.env.DEV) {
          console.warn(`[i18n] missing ${language}: ${key}`)
        }
      }

      if (entry == null) {
        if (import.meta.env.DEV) console.warn(`[i18n] missing key: ${key}`)
        return key
      }

      // Plural entries are objects keyed by CLDR category.
      if (typeof entry === 'object') {
        const count = Number(vars?.count ?? 0)
        let category = 'other'
        try {
          category = new Intl.PluralRules(LOCALES[language]?.date ?? 'en-US').select(count)
        } catch {
          category = count === 1 ? 'one' : 'other'
        }
        entry = entry[category] ?? entry.other ?? entry.one ?? ''
      }

      return interpolate(entry, vars)
    },
    [language],
  )

  const value = useMemo(() => ({ language, setLanguage, t }), [language, setLanguage, t])

  return <Ctx.Provider value={value}>{children}</Ctx.Provider>
}

export function useT() {
  const v = useContext(Ctx)
  if (!v) throw new Error('useT must be used inside <LanguageProvider>')
  return v
}

export { LOCALES, DEFAULT_LANGUAGE } from './locales'
