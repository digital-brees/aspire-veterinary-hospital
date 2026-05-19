import { defineConfig } from 'astro/config';

// Aspire Vet Hospital — Astro config
// Sitemap integration temporarily removed — plugin API mismatch with Astro 4.16
// fails the Vercel build. Reintroduce once @astrojs/sitemap lands a fix, or
// generate sitemap.xml from a build script.
export default defineConfig({
  site: 'https://aspirevethospital.com',
  trailingSlash: 'always',
  build: {
    format: 'directory',
  },
});
