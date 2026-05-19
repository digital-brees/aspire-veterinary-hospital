# 301 Redirect Map — Aspire Veterinary Hospital migration

When this Astro build replaces the live WordPress site, every old URL (plus anchor-fragment tabs) needs a 301 redirect to its new destination. This preserves earned authority and avoids duplicate-content penalties.

## URL strategy summary

- Old WordPress structure used `/patient-*` slugs and **anchor-fragment tabs** (`/patient-wellness-care/#tab-xxx`) which Google indexed as duplicates of the parent page.
- New structure uses **flat, top-level, SEO-keyword-rich slugs** with a `-germantown-md` location suffix where local SEO matters. Utility pages (`/contact/`, `/our-team/`, `/careers-form/`) stay on short slugs.
- Hub pages (`/patient-wellness-care/`, `/illness-care/`, `/aquatics-fitness-center/`) no longer exist as standalone destinations. They 301 to the first tab or the appropriate split page.

## Top-level page redirects

### Service hub pages

| From (old) | To (new) | Status |
|---|---|---|
| `/patient-wellness-care/` | `/wellness-exams-germantown-md/` | 301 |
| `/illness-care/` | `/urgent-care-germantown-md/` | 301 |
| `/patient-illness-care/` *(legacy alias)* | `/urgent-care-germantown-md/` | 301 |
| `/patient-surgery-dentistry/` | `/surgery-and-dentistry-germantown-md/` | 301 |
| `/geriatric-care/` | `/geriatric-care-germantown-md/` | 301 |
| `/patient-acupuncture-pain-management/` | `/acupuncture-pain-management-germantown-md/` | 301 |
| `/patient-joint-injections-regenerative-medicine/` | `/joint-injections-regenerative-medicine-germantown-md/` | 301 |
| `/working-k9-retired-care/` | `/retired-k9-care-germantown-md/` | 301 |
| `/aquatics-fitness-center/` | `/canine-fitness-and-aquatics-germantown-md/` | 301 |

### Careers + utility pages

| From (old) | To (new) | Status |
|---|---|---|
| `/career-opportunities/` | `/careers-germantown-md/` | 301 |
| `/client-service-representative/` | `/client-service-representative-germantown-md/` | 301 |
| `/sports-medicine-technician/` | `/sports-medicine-technician-germantown-md/` | 301 |
| `/veterinary-assistant-technician-i/` | `/veterinary-assistant-technician-i-germantown-md/` | 301 |
| `/veterinary-technician-ii/` | `/veterinary-technician-ii-germantown-md/` | 301 |
| `/veterinary-technician-iii-iv/` | `/veterinary-technician-iii-iv-germantown-md/` | 301 |
| `/anna-matheny-dvm-cvma-ccrp-cwdp/` | `/our-team/anna-matheny-dvm-cvma-ccrp-cwdp/` | 301 |

### Pages that keep their slug

| URL | Notes |
|---|---|
| `/careers-form/` | Same slug, new custom HTML form posting to JotForm 261376609844164. |
| `/contact/` | New dedicated page; old footer-anchor `#footer` link removed from header. |

## Wellness Care — anchor-fragment redirects

These were the "tabs" on `/patient-wellness-care/` — anchor links Google indexed as the same page. Each now has its own indexable flat-slug page.

| From (old anchor) | To (new) | Status |
|---|---|---|
| `/patient-wellness-care/#tab-cdc1a721d3e4aababd5` *(Examinations)* | `/wellness-exams-germantown-md/` | 301 |
| `/patient-wellness-care/#tab-269ddc6ba15fc16845d` *(Vaccinations)* | `/vaccinations-germantown-md/` | 301 |
| `/patient-wellness-care/#tab-7cdf3086c78e8121de4` *(Preventative Medications)* | `/preventative-care-germantown-md/` | 301 |
| `/patient-wellness-care/#tab-ee2a1e391e69dc5065c` *(Laboratory Diagnostics)* | `/wellness-laboratory-diagnostics-germantown-md/` | 301 |
| `/patient-wellness-care/#tab-e82b14c0969fb7a42dc` *(Imaging Diagnostics)* | `/wellness-imaging-diagnostics-germantown-md/` | 301 |
| `/patient-wellness-care/#tab-478b75565ef354e52ca` *(Routine Dental Cleaning)* | `/dog-dental-care-germantown-md/` | 301 |

