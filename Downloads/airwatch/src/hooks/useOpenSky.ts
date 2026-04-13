import { useEffect } from 'react'
import { useStore } from '../store/useStore'
import { fetchPlanes } from '../services/opensky'

const POLL_MS = 30_000 // OpenSky rate limit: don't poll too fast

export function useOpenSky() {
  const setPlanes = useStore((s) => s.setPlanes)
  const planesVisible = useStore((s) => s.layers.planes)

  useEffect(() => {
    if (!planesVisible) return

    async function poll() {
      const planes = await fetchPlanes()
      if (planes.length > 0) setPlanes(planes)
    }

    poll()
    const id = setInterval(poll, POLL_MS)
    return () => clearInterval(id)
  }, [planesVisible, setPlanes])
}
