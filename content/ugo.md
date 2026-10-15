---
title: "Ukraine Gospel Outreach"
slug: ugo
layout: ugo
description: "Ukraine Gospel Outreach carries the Gospel of Jesus Christ and hand-delivered aid into Ukrainian communities near the front — village by village, box by box."
# Cloudinary public ID. The photo's alt, caption, and size live with every
# other UGO photo in data/ugo.yaml; the layout looks it up by this ID.
hero_image: ugo/IMG_7382_rhjbix
give_designation: ugo-aid-boxes
give_cta_label: "Give an aid box — {box_price}"
status: active
weight: 10

# Page copy, rendered section by section by layouts/ugo.html. Source draft:
# planning/copy/ugo.md; tweaks happen in situ (#56).
#
# NO DATE OR PRICE IS TYPED HERE. Write a token instead, and
# layouts/partials/ugo-copy.html fills it in:
#   {trip_dates}  → "October 17–26, 2026"   (data/ugo.yaml trip)
#   {trip_year}   → "2026"                  (data/ugo.yaml trip)
#   {box_price}   → "$20"                   (data/designations.yaml)
#
# ⚠️ Aid goes out on discrete trips (#43). Nothing here may imply year-round
# or monthly distribution: frame gifts as preparing boxes ahead of a trip.

hero:
  tagline: "Bringing Hope to Ukraine"

stats:
  heading: "Real ground covered."
  text: "Years into the war, the cameras have moved on — but these families are still waiting, and the need is still real. We were able to go. So we did. And in {trip_year}, we're going back."

what:
  heading: "What is UGO?"
  body: |
    Ukraine Gospel Outreach is a ministry of Euro Team Outreach, based in the western Ukrainian city of Lviv. From there, small teams make short trips — five to ten days — into cities and villages across the country, including places the russian army once occupied. We come to do two things at once: meet urgent physical needs with hand-delivered aid, and share the reason for our hope, the Gospel of Jesus Christ. Along the way, we build real relationships with the people we meet.

    And we speak the language. When we preach, we preach in Ukrainian — directly, in the language of the country these families love. There is a particular trust that forms when the person bringing you the Gospel can also sit at your kitchen table and talk.

    If you've walked with us for years, you'll recognize the heart behind it. From 2006 to 2023, our Carpathian Mountain Outreach sent thirteen projects into the mountains of western Ukraine. The war closed that chapter, but not its purpose. UGO is its spiritual successor — the methods have changed to meet a harder moment, but the message has not.
  quote: "They departed not only with freshly baked bread to nourish their bodies, but having heard of the Bread of Life."
  quote_source: "from the first project, Mykolaiv region, November 2024"

model:
  heading: "The Gospel and a box of food"
  body: |
    In each village, word goes out and people gather. We share the good news of Jesus, and everyone who comes goes home with their hands full — a box of food in one hand, a bundle of Bible literature in the other. The Gospel and the aid arrive together; that is the whole idea.

    For most of our years in Ukraine, we held to one task: preaching the Gospel and teaching the Bible. We were wary of handing out aid alongside it — afraid it might blur the message, or gather a crowd hungry only for what was in the box. Then came the war, and a scale of suffering we could not preach past. So we went back to Scripture. *"If a brother or sister be naked, and destitute of daily food,"* James asks, and you offer them only words — *"what doth it profit?"* We could no longer tell cold, hungry families to be warmed and filled and do nothing. So now we come with both: food for the body, and the good news that outlasts the war.
  # KJV, verbatim (#45). The passage the paragraph above quotes in part.
  scripture:
    text: "If a brother or sister be naked, and destitute of daily food, And one of you say unto them, Depart in peace, be ye warmed and filled; notwithstanding ye give them not those things which are needful to the body; what doth it profit?"
    ref: "James 2:15–16"
  # Gospel first, aid second (#46): the order of these two is the point.
  columns:
    - heading: "Gospel"
      photo: gospel
      body: "At every stop, we preach the good news of Jesus directly, in Ukrainian — the language of the people we serve. Every family also goes home with a bundle of free literature: Gospel tracts, New Testaments, Christian calendars, and ***Good and Evil***, a picture-Bible overview in Ukrainian that has opened more conversations than we can count. They take printed lessons for **Bible First**, our free Bible course, too — paper copies that need no smartphone or signal, which matters where phones are old and coverage is thin (anyone who prefers can enroll and study online instead). UGO is how all of it reaches the field: the books into people's hands, the lessons into their homes."
    - heading: "Aid"
      photo: aid
      body: "Each family receives an aid box — about **{box_price}** of non-perishable food and household essentials: flour, cooking oil, beans, rice, canned meat. Wherever we can, we add fresh bread, baked locally that morning. It will not undo what the war has broken. But it is real food in real hands, and it carries a message of its own: *you have not been forgotten.*"
  # Pre-UGO track (#21): /good-and-evil/ goes through the fallback proxy to a
  # legacy redirect stub, which sends the visitor off-site to
  # goodandevilbook.com (http only). Bible First's own site is live. Both move
  # to on-site pages in Phase 2.
  links:
    - label: "Learn about Good and Evil"
      href: "/good-and-evil/"
    - label: "Explore Bible First"
      href: "https://getbiblefirst.com/"

