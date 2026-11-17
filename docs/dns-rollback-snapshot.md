# DNS Rollback Snapshot — `euroteamoutreach.org`

> **Purpose:** Pre-cutover record of the AWS Route 53 hosted zone for `euroteamoutreach.org`, captured before the S3 + CloudFront → Netlify move. If the cutover goes wrong, apply the rollback change batch below and the two changed records return to exactly these values. The runbook itself — the ordered, checked-off task list — is Hugo issue #31.

**Captured:** 2026-10-09, byte-exact via AWS CLI
**Hosted zone:** `euroteamoutreach.org` — Public hosted zone
**Hosted zone ID:** `Z8WR4A8DKJUQ8`
**Record count:** 14
**Capture command:** `aws route53 list-resource-record-sets --hosted-zone-id Z8WR4A8DKJUQ8 --output json --profile eto`

**Name servers (delegation — do not change):**

```text
ns-67.awsdns-08.com
ns-1743.awsdns-25.co.uk
ns-650.awsdns-17.net
ns-1105.awsdns-10.org
```

## Full record set (pre-cutover)

| Record name | Type | Alias | Value / Route traffic to | TTL |
| --- | --- | --- | --- | --- |
| `euroteamoutreach.org` | A | Yes | `d2amb9pccla9r3.cloudfront.net.` (CloudFront `E17QH79PE13UP8`, zone `Z2FDTNDATAQYW2`) | – (alias) |
| `euroteamoutreach.org` | MX | No | Google Workspace: `1 ASPMX`, `5 ALT1`, `5 ALT2`, `10 ALT3`, `10 ALT4` `.L.GOOGLE.COM` | 3600 |
| `euroteamoutreach.org` | NS | No | the four `awsdns` name servers above | 172800 |
| `euroteamoutreach.org` | SOA | No | `ns-67.awsdns-08.com. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400` | 900 |
| `euroteamoutreach.org` | TXT | No | `google-site-verification=…` (Search Console) | 300 |
| `_1613c6be3071fbf9ea84db64802e03d5.euroteamoutreach.org` | CNAME | No | `_121364b7065ac952d82afd3c790f00e4.acm-validations.aws.` (ACM cert validation for the CloudFront cert) | 300 |
| `_dmarc.euroteamoutreach.org` | TXT | No | `v=DMARC1; p=none; rua=mailto:info@euroteamoutreach.org` | 300 |
| `20260213202414pm._domainkey.euroteamoutreach.org` | TXT | No | DKIM public key (Postmark) | 300 |
| `_gh-euroteamoutreach-o.euroteamoutreach.org` | TXT | No | GitHub organization domain verification | 300 |
| `day.euroteamoutreach.org` | A | Yes | `s3-website-us-east-1.amazonaws.com.` (S3 website, zone `Z3AQBSTGFYJSTF`) | – (alias) |
| `lens.euroteamoutreach.org` | A | No | `66.241.125.56` (Fly.io — Umami) | 300 |
| `lens.euroteamoutreach.org` | AAAA | No | `2a09:8280:1::de:9193:0` (Fly.io — Umami) | 300 |
| `pm-bounces.euroteamoutreach.org` | CNAME | No | `pm.mtasv.net` (Postmark return path) | 300 |
| `www.euroteamoutreach.org` | A | Yes | `d2amb9pccla9r3.cloudfront.net.` (CloudFront `E17QH79PE13UP8`, zone `Z2FDTNDATAQYW2`) | – (alias) |

## What the cutover changes

Only **two** records change, in one atomic change batch ([`route53/cutover.json`](route53/cutover.json)):

