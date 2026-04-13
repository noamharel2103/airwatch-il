// ─── Pikud HaOref API client ───────────────────────────────────────────────
// docs: https://github.com/idanstark42/oref-alert
// The real endpoint: https://www.oref.org.il/warningMessages/alert/Alerts.json
// Because of CORS we need a proxy in production.
// For GitHub Pages, deploy a tiny Cloudflare Worker (free) as the proxy:
//   see README.md for instructions.
// In dev mode, the Vite proxy forwards /api/oref → oref.org.il

export interface OrefAlert {
  id: string
  cat: string        // '1' = rocket/missile
  title: string      // city name in Hebrew
  desc: string
  time: string
}

export interface OrefResponse {
  id: string
  cat: string
  title: string
  data: string[]     // array of city names
  desc: string
}

const PROXY_URL = import.meta.env.VITE_OREF_PROXY ?? '/api/oref'

export async function fetchOrefAlerts(): Promise<OrefResponse | null> {
  try {
    const res = await fetch(`${PROXY_URL}/warningMessages/alert/Alerts.json`, {
      headers: { 'X-Requested-With': 'XMLHttpRequest', Referer: 'https://www.oref.org.il/' },
      signal: AbortSignal.timeout(4000),
    })
    if (!res.ok) return null
    const text = await res.text()
    if (!text.trim()) return null
    return JSON.parse(text) as OrefResponse
  } catch {
    return null
  }
}

// City → approximate coordinates lookup (subset of common alert cities)
export const CITY_COORDS: Record<string, [number, number]> = {
  'תל אביב - יפו':      [32.0853, 34.7818],
  'תל אביב':            [32.0853, 34.7818],
  'ירושלים':            [31.7683, 35.2137],
  'חיפה':               [32.7940, 34.9896],
  'באר שבע':            [31.2530, 34.7915],
  'אשדוד':              [31.8040, 34.6550],
  'אשקלון':             [31.6688, 34.5743],
  'נתניה':              [32.3215, 34.8532],
  'פתח תקווה':          [32.0840, 34.8878],
  'ראשון לציון':        [31.9730, 34.7925],
  'רמת גן':             [32.0684, 34.8248],
  'הרצליה':             [32.1663, 34.8436],
  'נהריה':              [33.0082, 35.0942],
  'עכו':                [32.9260, 35.0818],
  'צפת':                [32.9646, 35.4956],
  'טבריה':              [32.7922, 35.5312],
  'אילת':               [29.5569, 34.9519],
  'קריית שמונה':        [33.2075, 35.5681],
  'מטולה':              [33.2722, 35.5764],
  'שדרות':              [31.5237, 34.5964],
  'ספיר':               [31.2200, 34.7400],
  'נתיבות':             [31.4214, 34.5892],
  'גן יבנה':            [31.7896, 34.7055],
  'ניצן':               [31.7340, 34.6420],
  'אשכול':              [31.3100, 34.5200],
}
