# Aspire Veterinary Hospital — Astro / Neuron-ready

A complete Astro project for Aspire Veterinary Hospital. Drops into Neuron's monorepo as `sites/aspire-veterinary-hospital/`, or runs standalone via `npm install && npm run dev`.

## What's here

```
aspire-neuron/
├── astro.config.mjs           ← Astro project config
├── package.json
├── tsconfig.json
├── src/
│   ├── components/
│   │   ├── AspireHeader.astro            ← shared site header (fixed, sticky-shrink, dropdown nav)
│   │   ├── AspireFooter.astro            ← shared site footer
│   │   ├── AspireHero.astro              ← homepage hero
│   │   ├── AspireMindset.astro           ← homepage mindset section (Vision/Mission/Approach)
│   │   ├── AspireDoctorSpotlight.astro   ← homepage doctor block
│   │   ├── AspireCareers.astro           ← homepage careers CTA
│   │   ├── AspireServiceArea.astro       ← homepage "Rooted in Maryland" section
│   │   ├── ServiceHero.astro             ← image hero with dark overlay (service pages)
│   │   ├── ServiceTabStrip.astro         ← sticky tab strip for sibling service navigation
│   │   ├── SpeciesToggle.astro           ← Dog/Cat toggle (vaccinations)
│   │   ├── PawList.astro                 ← bulleted list with paw bullets, 1- or 2-col
│   │   ├── SplitSection.astro            ← image (framed) + content side-by-side
│   │   └── HospitalCard.astro            ← emergency hospital referral block
│   ├── layouts/
│   │   ├── BaseLayout.astro              ← head + body + header + footer wrapper
│   │   └── ServiceLayout.astro           ← BaseLayout + service hero + tab strip + content slot
│   ├── pages/                                                          ← flat top-level routes (SEO-keyword-rich slugs)
│   │   ├── index.astro                                               ← /
│   │   ├── wellness-exams-germantown-md.astro                        ← /wellness-exams-germantown-md/  (Wellness Care landing)
│   │   ├── vaccinations-germantown-md.astro                          ← /vaccinations-germantown-md/
│   │   ├── preventative-care-germantown-md.astro                     ← /preventative-care-germantown-md/
│   │   ├── wellness-laboratory-diagnostics-germantown-md.astro       ← /wellness-laboratory-diagnostics-germantown-md/
│   │   ├── wellness-imaging-diagnostics-germantown-md.astro          ← /wellness-imaging-diagnostics-germantown-md/
│   │   ├── dog-dental-care-germantown-md.astro                       ← /dog-dental-care-germantown-md/
│   │   ├── urgent-care-germantown-md.astro                           ← /urgent-care-germantown-md/  (Illness Care landing)
│   │   ├── chronic-care-germantown-md.astro                          ← /chronic-care-germantown-md/
│   │   ├── illness-laboratory-diagnostics-germantown-md.astro        ← /illness-laboratory-diagnostics-germantown-md/
│   │   └── illness-imaging-diagnostics-germantown-md.astro           ← /illness-imaging-diagnostics-germantown-md/
│   └── styles/
│       └── tokens.css                    ← design tokens + base body/heading/content styles
└── public/                                ← static assets (currently empty; imgs hosted on Aspire CDN)
```

## Running locally

```bash
cd outputs/aspire-neuron
npm install
npm run dev
```

Then open http://localhost:4321 (or whatever port Astro picks).

## Dropping into Neuron's monorepo

1. **Copy this folder** to `sites/aspire-veterinary-hospital/` (or whatever convention Neuron's repo uses).
2. **Pull in the design tokens** — either keep `src/styles/tokens.css` as-is, or merge the CSS variables into Neuron's existing site config.
3. **Reuse the shared components** — `AspireHeader.astro`, `AspireFooter.astro`, etc. are vanilla Astro and have no external dependencies. They reference the CSS variables exported by `tokens.css`.
4. **The service components** (`ServiceHero`, `ServiceTabStrip`, `SpeciesToggle`, `PawList`, `SplitSection`, `HospitalCard`) are designed to be **reusable across the Neuron fleet** — every prop is typed and parameterized. Drop them into `packages/components/src/` if you want them available to all sites.

## Component prop interfaces (TypeScript)

All components export typed `Props` interfaces:

```ts
// ServiceHero
interface Props {
  bgImage: string;
  eyebrow?: string;
  h1: string;
  lede: string;
}

// ServiceTabStrip
interface Tab { slug: string; label: string; href: string; }
interface Props {
  tabs: Tab[];
  activeSlug?: string;
  ariaLabel?: string;
}

// SpeciesToggle
interface Props {
  label1: string;
  label2: string;
  pane1Id?: string;
  pane2Id?: string;
}
// Uses named slots: <Fragment slot="pane-1"> / <Fragment slot="pane-2">

// PawList
interface Props {
  items: string[];
  cols?: 1 | 2;
}

// SplitSection
interface Props {
  image: string;
  imageAlt?: string;
}
// Content via default slot

// HospitalCard
interface Props {
  name: string;
  addressLines: string[];
  addressHref: string;
  phone: string;
  phoneDisplay?: string;
  website: string;
  websiteDisplay?: string;
  hours: string;
}
```

## SEO

Every service page has:

- Unique `<title>` (50–60 chars, includes service + Germantown)
- Unique meta description (140–160 chars)
- Single `<h1>` with primary keyword
- H2/H3 hierarchy (H2 tan, H3 dark gray — matches live Avada/Fusion typography)
- `MedicalProcedure` schema (sub-pages) or `Service` schema (hubs) with `provider` → Aspire as `VeterinaryCare`
- `<link rel="canonical">` self-referencing
- OpenGraph + Twitter card meta
- Image `alt` attributes
- Active state in Patient Services dropdown for the current service (via `currentService` prop on `AspireHeader`)

## URL structure

All service URLs are flat, top-level, SEO-keyword-rich slugs with a `-germantown-md` location suffix (e.g. `/wellness-exams-germantown-md/`, `/urgent-care-germantown-md/`). No `/services/` prefix and no separate hub pages — the "Wellness Care" and "Illness Care" nav items land on the first tab in their category. `trailingSlash: 'always'` is set in `astro.config.mjs`.

## Redirects

When this ships, the old WordPress URLs (and their anchor-fragment tabs) need 301s to the new flat slugs. See `REDIRECTS.md` in this folder. The map covers anchor-fragment URLs too — the JS forwarder pattern in that doc handles `/patient-wellness-care/#tab-xxx` and `/illness-care/#tab-xxx` style URLs that servers can't see.

## Going forward

The remaining sections from the new sitemap still need to be built — each one becomes a new Astro page in `src/pages/`, reusing the existing components:

- **About** — `/about/`, `/our-team/`, `/reactive-dog-care-germantown-md/`
- **Surgery** — `/surgery-germantown-md/` (single page with internal sections: soft tissue, ortho, spay/neuter)
- **Rehab & Recovery** — `/canine-rehabilitation-germantown-md/` (hub), `/dog-physical-therapy-germantown-md/`, `/post-surgical-rehab-germantown-md/`
- **Aquatics & Fitness** — `/underwater-treadmill-for-dogs-germantown-md/`, `/canine-hydrotherapy-germantown-md/`

The old WP categories that don't appear on the new sitemap (Geriatric Care, Acupuncture & Pain Management, Joint Injections & Regenerative Medicine, Retired K9 Care) are TBD — confirm with stakeholder whether they're being deprecated, folded into Rehab, or kept as legacy pages.

No more static HTML — Astro-native from now on.
