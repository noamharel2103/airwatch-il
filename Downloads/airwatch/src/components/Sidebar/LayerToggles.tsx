import { useStore } from '../../store/useStore'
import type { LayerVisibility } from '../../types'

interface LayerDef {
  key: keyof LayerVisibility
  label: string
  emoji: string
  color: string
  countKey?: 'missiles' | 'drones' | 'planes' | 'alerts'
}

const LAYERS: LayerDef[] = [
  { key: 'missiles', label: 'טילים בליסטיים', emoji: '🚀', color: '#f97316', countKey: 'missiles' },
  { key: 'drones',   label: 'כטב"מים / רחפנים', emoji: '🛸', color: '#a855f7', countKey: 'drones' },
  { key: 'planes',   label: 'תנועה אווירית',  emoji: '✈️', color: '#94a3b8', countKey: 'planes' },
  { key: 'alerts',   label: 'התראות צופר',    emoji: '🔴', color: '#ef4444', countKey: 'alerts' },
  { key: 'radar',    label: 'כיסוי רדאר',     emoji: '📡', color: '#3b82f6' },
]

export function LayerToggles() {
  const layers = useStore((s) => s.layers)
  const toggleLayer = useStore((s) => s.toggleLayer)
  const projectiles = useStore((s) => s.projectiles)
  const planes = useStore((s) => s.planes)
  const alerts = useStore((s) => s.alerts)

  const counts: Record<string, number> = {
    missiles: projectiles.filter((p) => p.type === 'missile').length,
    drones:   projectiles.filter((p) => p.type === 'drone').length,
    planes:   planes.length,
    alerts:   alerts.filter((a) => Date.now() - a.timestamp.getTime() < 60_000).length,
  }

  return (
    <div style={{ padding: '11px 16px', borderBottom: '1px solid rgba(255,255,255,0.07)', flexShrink: 0 }}>
      <div style={{ fontSize: 10, fontFamily: "'IBM Plex Mono',monospace", color: 'rgba(226,232,240,0.3)', textTransform: 'uppercase', letterSpacing: '.1em', marginBottom: 9 }}>
        שכבות תצוגה
      </div>
      {LAYERS.map((layer) => {
        const on = layers[layer.key]
        const count = layer.countKey ? counts[layer.countKey] : undefined
        return (
          <div
            key={layer.key}
            onClick={() => toggleLayer(layer.key)}
            style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '6px 8px', borderRadius: 7, cursor: 'pointer', transition: 'background .15s', marginBottom: 2 }}
            onMouseEnter={(e) => (e.currentTarget.style.background = 'rgba(255,255,255,0.04)')}
            onMouseLeave={(e) => (e.currentTarget.style.background = 'transparent')}
          >
            <div style={{ width: 28, height: 28, borderRadius: 6, background: `${layer.color}18`, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 13, flexShrink: 0 }}>
              {layer.emoji}
            </div>
            <span style={{ flex: 1, fontSize: 12, color: on ? '#e2e8f0' : 'rgba(226,232,240,0.35)', transition: 'color .15s' }}>
              {layer.label}
            </span>
            {count !== undefined && count > 0 && (
              <span style={{ fontFamily: "'IBM Plex Mono',monospace", fontSize: 10, color: layer.color, background: `${layer.color}18`, border: `1px solid ${layer.color}44`, borderRadius: 4, padding: '1px 6px' }}>
                {count}
              </span>
            )}
            <Toggle on={on} color={layer.color} />
          </div>
        )
      })}
    </div>
  )
}

function Toggle({ on, color }: { on: boolean; color: string }) {
  return (
    <div style={{ width: 30, height: 17, borderRadius: 9, background: on ? color : 'rgba(255,255,255,0.1)', position: 'relative', transition: 'background .2s', flexShrink: 0 }}>
      <div style={{ position: 'absolute', top: 2, width: 13, height: 13, borderRadius: '50%', background: '#fff', transition: 'right .2s', right: on ? 2 : 15 }} />
    </div>
  )
}
