import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'

const style = document.createElement('style')
style.textContent = `
  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
  html, body, #root { height: 100%; width: 100%; overflow: hidden; }
  body { background: #07111f; color: #e2e8f0; }

  @keyframes blink    { 0%,100%{opacity:1} 50%{opacity:.3} }
  @keyframes slideUp  { from{opacity:0;transform:translateY(8px)} to{opacity:1;transform:none} }
  @keyframes slideDown{ from{opacity:0;transform:translateY(-100%)} to{opacity:1;transform:none} }

  /* Leaflet dark overrides */
  .leaflet-container { background: #07111f !important; }
  .leaflet-tile { filter: brightness(0.9) saturate(0.8); }
  .leaflet-popup-content-wrapper {
    background: rgba(13,27,46,0.97) !important;
    border: 1px solid rgba(255,255,255,0.14) !important;
    color: #e2e8f0 !important;
    border-radius: 8px !important;
    font-family: 'Heebo', sans-serif;
    font-size: 12px;
  }
  .leaflet-popup-tip { background: rgba(13,27,46,0.97) !important; }
  .leaflet-tooltip {
    background: rgba(13,27,46,0.95) !important;
    border: 1px solid rgba(255,255,255,0.14) !important;
    color: #e2e8f0 !important;
    font-family: 'Heebo', sans-serif;
    font-size: 11px;
    border-radius: 5px;
  }
  .leaflet-tooltip-arrow { border-top-color: rgba(13,27,46,0.95) !important; }
  .leaflet-control-zoom a {
    background: rgba(13,27,46,0.95) !important;
    color: #e2e8f0 !important;
    border-color: rgba(255,255,255,0.15) !important;
  }
  .leaflet-bar { border: 1px solid rgba(255,255,255,0.14) !important; }

  /* Scrollbar */
  ::-webkit-scrollbar { width: 3px; }
  ::-webkit-scrollbar-track { background: transparent; }
  ::-webkit-scrollbar-thumb { background: rgba(255,255,255,0.12); border-radius: 2px; }
`
document.head.appendChild(style)

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
)
