---
title: "Give"
slug: give
layout: give
description: "Give to Euro Team Outreach — carry the Gospel and real, practical help to people across Ukraine. Give once, or give monthly."

# Page copy, rendered section by section by layouts/give.html. The four fund
# cards are NOT here — they come from data/designations.yaml (#40).
# Source draft: planning/copy/give.md. Tweaks happen in situ (#56).

# The two doorways at the top of the page, equal in weight. Many visitors
# arrive because they know one of our families and want to give to them, not
# to ETO; the second card routes them to /team/, where each family links its
# own support channels (#10, #32). Side by side, the two also say plainly that
# a gift to ETO is not a gift to a named family (#14).
#
# /team/ is a literal URL, not a pageRef: it is unrendered on the pre-UGO
# track (hugo.toml cascade) and falls through to legacy.
doorways:
  - href: "#give-online"
    heading: "Give to ETO"
    text: "Support ETO's ministry in Ukraine — the work as a whole, or one of the funds below. Give once, or monthly."
    button: "Give online to ETO"
  - href: "/team/"
    heading: "Support a missionary family"
    text: "Many supporters give directly to a specific family. Each missionary family is supported through their own channels."
    button: "Meet the team"

where:
  heading: "Where your gift to ETO goes"
  intro: "When you give to ETO, you can support the work as a whole or direct your gift to one part of it. Choose a fund when you give:"

online:
  heading: "Give online"
  note: "You'll receive an emailed receipt for your records. Monthly giving is welcome — a steady gift helps us plan ahead, whatever fund you choose."
  fallback:
    prompt: "Form not loading?"
    link: "Give on Givebutter instead"
  mail:
    heading: "Prefer to mail a check?"
    text: "You're welcome to send one, payable to *Euro Team Outreach, Inc.*:"
    address:
      - "Euro Team Outreach, Inc."
      - "16723 Britford"
      - "Houston, TX 77084"

# ⚠️ LEGALLY LOAD-BEARING — ported VERBATIM from the legacy /donate page and
# checked character for character against docs/prd/07-donations.md §"The
# Disclaimer — Ported Verbatim". The disclaimer is what makes the Fallen
# Defender Fund compliant. Do not paraphrase, soften, shorten, or "improve"
# either paragraph (#13, #14, #39).
trust:
  heading: "Accountability & trust"
  statement: "Euro Team Outreach, Inc. (ETO) is a 501(c)(3) nonprofit corporation registered in the State of Texas. All gifts are tax-deductible and are used exclusively for ministry purposes. ETO staff members do not receive a salary, nor may any gift inure to them personally."
  disclaimer: "Contributions to ETO are solicited with the understanding that ETO has complete discretion and control over the use of all donated funds. ETO will attempt to honor requests to support particular causes or individuals, but the final decision on the use of all funds rests with the organization."
---

Your generosity carries the Gospel — and real, practical help — to people across Ukraine. Every gift goes to work in the field: an aid box placed in a family's hands near the front, the Scriptures opened in someone's own language. Give once, or give monthly to help sustain it.
