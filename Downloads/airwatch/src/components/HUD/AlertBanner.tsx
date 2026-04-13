import { useStore } from '../../store/useStore'
import { useEffect, useState } from 'react'

export function AlertBanner() {
  const alerts = useStore((s) => s.alerts)
  const [banner, setBanner] = useState<string | null>(null)

  useEffect(() => {
    const latest = alerts[0]
    if (!latest || latest.severity !== 'red') return
    const age = Date.now() - latest.timestamp.getTime()
    if (age > 3000) return
    setBanner(latest.title)
    const id = setTimeout(() => setBanner(null), 5000)
    return () => clearTimeout(id)
  }, [alerts])

  if (!banner) return null

  return (
    <div style={{
      position: 'absolute', top: 0, left: 0, right: 0,
      background: 'rgba(239,68,68,0.95)',
      padding: '10px 20px',
      display: 'flex', alignItems: 'center', gap: 12,
      zIndex: 900,
      animation: 'slideDown .3s ease',
      fontFamily: "'Heebo', sans-serif",
    }}>
      <span style={{ fontSize: 18 }}>⚠</span>
      <span style={{ fontSize: 13, fontWeight: 500, color: '#fff', fontFamily: "'IBM Plex Mono',monospace" }}>
        {banner} — כניסה לממ"ד!
      </span>
    </div>
  )
}
