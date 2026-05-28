# Texnoptom ERP

Texno Optom Gaming uchun ombor, sotuv va moliya boshqaruvi tizimi. Next.js 14 + Supabase + RBAC.

## Funksiyalar

- **Dashboard** — kunlik ko'rsatkichlar
- **Ombor (Warehouse)** — katalog, kirim (nakladnoy), spisaniya, qoldiq analitika (ABC/XYZ), tarix, hamkorlar
- **Sotuv** — chek yaratish va PDF eksport
- **Moliya** — to'lov kalendari
- **RBAC** — admin va skladchi rollari, Supabase RLS bilan server-side himoyalangan

## Texnik Stack

| Qatlam | Versiya |
|---|---|
| Next.js | 14.2.15 (App Router) |
| React | 18.3.1 |
| TypeScript | 5.5+ |
| Supabase | 2.45+ |
| lucide-react | 0.469+ |
| Node.js | 20.x (LTS) |

## Lokal Ishga Tushirish

### 1. Bog'liqliklarni o'rnatish

```bash
npm install
```

### 2. Environment Variables

`.env.example` ni nusxalab `.env.local` yarating:

```bash
cp .env.example .env.local
```

`.env.local` ichida Supabase ma'lumotlarini to'ldiring (Supabase Dashboard → Settings → API):

```
NEXT_PUBLIC_SUPABASE_URL=https://your-project-ref.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-public-key
```

### 3. Supabase RBAC sozlash

Supabase Dashboard → SQL Editor'ga o'ting va `supabase_rbac.sql` faylning to'liq matnini paste qilib **Run** bosing. Bu:

- `profiles` jadvalini yaratadi
- Yangi user ro'yxatdan o'tganda avtomatik profil yaratish trigger'ini o'rnatadi
- Barcha biznes jadvallarga RLS policy'larni qo'llaydi (admin → to'liq, skladchi → faqat o'qish + insert)

### 4. Ishga tushirish

```bash
npm run dev
```

http://localhost:3000 ochiladi.

## GitHub'ga Push va Vercel Deploy

### Variant A: Avtomat (deploy.sh orqali)

`deploy.sh` faylni oching va quyidagi qiymatlarni to'ldiring:

```bash
GITHUB_USER="sizning-username"
REPO_NAME="texnoptom-erp"        # GitHub'da yaratgan yangi repo nomi
GITHUB_PAT="ghp_xxxxxxxxxxxxx"   # Token: github.com/settings/tokens
```

So'ng:

```bash
bash deploy.sh
```

### Variant B: Qo'lda

```bash
git init
git add .
git commit -m "initial release"
git branch -M main
git remote add origin https://github.com/USER/REPO.git
git push -u origin main
```

### Vercel Deploy

1. https://vercel.com/new ga o'ting
2. GitHub repo'ni import qiling
3. **Framework Preset:** Next.js (avtomatik aniqlanadi)
4. **Root Directory:** `./` (bo'sh qoldiring)
5. **Environment Variables** qo'shing:
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`
6. **Deploy** bosing

### Deployment Protection

Sayt **public** bo'lishi uchun:

- Vercel → Project → Settings → **Deployment Protection**
- "Vercel Authentication" → **Disabled** (yoki "Only Preview Deployments")

## Loyiha Strukturasi

```
texnoptom-erp/
├── src/
│   ├── app/
│   │   ├── layout.tsx          # Root layout + AuthProvider
│   │   ├── page.tsx            # Dashboard (/)
│   │   ├── globals.css         # Global stillar
│   │   ├── login/page.tsx
│   │   ├── sales/page.tsx
│   │   ├── warehouse/page.tsx  # Asosiy biznes mantiq
│   │   └── finance/page.tsx
│   ├── components/
│   │   ├── Sidebar.tsx         # Nav + user card
│   │   ├── ClientLayout.tsx    # Route guard
│   │   └── RoleGate.tsx        # UI gating wrapper
│   ├── context/
│   │   └── AuthContext.tsx     # Auth state + RBAC
│   └── utils/
│       └── supabase.ts         # Supabase client
├── supabase_rbac.sql           # SQL schema + RLS policies
├── deploy.sh                   # One-shot deploy
├── next.config.mjs             # Vercel-safe config
├── tsconfig.json
├── .eslintrc.json
├── package.json
└── .env.example
```

## RBAC — Rollar

| Rol | Yaratish | Tahrirlash | O'chirish | Spisaniya |
|---|---|---|---|---|
| **admin** | ✅ | ✅ | ✅ | ✅ |
| **skladchi** | ✅ | ❌ | ❌ | ❌ |

Rol manbai — Supabase'dagi `profiles.role` ustuni. Server tomonda RLS policy'lar haqiqiy himoya beradi; UI faqat tugmalarni yashiradi.

**Adminni belgilash:**

```sql
update public.profiles set role = 'admin' where email = 'siz@example.com';
```

## Vercel Deploy'da Yo'l Qo'yilmagan Xatolar

Ushbu loyiha quyidagi muammolardan himoyalangan:

1. ✅ `next.config.mjs` (NOT `.ts` — Next 14 `.ts` config qabul qilmaydi)
2. ✅ `.eslintrc.json` (NOT flat config — eslint v8 + eslint-config-next 14 mos)
3. ✅ `engines.node: 20.x` + `.nvmrc` (Vercel Node 20'ga lock)
4. ✅ React 18.3.1 (React 19 EMAS — lucide-react bilan to'qnashuv)
5. ✅ `LucideIcon` tipi to'g'ri (NOT `React.ComponentType`)
6. ✅ `type` keyword bilan type imports (`isolatedModules` xavfsiz)
7. ✅ Modern lucide-react (^0.469.0 — eski 1.x emas)
8. ✅ `output: 'export'` o'rnatilmagan (SSR ishlaydi)
9. ✅ Tegishli `.gitignore` (`.env`, `node_modules`, `.next` istisno)
10. ✅ Mosligi tekshirilgan barcha lucide ikon nomlari

## License

Private — Texno Optom Gaming ichki foydalanish uchun.
