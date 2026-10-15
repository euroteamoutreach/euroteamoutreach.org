# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

The consolidated Hugo site for **Euro Team Outreach (ETO)** — a US-based Christian missions nonprofit (501(c)(3)) serving in Ukraine. It replaces four legacy properties (the Middleman umbrella site + blog, getbiblefirst.com, cmoproject.org, and a UGO Notion page). Audience is primarily **American donors and supporters**.

**Tech stack:** Hugo · Tailwind CSS v4 · Alpine.js · Netlify · Cloudinary (images) · Umami (analytics) · Givebutter (donations) · Netlify Forms

### Sister projects — look here FIRST, invent LAST

Both run the identical stack and conventions. **When you need a pattern — blog templates, RSS, tags, image handling, CI, URL verification, DNS cutover — look in ofreport first, dobroizlo second, and invent third.**

**`joshukraine/ofreport.com-hugo` — the PRIMARY reference** (public). Joshua's blog; the more relevant of the two because it actually _has_ a blog. This site's `/blog` **mirrors its mechanics** — `[permalinks] blog = "/blog/:slug/"`, tags-only taxonomy, front matter, archetype, posting workflow — so the two stay cheap to maintain together. Visual design diverges. It also ships tooling we should **reuse, not rewrite**:

- **`scripts/`** — a legacy-blog migration toolkit in Ruby: `migrate.rb`, `convert_anchors_to_markdown.rb`, `decode_legacy_entities.rb`, `normalize_curly_quotes.rb`, `strip_legacy_ials.rb`, `probe-images.rb`, and **`normalize_lviv_spelling.rb`** (the "Lviv" convention, already scripted). Adapt these for the 29 Middleman posts.
- **`docs/url-parity/`** + **`docs/link-check.md`** (+ `lychee` in CI) — machinery that enforces the **no-404s guarantee**. Wire the equivalent into this repo's CI rather than hand-checking the redirect map.
- **`docs/hugo-migration-brief.md`** — the canonical blog front-matter schema.
- Also uses `@tailwindcss/typography` (post prose) and `pagefind` (static search — optional for us).

**`euroteamoutreach/dobroizlo.com.ua`** (public) — simpler marketing site, **no blog**. Still the best reference for: the `css.TailwindCSS` wiring, Alpine patterns, the layout-driven template convention, Cloudinary + Umami partials, i18n, and — importantly — **`docs/netlify-setup.md` + `docs/dns-rollback-snapshot.md`**, a documented Netlify DNS cutover. **Read the rollback snapshot before planning ours** (Route 53 → Netlify, four domains, no-404s: the scariest step of this project).

## Where the planning lives

The **why** — and the full PRD — live in a separate **private** repo, `euroteamoutreach/eto-web-reboot` (locally the parent directory of this one). This repo is **public** (it deploys to Netlify); anything sensitive or tentative stays in the private repo.

**Sessions start here, in this repo.** The planning repo is `..`, readable because `.claude/settings.local.json` grants it as an additional directory. Its **`../CLAUDE.md`** carries the current project status (phase, critical path, open real-world inputs), which this public file deliberately leaves out — read it at the start of a session. Commits to the planning repo (ROADMAP ticks, CHANGELOG entries) are made there, not here.

