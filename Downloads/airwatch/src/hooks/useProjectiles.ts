import { useEffect, useRef } from 'react'
import { useStore } from '../store/useStore'
import type { Projectile, AlertEvent } from '../types'

// Bezier helpers
function bezierPoint(t: number, p0: number, p1: number, p2: number, p3: number) {
  const mt = 1 - t
  return mt * mt * mt * p0 + 3 * mt * mt * t * p1 + 3 * mt * t * t * p2 + t * t * t * p3
}

export function useProjectileAnimation() {
  const { projectiles, updateProjectileProgress, removeProjectile, addAlert } = useStore()
  const rafRef = useRef<number>(0)

  useEffect(() => {
    function tick() {
      const now = Date.now()
      projectiles.forEach((p) => {
        const elapsed = now - p.startedAt
        const raw = Math.min(elapsed / p.durationMs, 1)
        const endT = p.intercepted ? p.interceptAt : 1

        if (raw >= endT) {
          // Projectile finished
          removeProjectile(p.id)

          const alert: AlertEvent = {
            id: `outcome-${p.id}`,
            type: p.intercepted ? 'יירוט' : 'פגיעה',
            title: p.intercepted ? `יורט — ${p.targetName}` : `פגיעה — ${p.targetName}`,
            body: p.intercepted
              ? `${p.type === 'missile' ? 'טיל' : 'כטב"מ'} יורט בהצלחה מעל ${p.targetName}`
              : `${p.type === 'missile' ? 'טיל' : 'כטב"מ'} פגע באזור ${p.targetName}`,
            severity: p.intercepted ? 'green' : 'red',
            position: p.target,
            timestamp: new Date(),
          }
          addAlert(alert)
        } else {
          updateProjectileProgress(p.id, raw)
        }
      })
      rafRef.current = requestAnimationFrame(tick)
    }

    rafRef.current = requestAnimationFrame(tick)
    return () => cancelAnimationFrame(rafRef.current)
  }, [projectiles, updateProjectileProgress, removeProjectile, addAlert])
}

// Factory helpers
const TARGETS = [
  { name: 'תל אביב', lat: 32.07, lng: 34.78 },
  { name: 'ירושלים', lat: 31.77, lng: 35.23 },
  { name: 'חיפה',    lat: 32.79, lng: 34.99 },
  { name: 'באר שבע', lat: 31.25, lng: 34.79 },
  { name: 'אשדוד',   lat: 31.80, lng: 34.65 },
]

const IRAN_LAUNCH_SITES = [
  { lat: 35.69, lng: 51.38 }, // Tehran
  { lat: 32.66, lng: 51.67 }, // Isfahan
  { lat: 29.59, lng: 52.58 }, // Shiraz
]

const YEMEN_LAUNCH = { lat: 15.35, lng: 44.21 }

export function createMissile(interceptMode: boolean): Projectile {
  const origin = IRAN_LAUNCH_SITES[Math.floor(Math.random() * IRAN_LAUNCH_SITES.length)]
  const tgt = TARGETS[Math.floor(Math.random() * TARGETS.length)]
  const midLat = (origin.lat + tgt.lat) / 2
  const midLng = (origin.lng + tgt.lng) / 2
  const interceptAt = 0.5 + Math.random() * 0.15

  return {
    id: crypto.randomUUID(),
    type: 'missile',
    origin,
    target: { lat: tgt.lat, lng: tgt.lng },
    cp1: { lat: midLat + 8, lng: midLng - 3 },
    cp2: { lat: midLat + 8, lng: midLng + 3 },
    progress: 0,
    intercepted: interceptMode,
    interceptAt,
    startedAt: Date.now(),
    durationMs: (12 + Math.random() * 6) * 60 * 1000 / 60, // scaled down for demo: ~12-18s
    label: 'טיל בליסטי',
    source: ['Telegram/WarMonitor', 'OSINT/Intel_Sky', 'Pikud HaOref'][Math.floor(Math.random() * 3)],
    etaMinutes: Math.round(12 + Math.random() * 6),
    targetName: tgt.name,
  }
}

export function createDrone(interceptMode: boolean): Projectile {
  const tgt = TARGETS[Math.floor(Math.random() * TARGETS.length)]
  const midLat = (YEMEN_LAUNCH.lat + tgt.lat) / 2
  const midLng = (YEMEN_LAUNCH.lng + tgt.lng) / 2

  return {
    id: crypto.randomUUID(),
    type: 'drone',
    origin: YEMEN_LAUNCH,
    target: { lat: tgt.lat, lng: tgt.lng },
    cp1: { lat: midLat + 2, lng: midLng - 5 },
    cp2: { lat: midLat + 2, lng: midLng + 5 },
    progress: 0,
    intercepted: interceptMode,
    interceptAt: 0.6 + Math.random() * 0.1,
    startedAt: Date.now(),
    durationMs: 20000 + Math.random() * 8000,
    label: 'כטב"מ',
    source: 'Telegram/Yemen_ops',
    etaMinutes: Math.round(35 + Math.random() * 15),
    targetName: tgt.name,
  }
}

export { bezierPoint }
