# v7 Changelog & Development Report

**Date:** January 24, 2026
**Developer:** Claude (AI Assistant)
**Live URL:** https://koushik1161.github.io

---

## Summary

Created v7 of Koushik Jaladi's personal website, fixing critical bugs from v6, updating branding, and adding new features including a ChatGPT 2025 stats page.

---

## Changes from v6 to v7

### 1. Bug Fixes

#### Writing Page Fix
- **Issue:** The Writing page (`/writing/`) showed "72 articles" but displayed no posts
- **Root Cause:** The `_layouts/writing.html` template used `paginator.posts` which only works on `index.html` files in Jekyll
- **Solution:** Changed to use `site.posts` directly and grouped posts by year for better organization
- **File Modified:** `_layouts/writing.html`

### 2. Branding Updates

#### Name Change
- Changed name from "Koushik Cruz" to "Koushik Jaladi"
- **Files Modified:**
  - `_config.yml` (title, author, default author)
  - `_layouts/home.html` (hero section)
  - `about.md` (contact links)

#### Social Links Updated
- Twitter username: `koushikcruz` → `koushikjaladi`
- **Files Modified:**
  - `_config.yml`
  - `about.md`

#### Contact Email Added
- Added contact email: koushikcruz@gmail.com
- **Files Modified:**
  - `_layouts/home.html` (Connect section)
  - `about.md` (footer)

### 3. New Features

#### ChatGPT 2025 Stats Page
- **New Page:** `/2025/` (`2025.html`)
- **Content:**
  - Introduction with OpenAI account creation date (November 13, 2022)
  - Note about account predating ChatGPT launch (November 30, 2022)
  - Stats images with explanations:
    1. Chat Statistics - usage numbers
    2. The Strategist - ChatGPT persona archetype
    3. Year in Poem - AI-generated poem from conversation themes
    4. Still Life with GPU - AI artwork
  - Closing reflection on 4 years of AI collaboration (since late 2021)

#### Images Added
- **Location:** `assets/images/`
- **Files:**
  - `chat stats-2.png`
  - `The Strategist.png`
  - `year in poem.png`
  - `still-life-gpu.png`

### 4. UI/UX Improvements

#### Writing Page Redesign
- Posts grouped by year with sticky year headers
- Compact post items on mobile (excerpts hidden)
- Full excerpts visible on desktop
- Better visual hierarchy

#### New CSS Added
- `.archive__year-group` - year grouping container
- `.archive__year` - sticky year header
- `.chatgpt-stats` - stats gallery container
- `.stats-card` - individual stat card with hover effects
- `.stats-card--featured` - full-width featured card
- `.stats-explanation` - explanation text styling

---

## File Structure

```
v7/
├── _config.yml              # Site configuration (updated)
├── _layouts/
│   ├── home.html            # Homepage layout (updated)
│   ├── writing.html         # Writing archive layout (fixed)
│   └── ...
├── _posts/                  # 72 blog posts
├── assets/
│   ├── css/
│   │   └── style.css        # Styles (updated with new components)
│   ├── images/              # NEW: ChatGPT stats images
│   │   ├── chat stats-2.png
│   │   ├── The Strategist.png
│   │   ├── year in poem.png
│   │   └── still-life-gpu.png
│   └── js/
├── 2025.html                # NEW: ChatGPT 2025 stats page
├── about.md                 # About page (updated)
├── index.html               # Homepage
├── writing.html             # Writing archive
└── now.md                   # Now page
```

---

## Deployment

### GitHub Repository
- **Repo:** https://github.com/Koushik1161/Koushik1161.github.io
- **Branch:** main
- **Deployment:** GitHub Pages with GitHub Actions

### Commits
1. `Initial commit: v6 personal website` - Base from v6
2. `v7: Fix writing page, add Koushik Jaladi name, add ChatGPT 2025 stats page` - Main v7 changes
3. `Add contact email` - Contact information

---

## Local Development

```bash
cd v7
bundle install
bundle exec jekyll serve --port 4001
```

Site available at: http://127.0.0.1:4001/

---

## Technical Notes

### Jekyll Pagination Limitation
Jekyll's `jekyll-paginate` plugin only works on files named `index.html`. For archive pages like `/writing/`, use `site.posts` directly instead of `paginator.posts`.

### Image Optimization
The ChatGPT stats images are large PNG files. Consider optimizing them for web in the future to improve page load times.

---

## Pages

| Page | URL | Description |
|------|-----|-------------|
| Home | `/` | Hero, recent posts, connect links |
| Writing | `/writing/` | All 72 posts grouped by year |
| About | `/about/` | Bio, philosophy, focus areas |
| Now | `/now/` | Current activities |
| 2025 Stats | `/2025/` | ChatGPT year in review |

---

**Report generated:** January 24, 2026
