import { create } from 'zustand'
import type { AppState, LayerVisibility, TileStyle, Projectile, AlertEvent, Plane } from '../types'

export const useStore = create<AppState>((set) => ({
  layers: {
    missiles: true,
    drones: true,
    planes: true,
    alerts: true,
    radar: true,
  },
  tileStyle: 'dark',
  interceptMode: false,
  projectiles: [],
  alerts: [],
  planes: [],
  simRunning: false,

  toggleLayer: (layer: keyof LayerVisibility) =>
    set((s) => ({ layers: { ...s.layers, [layer]: !s.layers[layer] } })),

  setTileStyle: (style: TileStyle) => set({ tileStyle: style }),

  setInterceptMode: (v: boolean) => set({ interceptMode: v }),

  addProjectile: (p: Projectile) =>
    set((s) => ({ projectiles: [...s.projectiles, p] })),

  removeProjectile: (id: string) =>
    set((s) => ({ projectiles: s.projectiles.filter((p) => p.id !== id) })),

  updateProjectileProgress: (id: string, progress: number) =>
    set((s) => ({
      projectiles: s.projectiles.map((p) =>
        p.id === id ? { ...p, progress } : p
      ),
    })),

  addAlert: (a: AlertEvent) =>
    set((s) => ({ alerts: [a, ...s.alerts].slice(0, 50) })),

  setPlanes: (planes: Plane[]) => set({ planes }),

  setSimRunning: (v: boolean) => set({ simRunning: v }),
}))
