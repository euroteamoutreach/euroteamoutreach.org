# Satellite domains — where each redirect lives

ETO owns several domains besides `euroteamoutreach.org`. As this site absorbs each one's content, the domain becomes a redirect into the matching section here. Each domain is set up differently, and none of the redirects live in this repo, so this file records where each one is and how to change it.

Redirects for paths **on** `euroteamoutreach.org` (legacy URLs, `/donate`, team bios) are a separate thing: they live in this repo's `netlify.toml`.

## At a glance

| Domain | Today | DNS | Redirect lives in | Target |
| --- | --- | --- | --- | --- |
| `ugoproject.org` | Redirect | Cloudflare (Namecheap is registrar only) | GitHub repo [`joshukraine/ugoproject-redirects`](https://github.com/joshukraine/ugoproject-redirects) → Cloudflare Pages | `/ugo/` |
| `getbiblefirst.com` | Its own site (Middleman on AWS S3) | Route 53 | — not yet | `/bible-first/` (planned) |
| `cmoproject.org` | Its own site (Middleman on AWS S3) | Route 53 | — not yet | `/cmo/` (planned) |

The planned targets and per-path rules for the two AWS domains are in the planning repo's `planning/redirect-map.md`.

## `ugoproject.org`

**How it works:** the apex and `www` DNS records in Cloudflare are proxied `CNAME`s to `ugoproject-redirects.pages.dev`, a Cloudflare Pages project. That project deploys the `ugoproject-redirects` GitHub repo, whose `_redirects` file holds the rule:

```text
/ https://euroteamoutreach.org/ugo/ 301
```

Repointed from the Notion page to `/ugo/` on 2026-10-15, right after the DNS cutover.

**To change it:** edit `_redirects` in that repo and push to `main`. Cloudflare Pages redeploys in about 20 seconds. Check with `curl -sI https://ugoproject.org/`.

**Where it is NOT:** Cloudflare → Rules (Redirect Rules, Page Rules), Bulk Redirects and Workers Routes are all empty for this domain. The dashboard's **Rule simulator** confirms it: a request ends in a 301 with no rule matched, because the response comes from the Pages project. Look at DNS → Records first.

**Only `/` redirects.** Any other path 404s. A catch-all `/*` rule was tried and removed early on (`fix: remove wildcard (splat)` in that repo's history). Add one back only if a real deep link needs it.

## When the next domain redirects

`getbiblefirst.com` and `cmoproject.org` change once their sections are built here (#62 and the CMO page). Both are Middleman sites on S3 with Route 53 DNS, the same setup `euroteamoutreach.org` had before cutover, so `dns-rollback-snapshot.md` and `route53/` are the pattern to copy:

1. Snapshot the zone byte-exact before touching it, and keep MX/TXT/mail records out of the change batch.
2. Decide the mechanism. Pointing the domain at Netlify as a domain alias lets per-path rules sit in this repo's `netlify.toml`, which matters for `getbiblefirst.com` with its 127 legacy URLs. The alternative is a small redirect project like `ugoproject-redirects`.
3. Add a row to the table above, and a section like the one for `ugoproject.org`.