## Illness Care — anchor-fragment redirects

| From (old anchor) | To (new) | Status |
|---|---|---|
| `/illness-care/#tab-616fdf9856235ff7f40` *(Urgent Care)* | `/urgent-care-germantown-md/` | 301 |
| `/illness-care/#tab-21d3c62ff63dd39814d` *(Chronic Care)* | `/chronic-care-germantown-md/` | 301 |
| `/illness-care/#tab-291c6350c918ca27698` *(Illness Laboratory Diagnostics)* | `/illness-laboratory-diagnostics-germantown-md/` | 301 |
| `/illness-care/#tab-5fac3cae31dfa6112a9` *(Illness Imaging Diagnostics)* | `/illness-imaging-diagnostics-germantown-md/` | 301 |

## Fitness, Rehab & Aquatics — content split

The combined live `/aquatics-fitness-center/` page was split into two dedicated pages. No anchor tabs existed on the live page, so a single redirect to the fitness-and-aquatics page is the default. Manual links to rehab content should be updated to point at `/canine-rehabilitation-germantown-md/`.

| From (old) | To (new) | Status |
|---|---|---|
| `/aquatics-fitness-center/` | `/canine-fitness-and-aquatics-germantown-md/` | 301 |

> ⚠️ **Anchor fragments and 301s.** Server-side 301s only act on the path before the `#`. The browser strips the fragment before sending the request, so the server sees `/patient-wellness-care/` and 301s the user to `/wellness-exams-germantown-md/`. To get them to the *correct sub-page*, a tiny JS snippet needs to live on the landing page to detect the inbound `#tab-xxx` value and forward them. Patterns below.

## Inbound-fragment forwarder — Wellness landing page

Drop this into `/wellness-exams-germantown-md/`:

```html
<script>
  (function() {
    const map = {
      'tab-cdc1a721d3e4aababd5': '/wellness-exams-germantown-md/',
      'tab-269ddc6ba15fc16845d': '/vaccinations-germantown-md/',
      'tab-7cdf3086c78e8121de4': '/preventative-care-germantown-md/',
      'tab-ee2a1e391e69dc5065c': '/wellness-laboratory-diagnostics-germantown-md/',
      'tab-e82b14c0969fb7a42dc': '/wellness-imaging-diagnostics-germantown-md/',
      'tab-478b75565ef354e52ca': '/dog-dental-care-germantown-md/'
    };
    const hash = location.hash.slice(1);
    if (map[hash] && map[hash] !== location.pathname) location.replace(map[hash]);
  })();
</script>
```

## Inbound-fragment forwarder — Illness landing page

Drop this into `/urgent-care-germantown-md/`:

```html
<script>
  (function() {
    const map = {
      'tab-616fdf9856235ff7f40': '/urgent-care-germantown-md/',
      'tab-21d3c62ff63dd39814d': '/chronic-care-germantown-md/',
      'tab-291c6350c918ca27698': '/illness-laboratory-diagnostics-germantown-md/',
      'tab-5fac3cae31dfa6112a9': '/illness-imaging-diagnostics-germantown-md/'
    };
    const hash = location.hash.slice(1);
    if (map[hash] && map[hash] !== location.pathname) location.replace(map[hash]);
  })();
</script>
```

## Apache `.htaccess` snippet (for WordPress/Avada)

