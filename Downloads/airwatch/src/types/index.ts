export type ProjectileType = 'missile' | 'drone' | 'rocket'
export type AlertSeverity = 'red' | 'orange' | 'green' | 'info'
export type TileStyle = 'dark' | 'satellite' | 'topo'

export interface LatLng {
  lat: number
  lng: number
}

export interface Projectile {
  id: string
  type: ProjectileType
  origin: LatLng
  target: LatLng
  // bezier control points
  cp1: LatLng
  cp2: LatLng
  progress: number      // 0-1
  intercepted: boolean
  interceptAt: number   // progress value where interception happens (0-1)
  startedAt: number     // Date.now()
  durationMs: number
  label: string
  source: string
  etaMinutes: number
  targetName: string
}

export interface AlertEvent {
  id: string
  type: string
  title: string
  body: string
  severity: AlertSeverity
  position?: LatLng
  timestamp: Date
}

export interface Plane {
  id: string
  callsign: string
  lat: number
  lng: number
  altitude: number      // meters
  velocity: number      // m/s
  heading: number       // degrees
  country: string
  isMillitary: boolean
}

export interface LayerVisibility {
  missiles: boolean
  drones: boolean
  planes: boolean
  alerts: boolean
  radar: boolean
}

export interface AppState {
  layers: LayerVisibility
  tileStyle: TileStyle
  interceptMode: boolean
  projectiles: Projectile[]
  alerts: AlertEvent[]
  planes: Plane[]
  simRunning: boolean

  toggleLayer: (layer: keyof LayerVisibility) => void
  setTileStyle: (style: TileStyle) => void
  setInterceptMode: (v: boolean) => void
  addProjectile: (p: Projectile) => void
  removeProjectile: (id: string) => void
  updateProjectileProgress: (id: string, progress: number) => void
  addAlert: (a: AlertEvent) => void
  setPlanes: (planes: Plane[]) => void
  setSimRunning: (v: boolean) => void
}
