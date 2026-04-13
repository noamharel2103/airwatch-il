import { useEffect, useRef } from 'react'
import { useMap } from 'react-leaflet'
import L from 'leaflet'
import { useStore } from '../../store/useStore'

const RADAR_SITES = [
  { lat: 31.5, lng: 34.8, label: 'רדאר ישראל', radii: [80, 150, 250, 400] },
  { lat: 31.9, lng: 35.1, label: 'Arrow BMD', radii: [200, 500] },
]

export function RadarLayer() {
  const map = useMap()
  const visible = useStore((s) => s.layers.radar)
  const layerRef = useRef<L.LayerGroup>(L.layerGroup())

  useEffect(() => {
    layerRef.current.addTo(map)
    return () => { layerRef.current.remove() }
  }, [map])

  useEffect(() => {
    layerRef.current.clearLayers()
    if (!visible) return

    RADAR_SITES.forEach((site) => {
      site.radii.forEach((km, i) => {
        L.circle([site.lat, site.lng], {
          radius: km * 1000,
          color: '#3b82f6',
          fillColor: '#3b82f6',
          fillOpacity: i === 0 ? 0.04 : 0.02,
          weight: 0.5,
          opacity: 0.25,
          dashArray: '4,6',
        }).addTo(layerRef.current)
      })

      // Center marker
      L.circleMarker([site.lat, site.lng], {
        radius: 5, color: '#3b82f6', fillColor: '#3b82f6', fillOpacity: 0.7, weight: 2,
      })
        .bindTooltip(site.label, { direction: 'top', permanent: false })
        .addTo(layerRef.current)
    })
  }, [visible])

  return null
}