```apache
# Service hubs
Redirect 301 /patient-wellness-care/                       /wellness-exams-germantown-md/
Redirect 301 /illness-care/                                /urgent-care-germantown-md/
Redirect 301 /patient-illness-care/                        /urgent-care-germantown-md/
Redirect 301 /patient-surgery-dentistry/                   /surgery-and-dentistry-germantown-md/
Redirect 301 /geriatric-care/                              /geriatric-care-germantown-md/
Redirect 301 /patient-acupuncture-pain-management/         /acupuncture-pain-management-germantown-md/
Redirect 301 /patient-joint-injections-regenerative-medicine/  /joint-injections-regenerative-medicine-germantown-md/
Redirect 301 /working-k9-retired-care/                     /retired-k9-care-germantown-md/
Redirect 301 /aquatics-fitness-center/                     /canine-fitness-and-aquatics-germantown-md/

# Careers + jobs
Redirect 301 /career-opportunities/                        /careers-germantown-md/
Redirect 301 /client-service-representative/               /client-service-representative-germantown-md/
Redirect 301 /sports-medicine-technician/                  /sports-medicine-technician-germantown-md/
Redirect 301 /veterinary-assistant-technician-i/           /veterinary-assistant-technician-i-germantown-md/
Redirect 301 /veterinary-technician-ii/                    /veterinary-technician-ii-germantown-md/
Redirect 301 /veterinary-technician-iii-iv/                /veterinary-technician-iii-iv-germantown-md/

# Team
Redirect 301 /anna-matheny-dvm-cvma-ccrp-cwdp/             /our-team/anna-matheny-dvm-cvma-ccrp-cwdp/

# Note: anchor fragments handled by the JS forwarders above (servers can't see #fragments)
```

## Nginx alternative

```nginx
# Service hubs
rewrite ^/patient-wellness-care/?$                              /wellness-exams-germantown-md/ permanent;
rewrite ^/illness-care/?$                                       /urgent-care-germantown-md/    permanent;
rewrite ^/patient-illness-care/?$                               /urgent-care-germantown-md/    permanent;
rewrite ^/patient-surgery-dentistry/?$                          /surgery-and-dentistry-germantown-md/ permanent;
rewrite ^/geriatric-care/?$                                     /geriatric-care-germantown-md/ permanent;
rewrite ^/patient-acupuncture-pain-management/?$                /acupuncture-pain-management-germantown-md/ permanent;
rewrite ^/patient-joint-injections-regenerative-medicine/?$     /joint-injections-regenerative-medicine-germantown-md/ permanent;
rewrite ^/working-k9-retired-care/?$                            /retired-k9-care-germantown-md/ permanent;
rewrite ^/aquatics-fitness-center/?$                            /canine-fitness-and-aquatics-germantown-md/ permanent;

# Careers + jobs
rewrite ^/career-opportunities/?$                               /careers-germantown-md/ permanent;
rewrite ^/client-service-representative/?$                      /client-service-representative-germantown-md/ permanent;
rewrite ^/sports-medicine-technician/?$                         /sports-medicine-technician-germantown-md/ permanent;
rewrite ^/veterinary-assistant-technician-i/?$                  /veterinary-assistant-technician-i-germantown-md/ permanent;
rewrite ^/veterinary-technician-ii/?$                           /veterinary-technician-ii-germantown-md/ permanent;
rewrite ^/veterinary-technician-iii-iv/?$                       /veterinary-technician-iii-iv-germantown-md/ permanent;

# Team
rewrite ^/anna-matheny-dvm-cvma-ccrp-cwdp/?$                    /our-team/anna-matheny-dvm-cvma-ccrp-cwdp/ permanent;
```

## What to verify after redirects ship

1. Old URL in browser → lands on new URL with 301 status (use `curl -I` or browser devtools)
2. Old anchor URL (`/patient-wellness-care/#tab-269ddc6ba15fc16845d`) → lands on `/vaccinations-germantown-md/`
3. Search Console "Coverage" report: confirm old URLs marked as "Page with redirect" within 30 days
4. Internal site search and any hardcoded links updated to new URLs
5. Sitemap regenerated with new URLs

## Still pending (build before deploy)

These pages exist in the live WordPress site but are not yet built in the Astro project. Once they are, add their redirects here.

- `/about/` — pending content from stakeholder

## Pages that keep their slug (in addition to those listed above)

| URL | Notes |
|---|---|
| `/cherry-payment-plans/` | Same slug as live. Custom HTML page that mounts the Cherry widget via `_hw("init", { slug: 'aspire-veterinary-hospital', ... })`. No redirect needed since URL is unchanged. |