# Rewritten from the draft for the 2026 trip: visitors arrive from the field
# videos while the team is on the road, so this no longer says "planning".
next:
  heading: "We're going back"
  body: |
    The next UGO project runs **{trip_dates}** — the same core team, the same long drive south, into the de-occupied villages of the Mykolaiv region and beyond. These are the places where the war came closest, and where help is now hardest to find.

    In one village on an earlier trip, a woman told us the larger aid organizations had mostly stopped coming once the early years of the war had passed. We can't speak to anyone else's work — much of it did real good, on a scale we will never match. We can only tell you what we have seen with our own eyes: the families are still there, the winters are still hard, and the need has not eased. So we are going back.

    Every aid box has to be bought and packed before the team can hand it out, and each gift helps prepare the boxes for a trip south. {box_price} fills one box: food for a family, and the Gospel placed in their hands.

    If you would like to stand with us in this, there is a place for you. Here's how.

# The three doorways. Change them with the home page's (content/_index.md).
involved:
  heading: "Three ways to stand with us"
  doorways:
    - heading: "Pray"
      icon: hand-raised
      body: "We need God's blessing, protection, and intervention. *\"Except the LORD build the house…\"* Please pray with us for safety on the roads, for open doors in the villages, and for the families who will hear the Gospel on the next trip. As the project draws near, we'll send you specific things to pray for."
      label: "Follow along and pray"
      href: "/pray/"
    - heading: "Go"
      icon: map
      body: "God wants you to go and share Christ with the world. Over the years, dozens of young people have joined us in Ukraine to learn first-hand what it means to be a missionary. If you'd like to find out what it takes to serve on a UGO team, reach out — let's talk."
      label: "Serve with us"
      href: "/serve/"
    - heading: "Give"
      icon: gift
      body: "{box_price} puts one aid box — food and the Gospel — into a family's hands. Give once, or give monthly to help us prepare for the next trip."
      give: true # label and link come from give: below

give:
  heading: "Fill a box for a family"
  body: |
    A single gift becomes food on a table and the Gospel in a family's hands — delivered in person by our own team.

    Give once, or give monthly — a recurring gift quietly adds up between trips, so the boxes are ready to load when the team heads south. Every gift directly purchases supplies, hand-delivered to Ukrainian families in need.
  # Sits directly above the price table, so it introduces the table at
  # every width (beside the body on desktop, below it on a phone).
  table_label: "Here is what your giving does:"
  label: "Give an aid box"
  note: "Your gift goes to the UGO aid-box fund."

field:
  heading: "From the field"
  intro: "Short updates filmed on the road, and photos from the villages."
  playlist_label: "Watch the full playlist on YouTube"
  close: "Help fill the next box for a family."
---

We carry the Gospel of Jesus Christ and practical, hand-delivered aid into Ukrainian communities near the front — village by village, box by box.
