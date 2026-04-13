import { useEffect, useRef } from 'react'
import { useMap } from 'react-leaflet'
import L from 'leaflet'
import { useStore } from '../../store/useStore'

export function AlertLayer() {
  const map = useMap()
  const alerts = useStore((s) => s.alerts)
  const visible = useStore((s) => s.layers.alerts)
  const layerRef = useRef<L.LayerGroup>(L.layerGroup())

  useEffect(() => {
    layerRef.current.addTo(map)
    return () => { layerRef.current.remove() }
  }, [map])

  useEffect(() => {
    layerRef.current.clearLayers()
    if (!visible) return

    const recent = alerts.filter(
      (a) => a.position && Date.now() - a.timestamp.getTime() < 120_000
    )

    recent.forEach((a) => {
      if (!a.position) return
      const color = a.severity === 'red' ? '#ef4444' : a.severity === 'orange' ? '#f97316' : '#22c55e'

      // Pulse circle
      L.circleMarker([a.position.lat, a.position.lng], {
        radius: 18, color, fillColor: color, fillOpacity: 0.08, weight: 1.5,
      }).addTo(layerRef.current)

      // Center dot
      L.circleMarker([a.position.lat, a.position.lng], {
        radius: 6, color, fillColor: color, fillOpacity: 0.85, weight: 2,
      })
        .bindPopup(`<b>${a.title}</b><br>${a.body}`)
        .addTo(layerRef.current)
    })
  }, [alerts, visible])

  return null
}
