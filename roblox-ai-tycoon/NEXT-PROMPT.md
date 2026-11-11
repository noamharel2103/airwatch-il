# פרומפט להמשך (להדביק בצ'אט חדש)

תמשיך לבנות את המשחק שלי ב-Roblox: **FRONTIER**, טייקון של חברת AI (שם זמני). תענה לי בעברית. אני רוצה שהמשחק יהיה **נקי, פשוט ויפה, לא משוגע**.

## איפה הכול
- **קוד:** `C:\MinecraftServer\airwatch-il\roblox-ai-tycoon\src`
  - GitHub: `noamharel2103/airwatch-il`, ענף `claude/blissful-tesla-86xnws`
  - תעשה commit ו-push אחרי כל שינוי.
- **Studio:** Place1, כבר מחובר דרך ה-MCP `Roblox_Studio`.
- **מבנה:**
  - `src/shared/` → ReplicatedStorage.Shared: נתונים וחישובים. Labs, Hardware, Staff, TrainingOptions, TrainingMath, Benchmarks, ReactionTemplates, IncidentTemplates, Research, Catalog, Config, Format, Assets.
  - `src/server/` → ServerScriptService: Main.server, ו-Modules (Game, Launch, Saves).
  - `src/client/` → StarterPlayerScripts: Main.client, ו-ClientModules (UI, Net, Shell, Title, Reveal, Playground, AppLab, AppParts, AppTeam, AppBank, AppSocial, AppMail, AppCompany).
- **סנכרון ל-Studio (כמו Rojo קטן):**
  1. `python tools/manifest.py`
  2. שרת מקומי מתוך `src`: `python -m http.server 34873 --bind 127.0.0.1`
  3. ב-Studio, **במצב Edit בלבד** (לעצור Play קודם): `require(game.ServerStorage.DevSync:Clone())()`
- **חדרי המשרד:** נבנים ב-`tools/build_world.luau`, שמותקן ב-ServerStorage.BuildWorld. מריצים עם `require(game.ServerStorage.BuildWorld:Clone())()`.
- **ציור תמונות:** `tools/art/make_art.py`
  - מצייר SVG, ממיר ל-PNG עם `vectorcraft-cli convert`, ושומר ב-`src/_assets`.
  - מעלים ל-Roblox עם הכלי `upload_image`, לכתובת `http://127.0.0.1:34873/_assets/NAME.png`.
  - שמים את ה-id ב-`src/shared/Assets.luau`.
  - VectorCraft, FigCraft ו-PhotoCraft מותקנים ב-`%LOCALAPPDATA%\Programs\ArtCraft\*` ורשומים כשרתי MCP. EffectCraft מחובר גם הוא.

