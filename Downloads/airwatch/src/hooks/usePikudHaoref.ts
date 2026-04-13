import { useEffect, useRef } from 'react'
import { useStore } from '../store/useStore'
import { fetchOrefAlerts, CITY_COORDS } from '../services/pikudHaoref'
import type { AlertEvent } from '../types'

const POLL_MS = 5000 // poll every 5 seconds — same as IWM

export function usePikudHaoref() {
  const addAlert = useStore((s) => s.addAlert)
  const seenIds = useRef<Set<string>>(new Set())

  useEffect(() => {
    async function poll() {
      const data = await fetchOrefAlerts()
      if (!data || !data.id) return
      if (seenIds.current.has(data.id)) return
      seenIds.current.add(data.id)

      // Each city in data.data gets its own alert marker
      const cities = Array.isArray(data.data) ? data.data : [data.title]
      cities.forEach((city: string) => {
        const coords = CITY_COORDS[city]
        const alert: AlertEvent = {
          id: `${data.id}-${city}`,
          type: 'צופר',
          title: `🔴 צבע אדום — ${city}`,
          body: data.desc || 'כניסה מיידית לממ"ד',
          severity: 'red',
          position: coords ? { lat: coords[0], lng: coords[1] } : undefined,
          timestamp: new Date(),
        }
        addAlert(alert)
      })
    }

    poll()
    const id = setInterval(poll, POLL_MS)
    return () => clearInterval(id)
  }, [addAlert])
}
