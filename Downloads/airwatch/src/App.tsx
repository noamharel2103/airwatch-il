import { useEffect } from 'react'
import { MapView } from './components/Map/MapView'
import { Sidebar } from './components/Sidebar/Sidebar'
import { InfoCard } from './components/HUD/InfoCard'
import { AlertBanner } from './components/HUD/AlertBanner'
import { TopControls } from './components/HUD/TopControls'
import { usePikudHaoref } from './hooks/usePikudHaoref'
import { useOpenSky } from './hooks/useOpenSky'
import { useProjectileAnimation } from './hooks/useProjectiles'

export default function App() {
  // Start all data hooks
  usePikudHaoref()
  useOpenSky()
  useProjectileAnimation()

  // Prevent right-click context menu on map
  useEffect(() => {
    document.addEventListener('contextmenu', (e) => e.preventDefault())
  }, [])

  return (
    <div style={{ display: 'flex', height: '100vh', width: '100vw', overflow: 'hidden', background: '#07111f', direction: 'rtl' }}>
      <Sidebar />
      <div style={{ flex: 1, position: 'relative', overflow: 'hidden' }}>
        <MapView />
        <AlertBanner />
        <TopControls />
        <InfoCard />
      </div>
    </div>
  )
}