## מה המשחק כבר עושה
- **פתיחה:** מסך עם 3 תיקיות שמירה על רקע עיר בלוקית. בוחרים שם ועיר (6 ערים עם יתרונות שונים). מתחילים עם $30K ולפטופ, בינואר 2023.
- **החדר:** בלי הליכה. מצלמה קבועה בזווית "בית בובות" על חדר קטן. לוחצים על חפצים: לפטופ פותח את המחשב, ארון GPU פותח את Parts, הלוח פותח את Goals, הדלת פותחת את Company. יש 6 שלבי משרד. GPU ועובדים מופיעים פיזית.
- **HUD:** הכסף משמאל, התאריך ו-II/x1/x2/x4 מימין, וחדשות למעלה. ה-HUD נשאר גלוי גם כשהמחשב פתוח. ב-x4 יש יותר תקלות.
- **מחשב עם אפליקציות:**
  - **Lab:** Train פשוט (גודל, במה טוב, כוחות-על), Models (צ'אט עם המודל, בדיקת בטיחות, דחייה, RELEASE, עדכונים) ו-Leaderboard.
  - **Parts:** GPU אמיתיים לפי שנה, שכירה או קנייה, ותקרת הקצאה.
  - **Team:** צ'אט עם העובדים וגיוס.
  - **Bank:** שווי, גרפים, משקיעים והלוואות.
  - **Social:** כל התגובות.
  - **Mail:** החלטות.
  - **Goals.**
  - **Company:** האפליקציה שלך, מעבר משרד וקניית מתחרים.
- **השקה:** ספירה לאחור, בנצ'מרקים אחד אחד מול SOTA, Elo, ציון עם "למה", ואז "The internet reacts": 20 טיפוסים, כ-600 תבניות, X, Reddit, HN ועיתונות.
- **אירועים:** jailbreak, מודל שמנסה לברוח, contamination, השבתות. לכל אחד יש החלטות.
- **מתחרים אמיתיים:** 76 שחרורים לפי התאריכים האמיתיים מ-2022 עד 2026, ואחרי זה מודלים עתידיים.
- **מחקר:** רץ לבד ברקע. לא להחזיר את לשונית Research.

## מה אני רוצה (חשוב)
- **סגנון:** בלוקי ונקי בסגנון סימולטור של Roblox.
  - קו מתאר כהה עבה, צבעים חיים אבל לא בוהקים, וטקסט גדול וקריא.
  - **לא** לבן מסנוור, **לא** כהה ועמום, **לא** "AI slop".
  - להשתמש בתמונות מצוירות, ולא במסגרות מקוד, כשאפשר.
  - להשתמש בסקילים `roblox-gui` ו-`roblox-collaboration-mode`.
- **פשטות:** לא להעמיס אפשרויות. מעט כפתורים גדולים. כל דבר מתקדם מוסתר.
- **כיף לפני דיוק:** אחרי שעה-שעתיים אני אמור להיות בין החברות המובילות.
- **התקדמות:** מתחילים בחדר קטן, עוברים לחדר גדול יותר, ובסוף קונים חברות.
- **בלי אימוג'י** בתוך המשחק.

## הצעדים הבאים
1. **9-slice בכפתורים:** תמונת הכפתור `Assets.button` עדיין לא בשימוש.
   - TextButton לא יכול לשים תמונה מאחורי הטקסט שלו.
   - צריך כפתור שהוא ImageButton עם 9-slice ועם TextLabel ילד, כך ש-`.Text` ימשיך לעבוד (wrapper או proxy).
2. **ציור נוסף:** בלוגו, ברקע לדסקטופ ובתמונות בתוך החדר (מסך הלפטופ, פוסטרים).
3. **שמירה:** השמירה עובדת רק אחרי Publish והפעלת Studio API access. להגיד לי מתי לעשות את זה.
4. **איזון:** להריץ סימולציית בוט של כ-1,300 ימים בתוך Play/Server ולכוון כך שאגיע לטופ-3 בערך ב-2025. הנוסחאות ב-Game.luau, Launch.luau ו-Config.luau.
5. **סאונד:** קליק בכפתורים, ספירה לאחור, קונפטי ב-SOTA. כל הסאונדים ב-SoundService.
6. **בדיקה:** אחרי כל שינוי, playtest וצילום מסך. ללחוץ לפי `AbsolutePosition` של הכפתור. צילומי המסך מוקטנים ביחס למסך האמיתי.

## מלכודות שכבר נתקלתי בהן
- צריך לעצור Play לפני סנכרון. אחרת מופיעה השגיאה "Edit datamodel is not available".
- UIGradient על TextButton צובע גם את הטקסט. לא להשתמש.
- `GetPropertyChangedSignal` נדחה (deferred), אז צריך להתעלם מההד של כתיבה שלך.
- תמונות של יוצרים אחרים מהחנות לא נטענות במקום לא מפורסם. תמונות שאני מעלה כן נטענות.
- פלאגין לא יכול לשנות את `Lighting.Technology`. אני צריך לשים Future ידנית.
- ב-execute_luau ל-Server/Client יש require cache נפרד, כך שאי אפשר לגשת ל-state של המשחק. בודקים דרך הכפתורים או דרך הרימוטים.
