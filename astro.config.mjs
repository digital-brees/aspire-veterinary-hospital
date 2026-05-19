import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

// Aspire Vet Hospital — Astro config
// When merging into Neuron's monorepo, point base/site to the live origin.
export default defineConfig({
  site: 'https://aspirevethospital.com',
  trailingSlash: 'always',
  build: {
    format: 'directory',
  },
  integrations: [
    sitemap({
      // Customize the sitemap output. Default behavior emits every routable page.
      // Each entry inherits the `site` URL above.
      changefreq: 'monthly',
      priority: 0.7,
      lastmod: new Date(),
      // High-value pages get higher priority signals
      serialize(item) {
        // Homepage gets top priority
        if (item.url === 'https://aspirevethospital.com/') {
          item.priority = 1.0;
          item.changefreq = 'weekly';
        }
        // Patient Services landing pages get high priority
        else if (
          item.url.includes('-germantown-md/') &&
          !item.url.includes('representative') &&
          !item.url.includes('technician') &&
          !item.url.includes('careers-')
        ) {
          item.priority = 0.9;
        }
        // Careers + contact + utility
        else if (
          item.url.includes('/careers-germantown-md/') ||
          item.url.includes('/contact/') ||
          item.url.includes('/our-team/')
        ) {
          item.priority = 0.8;
        }
        // Job description pages get lower priority (they change often / less SEO value)
        else if (item.url.includes('-germantown-md/')) {
          item.priority = 0.5;
          item.changefreq = 'weekly';
        }
        return item;
      },
    }),
  ],
});