| Record | Before | After |
| --- | --- | --- |
| `euroteamoutreach.org` | `A` alias → CloudFront | `A 75.2.60.5`, TTL 300 (Netlify's load balancer) |
| `www.euroteamoutreach.org` | `A` alias → CloudFront | `CNAME euroteamoutreach.netlify.app`, TTL 300 |

The targets come from Netlify's external-DNS docs (checked 2026-10-09). Route 53 can alias only to AWS resources, so the apex takes Netlify's plain `A` record rather than an ALIAS to `apex-loadbalancer.netlify.com` — the same setup `dobroizlo.com.ua` runs in production. The apex stays the primary domain (it matches `baseURL`); Netlify 301s `www` to it. Today legacy CloudFront serves `www` as a 200 duplicate, so that redirect is a small improvement, not a change in reachability.

`www` changes record **type** (`A` → `CNAME`). A CNAME can't coexist with another record at the same name, so the batch deletes the alias and creates the CNAME together. Route 53 applies a change batch all-or-nothing, and its `DELETE` actions must match the current record exactly — so if the zone has drifted from this snapshot, the whole batch is rejected and nothing changes.

## What must NOT be touched

- **Mail:** `MX`, `_dmarc` TXT, the `_domainkey` DKIM TXT, `pm-bounces` CNAME. ETO's email runs through Google Workspace and Postmark. Since 2026-11-17 this also covers the SPF value in the root TXT, the `google._domainkey` TXT, and the MailChimp `k2`/`k3` CNAMEs (see "Email authentication records").
- **`lens.euroteamoutreach.org`** A + AAAA — the shared Umami instance on Fly.io, serving every site in the network.
- **NS** and **SOA** — zone delegation.
- The root **TXT** (Search Console), the **`_gh-`** TXT (GitHub), and **`day.`** (legacy S3 alias).
- The **ACM validation CNAME** — keeps the CloudFront cert renewable, which rollback depends on.

Outside DNS: **leave CloudFront distribution `E17QH79PE13UP8` and the `euroteamoutreach.org` S3 bucket in place.** The Netlify fall-through proxy (`netlify.toml`) fetches the S3 website endpoint directly, so the site depends on the bucket after cutover, and rollback depends on the distribution. Neither is retired until the full migration (Phase 13).

## Notes affecting the cutover

- **No TTL pre-lowering needed.** The apex and `www` are Route 53 **alias** records to CloudFront, which have no editable TTL and resolve at ~60s. There is no high static TTL to lower, so the usual 24–48h wait does not apply.
- **No email impact.** The batch names only the apex `A` and `www` records; the mail records are structurally out of reach. Confirm anyway (#31 post-launch).
- **TLS gap.** Netlify can't issue the Let's Encrypt certificate until DNS points at it, so HTTPS shows a certificate error for the first few minutes. Legacy sends no HSTS header, so no browser is locked out. Cut over in a quiet hour.

## Cutover procedure

```bash
aws route53 change-resource-record-sets --profile eto \
  --hosted-zone-id Z8WR4A8DKJUQ8 \
  --change-batch file://docs/route53/cutover.json
```

The response carries a change `Id` with `"Status": "PENDING"`; `aws route53 get-change --id <Id> --profile eto` reports `INSYNC` once all four Route 53 name servers serve it (usually under a minute). Then run `scripts/cutover-check.sh https://euroteamoutreach.org` and provision the certificate in Netlify.

**Console equivalent:** Route 53 → Hosted zones → `euroteamoutreach.org`. Edit the apex `A` record: Alias off, value `75.2.60.5`, TTL 300. Delete the `www` `A` alias record, then create `www` as `CNAME` → `euroteamoutreach.netlify.app`, TTL 300. (The CLI is preferred: it's atomic and refuses to run against a drifted zone.)

## Rollback procedure

If the site fails to serve correctly from Netlify, restore both records to their pre-cutover alias-to-CloudFront state ([`route53/rollback.json`](route53/rollback.json)):

```bash
aws route53 change-resource-record-sets --profile eto \
  --hosted-zone-id Z8WR4A8DKJUQ8 \
  --change-batch file://docs/route53/rollback.json
```

Resolvers that cached the Netlify answers hold them for up to their 300s TTL, so rollback takes effect within about **five minutes**. Leave the Netlify custom domain configured — it's inert while DNS points elsewhere — so a second attempt needs only the cutover batch again.

**Console equivalent:** restore the apex and `www` as `A` records with **Alias:** Yes · **target** `d2amb9pccla9r3.cloudfront.net.` · **hosted zone** `Z2FDTNDATAQYW2` (CloudFront's fixed zone ID) · **Evaluate target health:** No. Delete the `www` CNAME first.

**Tested on paper (2026-10-09):** each `DELETE` in the rollback batch matches, field for field, the record the cutover batch `CREATE`s, and each rollback `CREATE` is the exact alias from the capture below. Both files validate as JSON.

## Email authentication records (added 2026-11-17)

The domain had no SPF record and Google Workspace wasn't signing with DKIM, so staff mail failed DMARC and Gmail auto-forwarding bounced (5.7.27). A review of the DMARC aggregate reports (Oct 14 – Nov 16) found three legitimate senders: Google Workspace, Postmark, and MailChimp. Postmark already passed. These records fix the other two. Each was applied with the AWS CLI and checked against the authoritative name server.

| Record name | Type | Value | TTL | For |
| --- | --- | --- | --- | --- |
| `euroteamoutreach.org` | TXT | `v=spf1 include:_spf.google.com ~all`, added as a second value beside `google-site-verification=…` | 300 | SPF for Google Workspace |
| `google._domainkey.euroteamoutreach.org` | TXT | `v=DKIM1; k=rsa; p=…` (2048-bit key from Admin console → Gmail → Authenticate email), stored as two quoted strings because Route 53 limits each string to 255 characters | 300 | Workspace DKIM |
| `k2._domainkey.euroteamoutreach.org` | CNAME | `dkim2.mcsv.net` | 300 | MailChimp DKIM |
| `k3._domainkey.euroteamoutreach.org` | CNAME | `dkim3.mcsv.net` | 300 | MailChimp DKIM |

- **Postmark needs no SPF entry.** Its envelope sender is `pm-bounces.euroteamoutreach.org`, which passes through the existing CNAME, and it signs with its own `_domainkey` key.
- **MailChimp needs no SPF entry either.** Its envelope sender is `mandrillapp.com`, so it aligns with DMARC through DKIM (the `k2`/`k3` CNAMEs), not SPF.
- **DMARC was left as it was.** MailChimp's setup screen suggests `v=DMARC1; p=none;`, but replacing ours with that would drop the `rua` reports to info@.
- **SPF ends in `~all`, not `-all`.** Mail from a sender not listed is marked suspicious, not rejected. Tighten it, and the DMARC policy, only after the reports show no legitimate failures.
- **The apex TXT is one record holding two values.** Route 53 replaces all of a record's values together, so any change to it must carry both the Search Console and the SPF values, or one is lost.

**To undo:** delete the `google._domainkey` TXT and the `k2`/`k3` CNAMEs, and set the apex TXT back to only the `google-site-verification` value. Click "Stop authentication" in the Workspace Admin console before deleting the Google key, or Workspace mail will fail DKIM.

## Appendix — byte-exact capture

```json
{
    "ResourceRecordSets": [
        {
            "Name": "euroteamoutreach.org.",
            "Type": "A",
            "AliasTarget": {
                "HostedZoneId": "Z2FDTNDATAQYW2",
                "DNSName": "d2amb9pccla9r3.cloudfront.net.",
                "EvaluateTargetHealth": false
            }
        },
        {
            "Name": "euroteamoutreach.org.",
            "Type": "MX",
            "TTL": 3600,
            "ResourceRecords": [
                {
                    "Value": "1 ASPMX.L.GOOGLE.COM"
                },
                {
                    "Value": "5 ALT1.ASPMX.L.GOOGLE.COM"
                },
                {
                    "Value": "5 ALT2.ASPMX.L.GOOGLE.COM"
                },
                {
                    "Value": "10 ALT3.ASPMX.L.GOOGLE.COM"
                },
                {
                    "Value": "10 ALT4.ASPMX.L.GOOGLE.COM"
                }
            ]
        },
        {
            "Name": "euroteamoutreach.org.",
            "Type": "NS",
            "TTL": 172800,
            "ResourceRecords": [
                {
                    "Value": "ns-67.awsdns-08.com."
                },
                {
                    "Value": "ns-1743.awsdns-25.co.uk."
                },
                {
                    "Value": "ns-650.awsdns-17.net."
                },
                {
                    "Value": "ns-1105.awsdns-10.org."
                }
            ]
        },
        {
            "Name": "euroteamoutreach.org.",
            "Type": "SOA",
            "TTL": 900,
            "ResourceRecords": [
                {
                    "Value": "ns-67.awsdns-08.com. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"
                }
            ]
        },
        {
            "Name": "euroteamoutreach.org.",
            "Type": "TXT",
            "TTL": 300,
            "ResourceRecords": [
                {
                    "Value": "\"google-site-verification=yQARd7bJ9hk4P8TU8FkEEqv2OKq69emYUmoWzUByEhw\""
                }
            ]
        },
        {
            "Name": "_1613c6be3071fbf9ea84db64802e03d5.euroteamoutreach.org.",
            "Type": "CNAME",
            "TTL": 300,
            "ResourceRecords": [
                {
                    "Value": "_121364b7065ac952d82afd3c790f00e4.acm-validations.aws."
                }
            ]
        },
        {
            "Name": "_dmarc.euroteamoutreach.org.",
            "Type": "TXT",
            "TTL": 300,
            "ResourceRecords": [
                {
                    "Value": "\"v=DMARC1; p=none; rua=mailto:info@euroteamoutreach.org\""
                }
            ]
        },
        {
            "Name": "20260213202414pm._domainkey.euroteamoutreach.org.",
            "Type": "TXT",
            "TTL": 300,
            "ResourceRecords": [
                {
                    "Value": "\"k=rsa;p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCIgtLBSEMvSxCFwLJMbrnBs0u2RSdsivzT+ROQPCVZmSp1Dr4XYHTsfEkCJqUIdVsr8MI+agptdBcGf0DLouhL16w9138wpf3DzVi1zKXsKAvr7lAZ+tZiWdqAHDhiUCzPO3QbyrR3Eg8Mxssposvz3VKtCd0eVppBhrA2ckpHWwIDAQAB\""
                }
            ]
        },
        {
            "Name": "_gh-euroteamoutreach-o.euroteamoutreach.org.",
            "Type": "TXT",
            "TTL": 300,
            "ResourceRecords": [
                {
                    "Value": "\"133a075fa5\""
                }
            ]
        },
        {
            "Name": "day.euroteamoutreach.org.",
            "Type": "A",
            "AliasTarget": {
                "HostedZoneId": "Z3AQBSTGFYJSTF",
                "DNSName": "s3-website-us-east-1.amazonaws.com.",
                "EvaluateTargetHealth": false
            }
        },
        {
            "Name": "lens.euroteamoutreach.org.",
            "Type": "A",
            "TTL": 300,
            "ResourceRecords": [
                {
                    "Value": "66.241.125.56"
                }
            ]
        },
        {
            "Name": "lens.euroteamoutreach.org.",
            "Type": "AAAA",
            "TTL": 300,
            "ResourceRecords": [
                {
                    "Value": "2a09:8280:1::de:9193:0"
                }
            ]
        },
        {
            "Name": "pm-bounces.euroteamoutreach.org.",
            "Type": "CNAME",
            "TTL": 300,
            "ResourceRecords": [
                {
                    "Value": "pm.mtasv.net"
                }
            ]
        },
        {
            "Name": "www.euroteamoutreach.org.",
            "Type": "A",
            "AliasTarget": {
                "HostedZoneId": "Z2FDTNDATAQYW2",
                "DNSName": "d2amb9pccla9r3.cloudfront.net.",
                "EvaluateTargetHealth": false
            }
        }
    ]
}
```
