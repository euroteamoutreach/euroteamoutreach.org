#!/usr/bin/env bash
# Smoke check for the DNS cutover (#31): run it before cutover against the
# Netlify production URL, then after against the live domain, and again a day
# or two later. Exits non-zero if any check fails.
#
#   DNS  — asks Route 53's own name server (no resolver cache), so it reports
#          what the zone says right now. The mail, Umami (lens.) and other
#          untouchable records must match docs/dns-rollback-snapshot.md; the
#          apex and www answers are printed so you can see which side of the
#          cutover the zone is on.
#   URLs — built pages, the netlify.toml redirects, and legacy paths served
#          through the fall-through proxy, each with its expected status.
#          Every legacy blog post URL (each post's `aliases`) must 301 to its
#          new page in one hop.
#   Feed — /feed.xml, which MailChimp's RSS campaign reads, must be well-formed
#          and list the 10 newest posts.
#
# Usage: scripts/cutover-check.sh [base-url]   (default https://euroteamoutreach.org)
set -uo pipefail

base="${1:-https://euroteamoutreach.org}"
base="${base%/}"
ns="ns-67.awsdns-08.com" # authoritative for the zone (see the snapshot)
failures=0

pass() { printf '  \033[32m✓\033[0m %s\n' "$1"; }
fail() {
  printf '  \033[31m✗\033[0m %s\n' "$1"
  failures=$((failures + 1))
}

# Sorted answer for one record, from the authoritative name server.
answer() { dig +short @"$ns" "$1" "$2" | sort | tr '\n' ' ' | sed 's/ $//'; }

expect_dns() { # name type expected
  local got
  got=$(answer "$1" "$2")
  if [[ "$got" == "$3" ]]; then pass "$2 $1"; else fail "$2 $1 — got: ${got:-<none>}"; fi
}

echo "DNS (@$ns)"
expect_dns euroteamoutreach.org MX "1 aspmx.l.google.com. 10 alt3.aspmx.l.google.com. 10 alt4.aspmx.l.google.com. 5 alt1.aspmx.l.google.com. 5 alt2.aspmx.l.google.com."
expect_dns euroteamoutreach.org NS "ns-1105.awsdns-10.org. ns-1743.awsdns-25.co.uk. ns-650.awsdns-17.net. ns-67.awsdns-08.com."
expect_dns euroteamoutreach.org TXT '"google-site-verification=yQARd7bJ9hk4P8TU8FkEEqv2OKq69emYUmoWzUByEhw"'
expect_dns _dmarc.euroteamoutreach.org TXT '"v=DMARC1; p=none; rua=mailto:info@euroteamoutreach.org"'
expect_dns pm-bounces.euroteamoutreach.org CNAME "pm.mtasv.net."
expect_dns lens.euroteamoutreach.org A "66.241.125.56"
expect_dns lens.euroteamoutreach.org AAAA "2a09:8280:1::de:9193:0"
if [[ -n "$(answer 20260213202414pm._domainkey.euroteamoutreach.org TXT)" ]]; then
  pass "TXT DKIM (20260213202414pm._domainkey)"
else
  fail "TXT DKIM (20260213202414pm._domainkey) — missing"
fi
echo "  · apex A: $(answer euroteamoutreach.org A)"
echo "  · www:    $(answer www.euroteamoutreach.org CNAME) $(answer www.euroteamoutreach.org A)"

expect_url() { # path status [location]
  local got_status got_location
  read -r got_status got_location < <(curl -s -o /dev/null -w '%{http_code} %{redirect_url}' "$base$1")
  got_location="${got_location#"$base"}"
  if [[ "$got_status" == "$2" && "${3:-}" == "${got_location:-}" ]]; then
    pass "$2 $1${3:+ → $3}"
  else
    fail "$1 — expected $2${3:+ → $3}, got $got_status${got_location:+ → $got_location}"
  fi
}

echo
echo "URLs ($base)"
while read -r path status location; do
  [[ -z "$path" || "$path" == \#* ]] && continue
  expect_url "$path" "$status" "${location:-}"
done <<'EOF'
# Built pages
/ 200
/ugo/ 200
/give/ 200
/contact/ 200
/thank-you/ 200
/doctrine/ 200
/jesus/ 200
/team/ 200
/team/steele/ 200
/about/ 200
/approach/ 200
/blog/ 200
# netlify.toml redirects
/donate 301 /give/
/donate/thanks/ 301 /give/
/donations 301 /give/
/contact/thanks 301 /thank-you/
/steele 301 /team/steele/
/day 301 /team/day/
# Legacy paths through the fall-through proxy
/chepara 302 /chepara/
/chepara/ 200
/cmo/ 200
/biblefirst/ 200
EOF

# Legacy blog post URLs, read from each post's front matter: the alias is the
# old URL, the slug gives the new /blog/<slug>/. The old URL must 301 straight
# to the new one, and the new one must answer 200: one hop.
echo
echo "Blog redirects"
posts=0
for post in "$(dirname "$0")"/../content/blog/*.md; do
  slug=$(sed -n 's/^slug: *//p' "$post")
  alias=$(sed -n 's/^- "\(\/blog\/[^"]*\)"$/\1/p' "$post")
  [[ -z "$slug" || -z "$alias" ]] && continue
  expect_url "$alias" 301 "/blog/$slug/"
  expect_url "/blog/$slug/" 200
  posts=$((posts + 1))
done
((posts)) || fail "no blog posts with aliases found under content/blog/"

# Only meaningful on the live domain: Netlify's www → apex and HTTP → HTTPS
# redirects, and proof the TLS certificate is served (curl reports 000 on a
# certificate error).
if [[ "$base" == "https://euroteamoutreach.org" ]]; then
  for pair in "https://www.euroteamoutreach.org/ https://euroteamoutreach.org/" \
    "http://euroteamoutreach.org/ https://euroteamoutreach.org/"; do
    read -r from to <<<"$pair"
    read -r got_status got_location < <(curl -s -o /dev/null -w '%{http_code} %{redirect_url}' "$from")
    if [[ "$got_status" == 301 && "$got_location" == "$to" ]]; then
      pass "301 $from → $to"
    else
      fail "$from — expected 301 → $to, got $got_status ${got_location:-}"
    fi
  done
fi

echo
echo "Feed"
feed=$(curl -s "$base/feed.xml")
if xmllint --noout - <<<"$feed" 2>/dev/null; then
  pass "/feed.xml is well-formed"
else
  fail "/feed.xml is not well-formed XML"
fi
items=$(grep -o '<item>' <<<"$feed" | wc -l | tr -d ' ')
if [[ "$items" == 10 ]]; then
  pass "/feed.xml lists 10 items"
else
  fail "/feed.xml lists $items items, expected 10"
fi
if grep -q "<link>$base/blog/" <<<"$feed"; then
  pass "/feed.xml items link to $base/blog/"
else
  fail "/feed.xml items do not link to $base/blog/"
fi

echo
if ((failures)); then
  echo "$failures check(s) failed"
  exit 1
fi
echo "All checks passed"
