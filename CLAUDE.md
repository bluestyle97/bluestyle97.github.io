# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Academic personal website for Jiale Xu, built on the **al-folio** Jekyll theme. Hosted on GitHub Pages at `https://bluestyle97.github.io/`.

This is a lightly-customized fork of upstream al-folio. Most of the repo is untouched theme code and demo content — see "Template leftovers" below. Real edits almost always land in `_bibliography/papers.bib`, `_news/`, `_pages/about.md`, `assets/json/resume.json`, and `assets/img/publication_preview/`.

## Build & Development Commands

### Local development (Docker — recommended)

```bash
docker compose pull       # pulls pinned amirpourmand/al-folio:v0.14.6
docker compose up
# Site at http://localhost:8080, livereload on 35729
```

`docker-compose-slim.yml` uses the `:slim` image (no imagemagick/nbconvert) if you don't need responsive images.

### Local development (Ruby)

```bash
bundle install
bundle exec jekyll serve --livereload
```

Requires ImageMagick's `convert` on PATH (`imagemagick.enabled: true` in `_config.yml` generates responsive `.webp` variants for everything under `assets/img/`). Without it the build fails. Docker is the path of least resistance on Windows.

### Production build

```bash
JEKYLL_ENV=production bundle exec jekyll build
purgecss -c purgecss.config.js
```

### Formatting (CI gate)

```bash
npx prettier --check .    # what .github/workflows/prettier.yml runs
npx prettier --write .
```

Prettier is the only blocking style check. Config in `.prettierrc` (printWidth 150, `@shopify/prettier-plugin-liquid`); `.prettierignore` exempts vendored assets, `_scripts/`, and minified files.

## Deployment

`.github/workflows/deploy.yml` runs on push to `main` (path-filtered — docs-only and workflow-only changes are skipped). It installs imagemagick + nbconvert, builds with `JEKYLL_ENV=production`, purges CSS, then pushes `_site` to the `gh-pages` branch via `github-pages-deploy-action`. Ruby 3.3.5 / Python 3.13.

`bin/deploy` does the same thing manually from a local checkout — rarely needed since CI handles it.

## Architecture

- **Jekyll** (Ruby), config in `_config.yml`. Liquid layouts in `_layouts/`, partials in `_includes/`.
- **Styling**: SCSS in `_sass/`, Bootstrap 5 + MDB. Light/dark theming lives in `_sass/_themes.scss`.
- **Third-party JS/CSS** is configured under `third_party_libraries:` in `_config.yml` (CDN by default; `download: false`).

### Navigation

Only three pages are in the navbar (`nav: true` + `nav_order`): Blog (1), Publications (2), CV (3). `projects`, `repositories`, `teaching`, `books`, `profiles`, and `dropdown` are all `nav: false` — they exist but are unlinked. The homepage is `_pages/about.md` (`permalink: /`, `layout: about`).

### Publications

`_bibliography/papers.bib` → rendered by **jekyll-scholar** through `_layouts/bib.liquid`. Author highlighting comes from `scholar.last_name`/`first_name` in `_config.yml`; co-author hyperlinks come from `_data/coauthors.yml`, keyed by lowercase surname with a `firstname` list to disambiguate.

To add a paper:

1. Add the entry to the **top** of `papers.bib` (rendering order follows file order).
2. Drop the thumbnail in `assets/img/publication_preview/` — `preview={}` is resolved relative to that directory. Existing naming convention: `venue+year_shortname.ext` (e.g. `cvpr2026_meshweaver.png`, `arxiv2025_rolling.gif`).
3. Set `selected={true}` to surface it on the homepage's selected-papers list.

Non-standard fields supported by `bib.liquid`: `abbr` (venue badge), `preview`, `selected`, `bibtex_show`, `abstract`, `website`, `code`, `demo`, `arxiv`, `pdf`, `html`, `supp`, `poster`, `slides`, `video`, `blog`, `award`/`award_name`, `additional_info`, `google_scholar_id`, `inspirehep_id`. **Any custom field must also be listed in `filtered_bibtex_keywords:` in `_config.yml`**, otherwise `_plugins/hide-custom-bibtex.rb` won't strip it and it leaks into the copyable BibTeX popup.

`abbr` doubles as a venue key: matching entries in `_data/venues.yml` give the badge a color and link (unmatched abbrs render as a plain badge, which is the current norm).

### News

`_news/announcement_N.md` — sequentially numbered, `inline: true`, `layout: post`, ordered by the `date` field (not filename). The homepage shows the latest 8 (`announcements.limit` in `_pages/about.md`). Typical practice is to keep appending to the newest announcement file for related items rather than always creating a new one.

### CV page

**The CV renders from `assets/json/resume.json`, not `_data/cv.yml`.** `jekyll-get-json` loads that file into `site.data.resume` (see `jekyll_get_json` / `jsonresume` in `_config.yml`), and `_layouts/cv.liquid` branches on `site.data.resume` being present — so the `_data/cv.yml` code path is dead. Edit `resume.json` (JSON Resume schema: `basics`, `work`, `education`, `publications`, `projects`, `volunteer`). `_pages/cv.md` still points `cv_pdf` at the placeholder `assets/pdf/example_pdf.pdf`.

### Custom plugins (`_plugins/`)

- `hide-custom-bibtex.rb` — strips `filtered_bibtex_keywords` from displayed BibTeX (see above).
- `google-scholar-citations.rb` / `inspirehep-citations.rb` — Liquid tags fetching live citation counts at build time.
- `download-3rd-party.rb` — mirrors CDN libraries/fonts locally when `third_party_libraries.download` is true.
- `external-posts.rb` — pulls blog posts from RSS feeds listed under `external_sources:`.
- `cache-bust.rb`, `file-exists.rb`, `details.rb`, `remove-accents.rb` — asset hashing, existence checks, `{% details %}` blocks, slug normalization.

Plugins run at build time and hit the network — a slow or failing build is often one of the citation/download plugins.

### Template leftovers

Unmodified upstream demo content: `_posts/` (31 theme demo posts), `_projects/1_project.md`…`9_project.md`, `_books/the_godfather.md`, `_pages/about_einstein.md`, `_pages/dropdown.md`, `_data/cv.yml` (Einstein placeholder), `_data/venues.yml`, `README.md`, `INSTALL.md`, `CUSTOMIZE.md`, `FAQ.md`, `CONTRIBUTING.md`, and most of `.github/workflows/`. Don't mistake these for site content, and don't "fix" them unless asked. Blog and Projects are wired to this demo content — the Blog nav link currently leads to theme sample posts.
