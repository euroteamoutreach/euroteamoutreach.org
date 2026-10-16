# euroteamoutreach.org

[![Netlify Status](https://api.netlify.com/api/v1/badges/1908d467-2639-4e89-bf88-342fbdeab59a/deploy-status)](https://app.netlify.com/projects/euroteamoutreach/deploys)

The consolidated website for **Euro Team Outreach, Inc.** — a US-based Christian missions nonprofit (501(c)(3)) serving in Ukraine.

This Hugo site replaces and consolidates four legacy web properties into one:

| Legacy property | Stack | Fate |
| --- | --- | --- |
| euroteamoutreach.org | Middleman | The umbrella site + 2017–2025 blog archive → migrated here |
| getbiblefirst.com | Middleman | → `/bible-first` (Phase 2) |
| cmoproject.org | Middleman | → `/cmo` museum page (Phase 2) |
| ugoproject.org | Notion | → `/ugo` (MVP, critical path) |

**Tech stack:** Hugo · Tailwind CSS v4 · Alpine.js · Netlify · Cloudinary (images) · Umami (analytics) · Givebutter (donations) · Netlify Forms

**Audience:** primarily American donors and supporters.

## Where the planning lives

This repo is the **deliverable**. The reasoning behind it lives in a separate private planning repo, [`euroteamoutreach/eto-web-reboot`](https://github.com/euroteamoutreach/eto-web-reboot) — the decision log, content/URL inventories, redirect map, donation research, and the source copy drafts.

- **`eto-web-reboot` = the brain.** _Why_ we decided what we decided. Does not retire.
- **This repo = the build.** PRD, roadmap, issues, code, content. Source of truth for anything shipped.

Start with `planning/DECISIONS.md` in that repo for the full context (57 numbered decisions and counting).

## Quick start

```bash
npm install
hugo server -D        # dev server, live reload, includes drafts
hugo --gc --minify    # production build
```

## Documentation

| File | Purpose |
| --- | --- |
| `CLAUDE.md` | Project guide — stack, conventions, workflow |
| `docs/prd/README.md` | PRD index — start here for any feature question |
| `docs/prd/ROADMAP.md` | Task list with checkboxes, one PR per item |
| `docs/prd/CHANGELOG.md` | PRD deviation log |
| `docs/domain-redirects.md` | Where each satellite domain's redirect lives (`ugoproject.org`, …) |
| `docs/dns-rollback-snapshot.md` | Route 53 snapshot and rollback for the `euroteamoutreach.org` cutover |

## Sister projects

Built on the identical stack and conventions — consult them before inventing anything new:

- [`ofreport.com-hugo`](https://github.com/joshukraine/ofreport.com-hugo) — **the primary reference.** The blog structure this site's `/blog` mirrors (permalinks, tags, front matter, posting workflow), plus a reusable legacy-blog migration toolkit (`scripts/`) and a URL-parity / link-check QA harness that enforces the no-404s guarantee.
- [`dobroizlo.com.ua`](https://github.com/euroteamoutreach/dobroizlo.com.ua) — simpler marketing site (no blog). Best reference for the Tailwind/Hugo CSS pipeline, Cloudinary + Umami partials, i18n, and a documented Netlify DNS cutover.
