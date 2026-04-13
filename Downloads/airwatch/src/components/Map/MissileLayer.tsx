import { useEffect, useRef } from 'react'
import { useMap } from 'react-leaflet'
import L from 'leaflet'
import { useStore } from '../../store/useStore'
import { bezierPoint } from '../../hooks/useProjectiles'

function getBezierPath(p: { origin: {lat:number,lng:number}, target: {lat:number,lng:number}, cp1: {lat:number,lng:number}, cp2: {lat:number,lng:number} }, steps = 80) {
  const pts: [number, number][] = []
  for (let i = 0; i <= steps; i++) {
    const t = i / steps
    const lat = bezierPoint(t, p.origin.lat, p.cp1.lat, p.cp2.lat, p.target.lat)
    const lng = bezierPoint(t, p.origin.lng, p.cp1.lng, p.cp2.lng, p.target.lng)
    pts.push([lat, lng])
  }
  return pts
}

function dotIcon(color: string, size = 10) {
  return L.divIcon({
    className: '',
    html: `<div style="width:${size}px;height:${size}px;border-radius:50%;background:${color};border:2px solid ${color}55;box-shadow:0 0 8px ${color}88"></div>`,
    iconSize: [size, size],
    iconAnchor: [size / 2, size / 2],
  })
}

export function MissileLayer() {
  const map = useMap()
  const projectiles = useStore((s) => s.projectiles)
  const missilesVisible = useStore((s) => s.layers.missiles)
  const dronesVisible = useStore((s) => s.layers.drones)
  const layerRef = useRef<L.LayerGroup>(L.layerGroup())

  useEffect(() => {
    layerRef.current.addTo(map)
    return () => { layerRef.current.remove() }
  }, [map])

  useEffect(() => {
    layerRef.current.clearLayers()

    projectiles.forEach((p) => {
      const visible = p.type === 'missile' ? missilesVisible : dronesVisible
      if (!visible) return

      const color = p.type === 'missile' ? '#f97316' : '#a855f7'
      const endT = p.intercepted ? p.interceptAt : 1
      const t = Math.min(p.progress, endT)

      // Draw trail up to current position
      const fullPath = getBezierPath(p)
      const trailEnd = Math.floor(t * fullPath.length)
      const trail = fullPath.slice(0, trailEnd + 1)

      if (trail.length > 1) {
        L.polyline(trail, {
          color,
          weight: p.type === 'missile' ? 2 : 1.5,
          opacity: 0.8,
          dashArray: p.type === 'drone' ? '6,4' : undefined,
        }).addTo(layerRef.current)
      }

      // Draw projectile dot at current position
      const lat = bezierPoint(t, p.origin.lat, p.cp1.lat, p.cp2.lat, p.target.lat)
      const lng = bezierPoint(t, p.origin.lng, p.cp1.lng, p.cp2.lng, p.target.lng)

      L.marker([lat, lng], { icon: dotIcon(color, p.type === 'missile' ? 12 : 10) })
        .bindTooltip(
          `<b>${p.label}</b><br>יעד: ${p.targetName}<br>ETA: ${p.etaMinutes} דק'<br>מקור: ${p.source}`,
          { direction: 'top', opacity: 0.9 }
        )
        .addTo(layerRef.current)

      // Interception explosion marker
      if (p.intercepted && p.progress >= p.interceptAt) {
        const iLat = bezierPoint(p.interceptAt, p.origin.lat, p.cp1.lat, p.cp2.lat, p.target.lat)
        const iLng = bezierPoint(p.interceptAt, p.origin.lng, p.cp1.lng, p.cp2.lng, p.target.lng)
        L.circleMarker([iLat, iLng], {
          radius: 14, color: '#22c55e', fillColor: '#22c55e', fillOpacity: 0.15, weight: 2,
        }).addTo(layerRef.current)
        L.circleMarker([iLat, iLng], {
          radius: 5, color: '#22c55e', fillColor: '#22c55e', fillOpacity: 0.9, weight: 0,
        }).addTo(layerRef.current)
      }
    })
  }, [projectiles, missilesVisible, dronesVisible])

  return null
}
