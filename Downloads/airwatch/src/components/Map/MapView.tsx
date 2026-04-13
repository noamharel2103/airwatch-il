import { MapContainer, TileLayer, useMap } from 'react-leaflet'
import { useEffect } from 'react'
import { useStore } from '../../store/useStore'
import { MissileLayer } from './MissileLayer'
import { PlaneLayer } from './PlaneLayer'
import { AlertLayer } from './AlertLayer'
import { RadarLayer } from './RadarLayer'
import 'leaflet/dist/leaflet.css'

const TILES: Record<string, { url: string; attribution: string; subdomains?: string }> = {
  dark: {
    url: 'https://{s}.basemaps.cartocdn.com/dark_nolabels/{z}/{x}/{y}{r}.png',
    attribution: '© CartoDB',
    subdomains: 'abcd',
  },
  satellite: {
    url: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
    attribution: '© Esri',
  },
  topo: {
    url: 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png',
    attribution: '© OpenTopoMap',
    subdomains: 'abc',
  },
}

function TileController() {
  const tileStyle = useStore((s) => s.tileStyle)
  const map = useMap()

  useEffect(() => {
    // force re-render handled by key on TileLayer below
    void map
  }, [tileStyle, map])

  return null
}

export function MapView() {
  const tileStyle = useStore((s) => s.tileStyle)
  const tile = TILES[tileStyle] ?? TILES.dark

  return (
    <MapContainer
      center={[32.0, 40.0]}
      zoom={5}
      zoomControl={false}
      attributionControl={false}
      style={{ width: '100%', height: '100%', background: '#07111f' }}
    >
      <TileLayer key={tileStyle} url={tile.url} subdomains={tile.subdomains ?? 'abc'} />
      <TileController />
      <RadarLayer />
      <PlaneLayer />
      <AlertLayer />
      <MissileLayer />
    </MapContainer>
  )
}
