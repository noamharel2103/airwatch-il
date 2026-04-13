import { useStore } from '../../store/useStore'
import type { AlertEvent } from '../../types'

const SEV_COLORS = {
  red:    { dot: '#ef4444', border: 'rgba(239,68,68,0.22)', bg: 'rgba(239,68,68,0.05)', tag: 'rgba(239,68,68,0.12)', tagText: '#ef4444' },
  orange: { dot: '#f97316', border: 'rgba(249,115,22,0.18)', bg: 'rgba(249,115,22,0.04)', tag: 'rgba(249,115,22,0.12)', tagText: '#f97316' },
  green:  { dot: '#22c55e', border: 'rgba(34,197,94,0.18)',  bg: 'rgba(34,197,94,0.04)', tag: 'rgba(34,197,94,0.12)',  tagText: '#22c55e' },
  info:   { dot: '#3b82f6', border: 'rgba(59,130,246,0.18)', bg: 'rgba(59,130,246,0.04)', tag: 'rgba(59,130,246,0.12)', tagText: '#3b82f6' },
}

export function AlertsFeed() {
  const alerts = useStore((s) => s.alerts)
  const addAlert = useStore((s) => s.addAlert)

  // Demo: add initial system alerts on mount
  const initialized = React.useRef(false)
  React.useEffect(() => {
    if (initialized.current) return
    initialized.current = true
    setTimeout(() => addAlert({ id: 'sys-1', type: 'מערכת', title: 'AirWatch IL מחובר', body: 'מערכת פעילה — מחוברת ל-Pikud HaOref, OpenSky, Telegram OSINT', severity: 'info', timestamp: new Date() }), 800)
    setTimeout(() => addAlert({ id: 'sys-2', type: 'OSINT', title: 'פעילות חריגה זוהתה', body: 'תנועה אווירית גוברת מעל איראן — מעקב פעיל', severity: 'orange', position: { lat: 35.69, lng: 51.38 }, timestamp: new Date() }), 2000)
  }, [addAlert])

  return (
    <div style={{ flex: 1, overflowY: 'auto', padding: '11px 16px' }}>
      <div style={{ fontSize: 10, fontFamily: "'IBM Plex Mono',monospace", color: 'rgba(226,232,240,0.3)', textTransform: 'uppercase', letterSpacing: '.1em', marginBottom: 9 }}>
        התראות ואירועים
      </div>
      {alerts.length === 0 && (
        <div style={{ fontSize: 12, color: 'rgba(226,232,240,0.3)', textAlign: 'center', marginTop: 24 }}>אין התראות</div>
      )}
      {alerts.map((a) => <AlertCard key={a.id} alert={a} />)}
    </div>
  )
}

function AlertCard({ alert: a }: { alert: AlertEvent }) {
  const c = SEV_COLORS[a.severity] ?? SEV_COLORS.info
  const time = a.timestamp.toLocaleTimeString('he-IL', { hour: '2-digit', minute: '2-digit', second: '2-digit' })

  return (
    <div style={{ padding: '9px 11px', borderRadius: 8, marginBottom: 7, border: `1px solid ${c.border}`, background: c.bg, cursor: 'pointer' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 7, marginBottom: 4 }}>
        <div style={{ width: 7, height: 7, borderRadius: '50%', background: c.dot, flexShrink: 0 }} />
        <span style={{ fontSize: 12, fontWeight: 500, color: '#e2e8f0', flex: 1 }}>{a.title}</span>
        <span style={{ fontSize: 10, fontFamily: "'IBM Plex Mono',monospace", color: 'rgba(226,232,240,0.3)' }}>{time}</span>
      </div>
      <div style={{ fontSize: 11, color: 'rgba(226,232,240,0.55)', lineHeight: 1.5, paddingRight: 14 }}>{a.body}</div>
      <span style={{ display: 'inline-block', marginTop: 5, fontSize: 9, fontFamily: "'IBM Plex Mono',monospace", padding: '2px 6px', borderRadius: 3, background: c.tag, color: c.tagText, textTransform: 'uppercase' }}>
        {a.type}
      </span>
    </div>
  )
}

import React from 'react'
