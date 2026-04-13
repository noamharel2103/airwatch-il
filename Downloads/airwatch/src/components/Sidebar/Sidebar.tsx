import { useStore } from '../../store/useStore'
import { LayerToggles } from './LayerToggles'
import { AlertsFeed } from './AlertsFeed'

export function Sidebar() {
  const tileStyle = useStore((s) => s.tileStyle)
  const setTileStyle = useStore((s) => s.setTileStyle)
  const alerts = useStore((s) => s.alerts)
  const threatLevel = getThreatLevel(alerts.filter((a) => a.severity === 'red').length)

  return (
    <aside style={{
      width: 310,
      minWidth: 310,
      background: '#0d1b2e',
      borderLeft: '1px solid rgba(255,255,255,0.07)',
      display: 'flex',
      flexDirection: 'column',
      height: '100vh',
      overflow: 'hidden',
      zIndex: 1000,
      fontFamily: "'Heebo', sans-serif",
    }}>
      {/* Header */}
      <div style={{ padding: '13px 16px', borderBottom: '1px solid rgba(255,255,255,0.07)', display: 'flex', alignItems: 'center', gap: 10 }}>
        <span style={{ fontFamily: "'IBM Plex Mono',monospace", fontSize: 15, fontWeight: 500, color: '#fff', letterSpacing: '.04em' }}>
          Air<span style={{ color: '#f97316' }}>Watch</span> IL
        </span>
        <LiveBadge />
      </div>

      {/* Layer toggles */}
      <LayerToggles />

      {/* Alerts feed */}
      <AlertsFeed />

      {/* Footer */}
      <div style={{ padding: '9px 16px', borderTop: '1px solid rgba(255,255,255,0.07)', display: 'flex', alignItems: 'center', gap: 8, flexShrink: 0 }}>
        <Clock />
        <select
          value={tileStyle}
          onChange={(e) => setTileStyle(e.target.value as 'dark' | 'satellite' | 'topo')}
          style={{ fontFamily: "'IBM Plex Mono',monospace", fontSize: 10, background: '#112240', color: '#e2e8f0', border: '1px solid rgba(255,255,255,0.15)', borderRadius: 5, padding: '4px 8px', cursor: 'pointer', marginRight: 'auto' }}
        >
          <option value="dark">כהה</option>
          <option value="satellite">לוויין</option>
          <option value="topo">טופו</option>
        </select>
        <ThreatBadge level={threatLevel} />
      </div>
    </aside>
  )
}

function LiveBadge() {
  return (
    <div style={{ marginRight: 'auto', display: 'flex', alignItems: 'center', gap: 5, background: 'rgba(34,197,94,0.1)', border: '1px solid rgba(34,197,94,0.3)', borderRadius: 4, padding: '3px 7px', fontFamily: "'IBM Plex Mono',monospace", fontSize: 10, color: '#22c55e' }}>
      <div style={{ width: 6, height: 6, borderRadius: '50%', background: '#22c55e', animation: 'blink 1.2s infinite' }} />
      LIVE
    </div>
  )
}

function Clock() {
  const [time, setTime] = React.useState(new Date().toLocaleTimeString('he-IL'))
  React.useEffect(() => {
    const id = setInterval(() => setTime(new Date().toLocaleTimeString('he-IL')), 1000)
    return () => clearInterval(id)
  }, [])
  return <span style={{ fontFamily: "'IBM Plex Mono',monospace", fontSize: 11, color: 'rgba(226,232,240,0.5)' }}>{time}</span>
}

function getThreatLevel(redCount: number) {
  if (redCount === 0) return { label: 'נמוכה', cls: 'low' }
  if (redCount <= 2) return { label: 'בינונית', cls: 'med' }
  if (redCount <= 5) return { label: 'גבוהה', cls: 'high' }
  return { label: 'קריטי', cls: 'crit' }
}

const TL_COLORS = {
  low:  { bg: 'rgba(34,197,94,0.1)',  border: 'rgba(34,197,94,0.3)',  text: '#22c55e' },
  med:  { bg: 'rgba(234,179,8,0.1)',  border: 'rgba(234,179,8,0.3)',  text: '#eab308' },
  high: { bg: 'rgba(249,115,22,0.1)', border: 'rgba(249,115,22,0.3)', text: '#f97316' },
  crit: { bg: 'rgba(239,68,68,0.1)',  border: 'rgba(239,68,68,0.3)',  text: '#ef4444' },
}

function ThreatBadge({ level }: { level: { label: string; cls: string } }) {
  const c = TL_COLORS[level.cls as keyof typeof TL_COLORS]
  return (
    <div style={{ fontFamily: "'IBM Plex Mono',monospace", fontSize: 10, padding: '3px 8px', borderRadius: 4, background: c.bg, border: `1px solid ${c.border}`, color: c.text }}>
      רמה: {level.label}
    </div>
  )
}

import React from 'react'
