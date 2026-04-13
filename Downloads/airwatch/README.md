# AirWatch IL 🛰

מעקב שטח אווירי בזמן אמת — ישראל / איראן

## טכנולוגיות
- **React 18** + TypeScript
- **Leaflet** + react-leaflet — מפה אינטראקטיבית
- **Zustand** — ניהול state
- **Vite** — build tool
- **GitHub Actions** — deploy אוטומטי

## מקורות נתונים
| מקור | תיאור | קצב עדכון |
|------|--------|-----------|
| פיקוד העורף | התראות צבע אדום | 5 שניות |
| OpenSky Network | מטוסים ADS-B | 30 שניות |
| Telegram OSINT | WarMonitor / Intel_Sky | הדמייה |

---

## הוראות התקנה

### 1. Clone והתקנה

```bash
git clone https://github.com/YOUR_USERNAME/airwatch-il.git
cd airwatch-il
npm install
npm run dev
```

הפרויקט יפתח ב-`http://localhost:5173`

---

### 2. Deploy ל-GitHub Pages

#### א. צור repo ב-GitHub
1. כנס ל-[github.com/new](https://github.com/new)
2. שם: `airwatch-il` (חשוב שיתאים ל-`base` ב-vite.config.ts)
3. הגדר כ-Public

#### ב. דחוף את הקוד
```bash
git init
git add .
git commit -m "initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/airwatch-il.git
git push -u origin main
```

#### ג. הפעל GitHub Pages
1. כנס ל-Settings → Pages
2. Source: **GitHub Actions**
3. שמור

כל `git push` יגרור build ו-deploy אוטומטי. האתר יהיה ב:
`https://YOUR_USERNAME.github.io/airwatch-il/`

---

### 3. חיבור פיקוד העורף לייצור (CORS Proxy)

בגלל CORS, ב-production צריך proxy. הפתרון הכי קל — **Cloudflare Worker חינמי**:

1. כנס ל-[workers.cloudflare.com](https://workers.cloudflare.com)
2. צור Worker חדש עם הקוד הבא:

```javascript
export default {
  async fetch(request) {
    const url = new URL(request.url)
    const orefUrl = 'https://www.oref.org.il' + url.pathname + url.search
    const resp = await fetch(orefUrl, {
      headers: {
        'Referer': 'https://www.oref.org.il/',
        'X-Requested-With': 'XMLHttpRequest',
      }
    })
    return new Response(resp.body, {
      headers: {
        ...Object.fromEntries(resp.headers),
        'Access-Control-Allow-Origin': '*',
      }
    })
  }
}
```

3. העתק את כתובת ה-Worker (משהו כמו `https://oref-proxy.YOUR.workers.dev`)
4. הוסף קובץ `.env.production` בשורש:

```
VITE_OREF_PROXY=https://oref-proxy.YOUR.workers.dev
```

---

## מבנה הפרויקט

```
src/
├── components/
│   ├── Map/          # שכבות המפה
│   ├── Sidebar/      # פאנל שמאל
│   └── HUD/          # מידע על המפה
├── hooks/            # usePikudHaoref, useOpenSky, useProjectiles
├── services/         # API clients
├── store/            # Zustand state
└── types/            # TypeScript types
```