- **`planning/prd/`** — the full PRD (overview, architecture, ROADMAP, per-feature specs). Relocated here when this repo went public (decision #55, revised). Available locally at **`docs/prd/`** via a gitignored symlink, so the old path and the workflow skills keep working unchanged.
- **`planning/DECISIONS.md`** — the numbered decision log. **Read it first.** Nearly every question below ("why UGO at top level?", "why lowercase russia?", "why KJV?") is answered there with rationale.
- `planning/sitemap.md` · `planning/content-model.md` · `planning/redirect-map.md` · `planning/donations-research.md`
- `planning/copy/` — the **source copy drafts** for all 11 MVP pages. These are the input to `content/`. **Once copy lands here as Hugo content, this repo owns it** and `planning/copy/` becomes historical (decision #55).

## Development Approach

**Developer-directed, AI-assisted.** Joshua directs the decisions and wants to follow the reasoning.

- **Explain the decision, not the syntax** — surface trade-offs and rejected alternatives; skip Hugo and Tailwind concept tutorials. He ships this stack in production.
- **Replace, don't deprecate** — no backward-compat shims

### Tailwind Plus Workflow

Joshua holds a Tailwind Plus subscription. Licensed snippets live locally in `docs/tailwind_plus/` as design references — **git-ignored, never committed** (see the root `NOTICE`). Read them for layout, spacing, and class idiom, then **build Hugo templates from those patterns — never copy verbatim**. Pull **v4-era** snippets; v3→v4 renamed some utilities.

## Handling Ambiguity

| Decide and move | Stop and ask Joshua |
| --- | --- |
| Reversible edits — layout, styling, copy tweaks | A new page/route, or any change to an existing URL |
| Implementation details the PRD leaves unspecified | Anything that contradicts or amends the PRD |
| Lint, formatting, docs cleanup | Donation flow, form behavior, or the designation model |
| | Anything touching the memorial team page or a sensitive bio |

The test: if it's easily reversed, decide and move. **URL continuity, the donation flow, and the two forms are load-bearing** — treat them as interfaces, not implementation details.

## Development Workflow

All work flows through GitHub Issues:

1. **Plan** → the output of planning is one or more GitHub issues with clear acceptance criteria. Issues come _before_ implementation code.
2. **Implement** → `/resolve-issue <number>` (feature branch, structured workflow).
3. **PR** → `/create-pr --issue <number>`.
4. **Merge** → must pass `hugo --gc --minify` first. Squash merge.

Conventions:

- **Conventional Commits**, but commit messages do **not** reference issue numbers. Issue linking happens in the PR description via "Closes #N".
- **Branch naming:** `<type>/gh-<issue#>-<short-description>` (e.g. `feat/gh-12-ugo-page`).
- **ROADMAP checkboxes:** the ROADMAP lives in the **private planning repo** (`planning/prd/ROADMAP.md`, symlinked locally at `docs/prd/ROADMAP.md`). Tick the box in a **planning-repo commit** alongside the work — it is no longer part of the Hugo PR.
- Small housekeeping (typos, README) can go straight to main.

## Build Commands

```bash
npm install
hugo server -D        # dev server (live reload, includes drafts)
hugo --gc --minify    # production build
npm run lint          # markdownlint + prettier
```

Hugo version is pinned in `netlify.toml`. Node 22 target runtime.

## Architecture

> Filled in as the build lands. The settled shape:

### CSS Pipeline

Tailwind v4 via Hugo's built-in `css.TailwindCSS` function (**not** a PostCSS/npm-script bolt-on):

- Entry point: `assets/css/main.css` — holds the `@theme { }` **design-token block**
- Processing partial: `layouts/partials/css.html`
- JIT scanning via `hugo_stats.json` (auto-generated, gitignored); requires `[build.buildStats] enable = true` + the `hugo_stats.json` module mount
- Deferred rendering in `<head>` via `templates.Defer`, so the class list is complete before CSS generation

**Design tokens are the design system.** Tailwind v4 is CSS-first: `--color-eto-blue: #0d47a1` in `@theme` auto-generates `bg-eto-blue`, `text-eto-blue`, etc. The Claude Design phase's output lands _here_ — not as a parallel hand-rolled CSS system (decision #50).

### JavaScript

**Alpine.js** for interactivity (mobile nav, form validation/AJAX). No framework. Per-page scripts bundled via Hugo's `js.Build` with fingerprinting + SRI.

### Images — Cloudinary

Photographic images are served through **ETO's existing Cloudinary account** (already in use for Bible First Online v1), via a `layouts/partials/cloudinary-img.html` partial with automatic format/size optimization. This site is image-heavy: the UGO page alone carries ~23 captioned field photos, plus team photos and the blog archive.

- **Cloudinary** → photographs.
- **Hugo's native pipeline** → structural assets, SVGs, inline icons (Heroicons).

🔒 **No secrets in this repo.** Delivery needs only the **cloud name**, which is public and lives in `hugo.toml`. The API key/secret are needed only to _upload_ — done via the Cloudinary UI or a local CLI with env vars (or Netlify env vars if ever automated). **Never commit them.**

### Analytics — Umami

**Self-hosted Umami** at `lens.euroteamoutreach.org` (ETO runs its own instance on Fly.io, serving every site in the network). Wire it in via `layouts/partials/analytics.html`, **production-only** — no tracking in dev. **Not** Google Analytics.

### Forms

Both on **Netlify Forms** (replacing the legacy Formspree):

- `/contact` — Connect form
- `/serve` — the lightweight gateway form (name · who you are · the basics). Its only job is to **open a conversation** → triggers a video interview. Vetting stays human; there is no application pipeline.

### Donations

**Givebutter** (free tier), client-side embed. Four cause designations, single-sourced in `data/designations.yaml` and referenced by `/give` and every program give-CTA:

`ugo-aid-boxes` · `fallen-defender` · `good-and-evil-printing` · `general`

⚠️ **Legally load-bearing:** the 501(c)(3) **discretion-and-control disclaimer** on `/give` is ported verbatim. Designations are always **cause-framed, never earmarked to a named individual** (IRS rules). Do not soften or "improve" this language. See decisions #13, #14, #39.

## Copy & Style Conventions

Settled site-wide (planning `DECISIONS.md` #41–46). These are deliberate — do **not** "correct" them:

- **"Lviv"** — no apostrophe, never "L'viv".
- **"russia" / "russian" — lowercase**, always, in body copy. A deliberate act of solidarity. Don't capitalize. (Exception: never alter direct quotations. Prefer rephrasing so it doesn't start a sentence.)
- **KJV exclusively** for all English Scripture — a settled conviction, not a style preference.
- **Capitalize pronouns that refer to God** (He, Him, His) in site copy. Quoted Scripture keeps the KJV's own lowercase — never alter a quotation.
- **"young people"**, not "young men", in `/serve` and UGO invitations. Deliberate and future-proof; do not narrow it.
- **Gospel first, aid second.** The two are distinct and _ordered_. Never frame humanitarian aid as co-equal to or ahead of the Gospel. The phrase "the greatest evangelistic weapon in our arsenal" is **kept** as-is.
- **Aid goes out on discrete trips**, not year-round. Giving copy must never imply continuous monthly distribution.
- **Tone: humble sobriety.** Bold, never cocky or self-promoting. Lead with the need. Present what we _are_ — don't tell readers what we're _not_.

## URL Preservation

**Preserving legacy URLs is a first-class requirement — no 404s.** Full map in `planning/redirect-map.md`.

- Preserved as-is: `/about` · `/approach` · `/jesus` · `/doctrine` · `/contact`
- `/donate` + `/donations` → `/give`
- Team bios move to `/team/{slug}/`; legacy root slugs (`/day` `/steele` `/sargent` `/chepara` `/patricia`) 301 to them
- **Blog:** legacy `/blog/{year}/{month}/{title}.html` → new `/blog/YYYY-MM-DD-slug/`. The exact day comes from each legacy post's front-matter `date:` field. Per-post 301s via Hugo `aliases`.

⚠️ **MailChimp RSS is wired to the blog.** Changed permalinks/GUIDs can re-blast old posts to the entire list as "new." **Pause the RSS automation during migration**, verify the feed, then re-enable.

## Sensitive Content

Some `/team/` content and one donation designation involve **sensitive, real-person relational handling that is deliberately NOT documented in this public repo.** Before touching the **memorial team page** (it ships `draft: true` and does **not** publish) or the **Fallen Defender Fund** designation, consult the **private planning repo** (`planning/prd/12-risks-and-open-items.md`, `planning/DECISIONS.md`) and **stop and ask Joshua**.

The **Fallen Defender Fund** is **cause-framed** and **never** earmarked to any named individual or family (IRS rules — see the Donations section above). Handle all of this with care; if in doubt, stop and ask.

## Key Files

| File | Purpose |
| --- | --- |
| `docs/prd/README.md` | PRD index — start here for any feature question |
| `docs/prd/ROADMAP.md` | Task list with checkboxes, one PR per item |
| `docs/prd/CHANGELOG.md` | PRD deviation log — update before merging any deviation |
| `../planning/DECISIONS.md` | The numbered decision log (the _why_) |
| `~/.claude/docs/label-taxonomy.md` | Work type labels, branch naming, board config |

**Always consult the relevant PRD file before implementing a feature.**
