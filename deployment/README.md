# Deployment artifacts

Files in this folder are for the host / DevOps team applying the migration
from the live WordPress site to the new Astro build.

## Files

### `.htaccess`
Apache redirect map. Drop the contents into the `.htaccess` file at the WordPress
site root, BEFORE the `# BEGIN WordPress` block. Reload Apache (or wait for it
to pick up the change — `.htaccess` is read per request).

Verify with `curl -I https://aspirevethospital.com/patient-wellness-care/` — should
return `HTTP/1.1 301 Moved Permanently` with `Location: /wellness-exams-germantown-md/`.

### `nginx-redirects.conf`
Same rules in Nginx syntax. Drop the `rewrite` lines into the appropriate `server { }`
block and run `nginx -t && systemctl reload nginx`.

### Anchor-fragment JS forwarders
For old anchor-tab URLs (e.g. `/patient-wellness-care/#tab-cdc1a721d3e4aababd5`), see
the JS snippets in `../REDIRECTS.md`. These need to live on the destination Astro
pages (`/wellness-exams-germantown-md/` and `/urgent-care-germantown-md/`) so they
intercept inbound `#tab-xxx` hashes and forward to the correct sub-page.

## Verification checklist (post-deploy)

1. `curl -I` each old URL → confirm 301 + correct `Location:` header
2. Click an old `/patient-wellness-care/#tab-xxx` URL in a browser → should land on the right sub-page
3. Search Console "Coverage" report after 30 days → old URLs should be marked "Page with redirect"
4. Update the site sitemap submission in Search Console with the new sitemap URL
