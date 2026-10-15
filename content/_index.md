---
title: "Euro Team Outreach"
description: "Euro Team Outreach is a Christian missions organization serving in Ukraine since 2004 — preaching the Gospel, teaching the Bible, and discipling the next generation of laborers."

# Page copy, rendered section by section by layouts/index.html. Source draft:
# planning/copy/home.md; tweaks happen in situ (#56). UGO strings go through
# layouts/partials/ugo-copy.html, so {trip_dates}, {trip_year} and
# {box_price} work here too. Published-copy conventions apply: russia/russian
# lowercase, Lviv without an apostrophe, KJV for Scripture.

# The legacy home's cover photo, kept for continuity with the site long-time
# supporters know. Shot on a CMO project; the team-around-a-map scene is as
# true of the work today. The blue wash is CSS (layouts/index.html), not baked
# into the file.
hero:
  photo:
    id: eto/eto-cover-2018_kp06lc
    width: 2000
    height: 1015
    alt: "A team of young men with backpacks gathers around a map on a street in Ukraine, planning the day's route."
  # The mission statement, carried over from the legacy home unchanged.
  mission:
    - "Preaching the Gospel"
    - "Teaching the Bible"
    - "Discipling Men in Missions"
  lede: "Christian missionaries serving in Ukraine since 2004 — carrying the good news of Jesus Christ, and practical help, to a nation at war."
  # Pray first: the site's priority is pray, then go, then give (#5).
  # Change these with ugo.md's doorways.
  actions:
    - label: "Pray with us"
      href: "/pray/"
    - label: "Go"
      href: "/serve/"
    - label: "Give"
      href: "/give/"
      give: true

who:
  heading: "Who we are"
  # An id from data/ugo.yaml photos.gallery, shown beside the text. Stands in
  # until the Lviv panorama's original turns up.
  photo: ugo/team-kherson-obl_cqlvtz
  body: |
    Euro Team Outreach is a Christian missions organization that has served in Ukraine since 2004 — a small, family-rooted team of American missionaries, working hand in hand with Ukrainian believers and local churches. For over two decades, we've had a singular focus, in changing forms: making Jesus Christ known — preaching the Gospel, teaching the Bible through our *Bible First* course, and discipling the next generation of laborers in the field.

    From our base in Lviv, that calling reaches across the country — city squares and mountain villages, and now the de-occupied towns near the front, where families are holding on under hard conditions. We come to introduce people to Jesus through the pages of Scripture, and to meet real needs as we go. The war has changed our methods, not our message.

# Every ministry is first-class here: a first-time visitor should see that
# ETO is more than UGO. UGO leads because it is the work in the field now.
work:
  heading: "What we do"
  intro: "One calling, carried in several forms — each one aimed at putting the Gospel and the Scriptures into Ukrainian hands."
  lead:
    eyebrow: "Now · next project {trip_dates}"
    heading: "Ukraine Gospel Outreach"
    # A key under photos.featured in data/ugo.yaml.
    photo: aid
    body: "Our largest effort today reaches the de-occupied villages of southern Ukraine — places the russian army once held, where help is now hardest to find. We go village by village with the Gospel and a box of food, hand-delivered to families who are still holding on. And in {trip_year}, we're going back."
    label: "Learn about UGO"
    href: "/ugo/"
  # Pre-UGO track (#21): none of these has an on-site page yet, so every
  # card links off-site. cmoproject.org is live but out of date and never
  # says the project is retired, so the card does. All three move to on-site
  # pages in Phase 2.
  #
  # logo: a file under assets/ (brand assets go through Hugo's pipeline, not
  # Cloudinary); logo_class sets its height in the strip (default h-full).
  # links: the first is the card's own link, stretched over the
  # whole card; any after it sit above that overlay as links of their own.
  # lang marks a link to a page in another language.
  ministries:
    - eyebrow: "Since 2006"
      heading: "Bible First"
      body: "A free evangelistic Bible course that takes students chronologically through the book of Genesis, pointing to Jesus at every turn. Over twenty lessons, studied on paper or online, students meet the Gospel and every major doctrine of Scripture."
      logo: img/ministries/bible-first.svg
      logo_alt: "Bible First"
      logo_class: "h-16"
      links:
        - label: "Visit getbiblefirst.com"
          href: "https://getbiblefirst.com/"
    - eyebrow: "Since 2008"
      heading: "Good and Evil"
      body: "The Bible's story told in illustrated form, which we translate into Ukrainian and put into people's hands. More than 25,000 copies have been given out since 2008, many in war-affected regions and hand-delivered on UGO trips. Churches, missionaries and schools across Ukraine can also request free copies to hand out in their own communities."
      logo: img/ministries/good-and-evil-uk-3d.png
      logo_alt: "The Ukrainian edition of Good and Evil, titled Добро і зло"
      # The publisher's English site explains the book; ours shows the
      # Ukrainian work itself, flagged so a donor expects a page they cannot
      # read; the distributor page is ours too, but in English. 25,000+ is
      # four printings (36,400) less stock on hand (8,850) and the ~1,000
      # sent south for UGO 2026, as of 2026-10-15.
      links:
        - label: "About the book"
          href: "https://goodandevilbook.com/"
        - label: "dobroizlo.com.ua"
          href: "https://dobroizlo.com.ua/"
          lang: uk
        - label: "Distributor program"
          href: "https://dobroizlo.com.ua/en/distributors/"
    - eyebrow: "2006–2023"
      heading: "Carpathian Mountain Outreach"
      body: "For seventeen years, summer teams went into the villages of the Carpathian mountains to show Gospel films, preach, and hand out literature. Thirteen projects brought more than sixty young people to Ukraine to learn the work of a missionary by doing it. CMO has finished; UGO carries its purpose forward."
      logo: img/ministries/cmo.svg
      logo_alt: "Carpathian Mountain Outreach"
      logo_class: "h-28"
      links:
        - label: "Visit the CMO archive"
          href: "https://cmoproject.org/"

involved:
  heading: "Three ways to stand with us"
  # Background photo: an id from data/ugo.yaml photos.gallery. A wide scene
  # with no close faces, since the cards cover the middle of the frame.
  photo: ugo/IMG_7370_ticlpq
  intro: "There are several ways to be part of what God is doing in Ukraine — and prayer comes first."
  doorways:
    - heading: "Pray & follow along"
      icon: hand-raised
      body: "The work runs on prayer. Pray with us, and follow along for real updates from the field and specific things to pray for."
      label: "Follow along"
      href: "/pray/"
    - heading: "Go"
      icon: map
      body: "God calls His people to go. For years, young people have joined us in Ukraine to learn first-hand what it means to serve as a missionary. If that stirs something in you, let's talk."
      label: "Serve with us"
      href: "/serve/"
    - heading: "Give"
      icon: gift
      body: "Help carry the Gospel and practical aid into Ukrainian communities. Give once, or give monthly to sustain the work between trips."
      label: "Give"
      href: "/give/"
      give: true
---
