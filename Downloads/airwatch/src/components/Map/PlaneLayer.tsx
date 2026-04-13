import { useEffect, useRef } from 'react'
import { useMap } from 'react-leaflet'
import L from 'leaflet'
import { useStore } from '../../store/useStore'

function planeIcon(heading: number, isIsrael: boolean) {
  const color = isIsrael ? '#94a3b8' : '#64748b'
  const svg = `
    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 20 20">
      <g transform="rotate(${heading}, 10, 10)">
        <path d="M10 2 L13 10 L10 8.5 L7 10 Z" fill="${color}" opacity="0.9"/>
        <path d="M7 10 L3 13 L10 11.5 L17 13 L13 10" fill="${color}" opacity="0.6"/>
      </g>
    </svg>`
  return L.divIcon({
    className: '',
    html: svg,
    iconSize: [20, 20],
    iconAnchor: [10, 10],
  })
}

export function PlaneLayer() {
  const map = useMap()
  const planes = useStore((s) => s.planes)
  const visible = useStore((s) => s.layers.planes)
  const layerRef = useRef<L.LayerGroup>(L.layerGroup())

  useEffect(() => {
    layerRef.current.addTo(map)
    return () => { layerRef.current.remove() }
  }, [map])

  useEffect(() => {
    layerRef.current.clearLayers()
    if (!visible) return

    planes.forEach((plane) => {
      const isIsrael = plane.country === 'Israel'
      L.marker([plane.lat, plane.lng], { icon: planeIcon(plane.heading, isIsrael) })
        .bindTooltip(
          `<b>${plane.callsign}</b><br>${plane.country}<br>גובה: ${Math.round(plane.altitude)}מ'<br>מהירות: ${Math.round(plane.velocity)}מ/ש`,
          { direction: 'top', opacity: 0.9 }
        )
        .addTo(layerRef.current)
    })
  }, [planes, visible])

  return null
}
