import { useStore } from '../../store/useStore'

export function InfoCard() {
  const projectiles = useStore((s) => s.projectiles)
  const active = projectiles[projectiles.length - 1]

  const show = !!active

  if (!show) return null

  const color = active.type === 'missile' ? '#f97316' : '#a855f7'
  const pct = active.intercepted ? Math.round(75 + Math.random() * 20) : Math.round(40 + Math.random() * 25)

  return (
    <div style={{
      position: 'absolute', bottom: 14, left: 14,
      background: 'rgba(13,27,46,0.95)', border: '1px solid rgba(255,255,255,0.14)',
      borderRadius: 10, padding: '13px 15px', minWidth: 210,
      animation: 'slideUp .2s ease',
      fontFamily: "'Heebo', sans-serif",
      zIndex: 800,
    }}>
      <div style={{ fontSize: 10, fontFamily: "'IBM Plex Mono',monospace", color, marginBottom: 8, textTransform: 'uppercase', letterSpacing: '.06em' }}>
        {active.type === 'missile' ? 'טיל בליסטי פעיל' : 'כטב"מ פעיל'}
      </div>
      <Row label="סטטוס"     value="שיגור זוהה"       color="#ef4444" />
      <Row label="יעד"       value={active.targetName} />
      <Row label="ETA"       value={`${active.etaMinutes} דקות`} />
      <Row label="התקדמות"   value={`${Math.round(active.progress * 100)}%`} color={color} />
      <Row label="יירוט"     value={`${pct}%`} color={pct > 65 ? '#22c55e' : '#f97316'} />
      <Row label="מקור"      value={active.source} />
    </div>
  )
}

function Row({ label, value, color }: { label: string; value: string; color?: string }) {
  return (
    <div style={{ display: 'flex', justifyContent: 'space-between', gap: 14, marginBottom: 4, fontSize: 11 }}>
      <span style={{ color: 'rgba(226,232,240,0.45)' }}>{label}</span>
      <span style={{ fontWeight: 500, fontFamily: "'IBM Plex Mono',monospace", color: color ?? '#e2e8f0', textAlign: 'left' }}>{value}</span>
    </div>
  )
}
