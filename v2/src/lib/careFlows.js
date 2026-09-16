/* ==========================================================================
   The five guided care flows.

   Only ids and icons live here — every piece of text is in the translation
   catalogs under `voice.*`, because these scripts are read aloud in the
   patient's own language.
   ========================================================================== */

export const CARE_FLOWS = [
  { id: 'orientation', icon: '🌅', needsDate: true },
  { id: 'hydration', icon: '💧' },
  { id: 'medication', icon: '💊' },
  { id: 'encouragement', icon: '🌱' },
  { id: 'calming', icon: '🫧', needsName: false },
]

export const flowTitle = (id) => `voice.${id}Title`
export const flowBlurb = (id) => `voice.${id}Blurb`
export const flowScript = (id) => `voice.${id}Script`
