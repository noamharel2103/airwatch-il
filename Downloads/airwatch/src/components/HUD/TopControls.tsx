import { useStore } from '../../store/useStore'
import { createMissile, createDrone } from '../../hooks/useProjectiles'
import type { AlertEvent } from '../../types'

export function TopControls() {
  const { interceptMode, setInterceptMode, addProjectile, addAlert, simRunning, setSimRunning } = useStore()
  const simRef = React.useRef<ReturnType<typeof setInterval> | null>(null)

  function fireMissile() {
    const p = createMissile(interceptMode)
    addProjectile(p)
    const alert: AlertEvent = {
      id: `launch-${p.id}`,
      type: 'missile',
      title: `שיגור טיל זוהה`,
      body: `טיל בליסטי משוגר לעבר ${p.targetName} — ETA ${p.etaMinutes} דקות`,
      severity: 'red',
      position: p.target,
      timestamp: new Date(),
    }
    addAlert(alert)
  }

  function fireDrone() {
    const p = createDrone(interceptMode)
    addProjectile(p)
    const alert: AlertEvent = {
      id: `launch-${p.id}`,
      type: 'drone',
      title: `כטב"מ זוהה`,
      body: `כטב"מ התקפי לעבר ${p.targetName} — ETA ${p.etaMinutes} דקות`,
      severity: 'orange',
      position: p.target,
      timestamp: new Date(),
    }
    addAlert(alert)
  }

  function toggleSim() {
    if (simRunning) {
      if (simRef.current) clearInterval(simRef.current)
      setSimRunning(false)
    } else {
      setSimRunning(true)
      fireMissile()
      simRef.current = setInterval(() => {
        if (Math.random() < 0.6) fireMissile()
        else fireDrone()
      }, 9000)
    }
  }

  React.useEffect(() => {
    return () => { if (simRef.current) clearInterval(simRef.current) }
  }, [])

  const btn = (label: string, onClick: () => void, active = false) => (
    <button
      onClick={onClick}
      style={{
        background: active ? 'rgba(249,115,22,0.15)' : 'rgba(13,27,46,0.9)',
        border: `1px solid ${active ? '#f97316' : 'rgba(255,255,255,0.18)'}`,
        borderRadius: 6, color: active ? '#f97316' : '#e2e8f0',
        fontSize: 11, fontFamily: "'IBM Plex Mono',monospace",
        padding: '7px 13px', cursor: 'pointer', transition: 'all .15s',
        whiteSpace: 'nowrap',
      }}
      onMouseEnter={(e) => { if (!active) e.currentTarget.style.background = 'rgba(255,255,255,0.08)' }}
      onMouseLeave={(e) => { if (!active) e.currentTarget.style.background = 'rgba(13,27,46,0.9)' }}
    >
      {label}
    </button>
  )

  return (
    <div style={{ position: 'absolute', top: 14, left: 14, display: 'flex', gap: 7, zIndex: 800 }}>
      {btn(simRunning ? '⏸ עצור' : '▶ הדמייה', toggleSim, simRunning)}
      {btn('🚀 טיל', fireMissile)}
      {btn('🛸 כטב"מ', fireDrone)}
      {btn(`יירוט: ${interceptMode ? 'פעיל' : 'כבוי'}`, () => setInterceptMode(!interceptMode), interceptMode)}
    </div>
  )
}

import React from 'react'
