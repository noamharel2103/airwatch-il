// ─── OpenSky Network API client ──────────────────────────────────────────────
// Free, no auth needed for limited requests (400/day anonymous)
// Docs: https://openskynetwork.github.io/opensky-api/rest.html

import type { Plane } from '../types'

// Bounding box: Israel + Iran + surroundings
const BBOX = { minLat: 25, maxLat: 40, minLon: 28, maxLon: 60 }

export async function fetchPlanes(): Promise<Plane[]> {
  try {
    const url = `https://opensky-network.org/api/states/all?lamin=${BBOX.minLat}&lomin=${BBOX.minLon}&lamax=${BBOX.maxLat}&lomax=${BBOX.maxLon}`
    const res = await fetch(url, { signal: AbortSignal.timeout(6000) })
    if (!res.ok) return []
    const data = await res.json()
    if (!data.states) return []

    return (data.states as unknown[][])
      .filter((s) => s[5] != null && s[6] != null)
      .slice(0, 60) // limit for performance
      .map((s) => ({
        id: String(s[0]),
        callsign: String(s[1] ?? '').trim() || '?',
        lat: Number(s[6]),
        lng: Number(s[5]),
        altitude: Number(s[7] ?? 0),
        velocity: Number(s[9] ?? 0),
        heading: Number(s[10] ?? 0),
        country: String(s[2] ?? ''),
        isMillitary: false,
      }))
  } catch {
    return []
  }
}
