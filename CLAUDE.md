# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Academic personal website for Jiale Xu, built with the **al-folio** Jekyll theme. Hosted on GitHub Pages at `https://bluestyle97.github.io/`.

## Build & Development Commands

### Local development (Docker — recommended)
```bash
docker compose pull
docker compose up
# Site available at http://localhost:8080
```

### Local development (Ruby)
```bash
bundle install
bundle exec jekyll serve --livereload
```

### Production build
```bash
JEKYLL_ENV=production bundle exec jekyll build
purgecss -c purgecss.config.js
```

### Code formatting
```bash
npx prettier --check .    # check formatting
npx prettier --write .    # fix formatting
```

## Architecture

- **Static site generator**: Jekyll (Ruby). Config in `_config.yml`.
- **Deployment**: GitHub Actions (`.github/workflows/deploy.yml`) builds and deploys to the `gh-pages` branch on push to `main`.
- **Styling**: SCSS in `_sass/`, Bootstrap 5 + MDB. Dark/light theme toggle via `_sass/_themes.scss`.
- **Templates**: Liquid templates — layouts in `_layouts/`, reusable partials in `_includes/`.

### Content types
| Type | Location | Notes |
|------|----------|-------|
| Pages | `_pages/` | Static pages (about, cv, publications, etc.) |
| Blog posts | `_posts/` | Date-prefixed markdown files |
| News | `_news/` | Short announcements shown on homepage |
| Projects | `_projects/` | Project showcases with `importance` and `category` front matter |
| Publications | `_bibliography/papers.bib` | BibTeX entries rendered by jekyll-scholar |
| Books | `_books/` | Book reviews |

### Key data files (`_data/`)
- `cv.yml` — CV content (education, experience, etc.)
- `coauthors.yml` — Co-author links for bibliography
- `repositories.yml` — GitHub repos to showcase
- `venues.yml` — Publication venue abbreviations

### Publications system
Uses the **jekyll-scholar** plugin with BibTeX source at `_bibliography/papers.bib`. Publication entries are rendered via `_layouts/bib.liquid`. Supports Altmetric/Dimensions badges and author highlighting.

### Custom plugins (`_plugins/`)
Ruby plugins for cache busting, external posts, Google Scholar citations, and more.

## Formatting & Linting

- **Prettier** enforced in CI (`.github/workflows/prettier.yml`). Config in `.prettierrc` — print width 150, Liquid template support.
- **Pre-commit hooks** (`.pre-commit-config.yaml`): trailing whitespace, end-of-file fixer, YAML validation.

## Front Matter Conventions

Pages and posts use YAML front matter with fields like `layout`, `title`, `date`, `description`, `img`, `importance`, `category`, `tags`, `selected`, `featured`. Refer to existing files for examples.
