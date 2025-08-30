# Phase 1: Project Setup & Core Infrastructure

## 📋 Overview

Setup awal project Next.js 14 dengan konfigurasi dasar dan infrastruktur core untuk Progressive Web App (PWA).

## 🎯 Objectives

- Next.js 14 project setup
- TypeScript configuration
- Tailwind CSS setup
- Component library foundation
- PWA configuration
- Development environment setup

## 📁 Files Structure

```
phase-1/
├── 01-nextjs-setup.md
├── 02-typescript-configuration.md
├── 03-tailwind-css-setup.md
├── 04-component-library.md
├── 05-pwa-configuration.md
└── 06-development-tools.md
```

## 🔧 Implementation Points

### Point 1: Next.js 14 Setup

**Subpoints:**

- Install Next.js 14 dengan TypeScript
- Konfigurasi App Router
- Setup project structure
- Konfigurasi environment variables
- Setup development server
- Konfigurasi build process

**Files:**

- `package.json` - Dependencies
- `next.config.js` - Next.js configuration
- `.env.example` - Environment template
- `app/layout.tsx` - Root layout
- `app/page.tsx` - Home page

### Point 2: TypeScript Configuration

**Subpoints:**

- Setup TypeScript compiler options
- Konfigurasi strict mode
- Setup type definitions
- Konfigurasi path mapping
- Setup ESLint untuk TypeScript
- Konfigurasi Prettier

**Files:**

- `tsconfig.json` - TypeScript configuration
- `.eslintrc.json` - ESLint configuration
- `.prettierrc` - Prettier configuration
- `types/` - Custom type definitions

### Point 3: Tailwind CSS Setup

**Subpoints:**

- Install dan konfigurasi Tailwind CSS
- Setup custom color palette
- Konfigurasi typography system
- Setup component utilities
- Konfigurasi responsive design
- Setup dark mode support

**Files:**

- `tailwind.config.js` - Tailwind configuration
- `app/globals.css` - Global styles
- `styles/` - Custom styles
- `components/ui/` - UI components

### Point 4: Component Library Foundation

**Subpoints:**

- Setup component architecture
- Implementasi base components
- Setup component documentation
- Konfigurasi Storybook (optional)
- Setup component testing
- Implementasi design system

**Files:**

- `components/base/` - Base components
- `components/ui/` - UI components
- `components/layout/` - Layout components
- `lib/utils.ts` - Utility functions

### Point 5: PWA Configuration

**Subpoints:**

- Install Next PWA
- Setup service worker
- Konfigurasi manifest.json
- Setup offline functionality
- Konfigurasi push notifications
- Setup PWA testing

**Files:**

- `next.config.js` - PWA configuration
- `public/manifest.json` - PWA manifest
- `public/icons/` - PWA icons
- `app/sw.js` - Service worker

## 📦 Dependencies

### Core Dependencies

```json
{
  "next": "^14.0.0",
  "react": "^18.0.0",
  "react-dom": "^18.0.0",
  "typescript": "^5.0.0"
}
```

### UI Dependencies

```json
{
  "tailwindcss": "^3.3.0",
  "autoprefixer": "^10.4.0",
  "postcss": "^8.4.0",
  "@headlessui/react": "^1.7.0",
  "@heroicons/react": "^2.0.0"
}
```

### Development Dependencies

```json
{
  "@types/node": "^20.0.0",
  "@types/react": "^18.0.0",
  "@types/react-dom": "^18.0.0",
  "eslint": "^8.0.0",
  "eslint-config-next": "^14.0.0",
  "prettier": "^3.0.0",
  "next-pwa": "^5.6.0"
}
```

## 📁 Project Structure

```
frontend/
├── app/
│   ├── layout.tsx
│   ├── page.tsx
│   └── globals.css
├── components/
│   ├── base/
│   ├── ui/
│   └── layout/
├── lib/
│   ├── utils.ts
│   └── constants.ts
├── types/
│   └── index.ts
├── styles/
│   └── components.css
├── public/
│   ├── manifest.json
│   └── icons/
├── package.json
├── tsconfig.json
├── tailwind.config.js
└── next.config.js
```

## 🎨 Design System Foundation

### Color Palette

```css
:root {
  --primary: #3b82f6;
  --primary-dark: #2563eb;
  --secondary: #10b981;
  --accent: #f59e0b;
  --error: #ef4444;
  --success: #10b981;
  --warning: #f59e0b;
  --gray-50: #f9fafb;
  --gray-100: #f3f4f6;
  --gray-900: #111827;
}
```

### Typography

```css
.font-inter {
  font-family: "Inter", sans-serif;
}

.text-heading-1 {
  font-size: 2.25rem;
  font-weight: 700;
  line-height: 1.2;
}

.text-body {
  font-size: 1rem;
  font-weight: 400;
  line-height: 1.5;
}
```

### Spacing System

```css
.space-xs {
  gap: 0.25rem;
}
.space-sm {
  gap: 0.5rem;
}
.space-md {
  gap: 1rem;
}
.space-lg {
  gap: 1.5rem;
}
.space-xl {
  gap: 2rem;
}
```

## 🚀 Getting Started

1. Clone repository
2. Run `npm install`
3. Copy `.env.example` to `.env.local`
4. Configure environment variables
5. Run `npm run dev`
6. Open http://localhost:3000

## 📚 Development Commands

```bash
npm run dev          # Start development server
npm run build        # Build for production
npm run start        # Start production server
npm run lint         # Run ESLint
npm run type-check   # Run TypeScript check
npm run test         # Run tests
```

## ✅ Success Criteria

- [ ] Next.js 14 berhasil terinstall dan berjalan
- [ ] TypeScript dapat digunakan tanpa error
- [ ] Tailwind CSS berfungsi dengan baik
- [ ] Component library dapat digunakan
- [ ] PWA dapat diinstall
- [ ] Development environment terkonfigurasi
- [ ] Build process berjalan lancar
- [ ] Performance metrics memenuhi standar

## 📚 Documentation

- Next.js 14 Documentation
- TypeScript Configuration Guide
- Tailwind CSS Documentation
- PWA Implementation Guide
- Component Architecture Guide
