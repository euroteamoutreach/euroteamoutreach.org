#!/usr/bin/env ruby
# frozen_string_literal: true

# migrate.rb — convert the 29 legacy Middleman blog posts to Hugo content.
#
# Adapted from ofreport's scripts/migrate.rb (runner, skip-if-exists guard,
# hard assertions, audit CSV) and its cleanup passes (entities, curly quotes,
# Lviv). ofreport's source was Nuxt components; ours is Kramdown, so the
# conversions are new:
#
#   * Image blocks — a linked thumbnail, its attribute line, and an optional
#     caption line with its own attribute line:
#
#       [![Description](assets/images/blog/2018/x-550w.jpg)](assets/images/blog/2018/x-2000w.jpg)
#       {: .article-image .article-image--has-caption}
#       The caption.
#       {: .caption-text .article-image__caption}
#
#     become {{< figure >}} on the full-size file, uploaded to Cloudinary under
#     a public ID derived from its path (blog/2018/x). Every legacy alt is the
#     literal "Description", so none is carried over: the caption serves, and
#     an uncaptioned image takes its alt from the fixes file.
#   * Vimeo/YouTube iframes in a video-wrapper div -> {{< vimeo >}} / {{< youtube >}}.
#   * The one self-hosted <video> -> a raw <figure><video> on Cloudinary.
#   * Links styled with .article-button -> {{< button >}}.
#   * Kramdown attribute lines ({: …}), READMORE markers, raw <a>, <br> and
#     nowrap <span> are removed or converted.
#   * Copy conventions: "Lviv", and lowercase "russia"/"russian" except at the
#     start of a sentence or inside a quotation, which are reported.
#
# Every hand decision lives in scripts/blog-migration-fixes.yml (descriptions,
# alt text, exact-match text replacements), so a --force re-run reproduces the
# manual fix pass instead of wiping it.
#
# Outputs:
#   content/blog/YYYY-MM-DD-slug.md
#   tmp/blog-migration/images.tsv  — source → public ID, read by upload-blog-images.rb
#   tmp/blog-migration/audit.csv   — one row per post
#
# Ruby stdlib only.
#
# Usage:
#   ruby scripts/migrate.rb              # write new posts (skip existing)
#   ruby scripts/migrate.rb --force      # re-migrate all (overwrites)
#   ruby scripts/migrate.rb --dry-run    # transform + validate + report only

require "yaml"
require "fileutils"
require "optparse"
require "csv"
require "date"

module Migrate
  module_function

  FIELD_ORDER = %w[title date author description tags cover caption slug aliases].freeze
  REQUIRED_FIELDS = %w[title date author description cover slug aliases].freeze

  # The legacy asset host. Nothing in a migrated post may point at it.
  LEGACY_ASSET_HOST = "d2ppgd6w5akw3v.cloudfront.net"

  # Leftovers the conversions must eliminate. Any hit fails the run.
  GAP_PATTERNS = {
    "<img>" => /<img\b/i,
    "<iframe>" => /<iframe\b/i,
    "raw <a>" => /<a\s/i,
    "Kramdown attribute {:" => /\{:/,
    "READMORE" => /READMORE/,
    "legacy assets/images path" => %r{assets/images},
    "legacy asset host" => /#{Regexp.escape(LEGACY_ASSET_HOST)}/,
    "legacy blog URL" => %r{euroteamoutreach\.org/blog/|\]\(/blog/\d{4}/\d{2}/},
    "L'viv spelling" => /L['’]{1,2}viv/
  }.freeze

  # Raw HTML intentionally kept, reported as the manual-review worklist.
  RESIDUAL_PATTERNS = {
    "<video> figure" => /<video\b/i,
    "<span>" => /<span\b/i,
    "<div>" => /<div\b/i,
    "<br>" => /<br\b/i,
    "other HTML tag" => %r{<(?!/?(?:video|figure|figcaption|span|div|br)\b)/?[a-z][^>\n]*>}i
  }.freeze

  # --- helpers --------------------------------------------------------------

  def present?(value)
    !value.nil? && !value.to_s.strip.empty?
  end

  # A Hugo shortcode named-parameter value (a Go interpreted string literal).
  def quote(value)
    escaped = value.to_s.gsub("\\") { "\\\\" }.gsub('"') { '\\"' }
    %("#{escaped}")
  end

  # Pixel size of a JPEG or PNG, read from its header. No image in the set
  # carries an EXIF rotation (checked 2026-11-18), so header size is display size.
  def image_size(path)
    File.open(path, "rb") do |f|
      head = f.read(24)
      return head[16, 8].unpack("NN") if head.start_with?("\x89PNG".b)
      raise "not a JPEG or PNG: #{path}" unless head.start_with?("\xFF\xD8".b)

      f.seek(2)
      loop do
        byte = f.readbyte
        next unless byte == 0xFF

        type = f.readbyte
        type = f.readbyte while type == 0xFF
        len = f.read(2).unpack1("n")
        if (0xC0..0xCF).cover?(type) && ![0xC4, 0xC8, 0xCC].include?(type)
          f.read(1)
          h, w = f.read(4).unpack("nn")
          return [w, h]
        end
        f.seek(len - 2, IO::SEEK_CUR)
      end
    end
  end

  # The public ID for a legacy blog image: its path under assets/images,
  # lowercased, without the extension and the export-size suffix
  # (-2000w, -550h, -1200x630, -1200-630, -lg, _1920, a bare -2000). A bare
  # number that looks like a year (2005–2030) is part of the name and stays.
  #   blog/2022/cmo-2022-ann-cover-1200x630-lg.jpg -> blog/2022/cmo-2022-ann-cover
  def public_id(rel)
    dir = File.dirname(rel)
    base = File.basename(rel, ".*").downcase
    loop do
      stripped = base.sub(/[-_](?:\d{3,4}[wh]|\d{3,4}[x-]\d{3,4}|lg)\z/, "")
      if stripped == base
        stripped = base.sub(/[-_](\d{3,4})\z/) { (2005..2030).cover?(Regexp.last_match(1).to_i) ? Regexp.last_match(0) : "" }
      end
      break if stripped == base

      base = stripped
    end
    "#{dir}/#{base}"
  end

  # --- cleanup passes (ported from ofreport) -------------------------------

  ENTITIES = {
    "&mdash;" => "—", "&ndash;" => "–", "&ldquo;" => "“", "&rdquo;" => "”",
    "&lsquo;" => "‘", "&rsquo;" => "’", "&#39;" => "’", "&apos;" => "’",
    "&nbsp;" => " ", "&amp;" => "&"
  }.freeze
  HTML_TAG = %r{</?[a-zA-Z][^>\n]*>}
  ENTITY_TOKEN = Regexp.union(HTML_TAG, Regexp.union(ENTITIES.keys))

  def decode_entities(text)
    text.gsub(ENTITY_TOKEN) { |m| ENTITIES.fetch(m, m) }
  end

  def normalize_lviv(text)
    text.gsub(/L['’]{1,2}viv/, "Lviv")
  end

  # Curly quotes, as ofreport's normalize_curly_quotes.rb: shortcode tags,
  # HTML tags, link destinations and URLs are protected.
  OPENING_BEFORE = /[\s(\[{<“‘—–*_]/
  CURL_TOKEN = Regexp.union(
    /\{\{[<%].*?[%>]\}\}/, HTML_TAG, /\]\([^)\n]*\)/, %r{https?://\S+}, /['"]/
  )

  def curl_char(quote, pre)
    return "’" if quote == "'"

    pre.empty? || OPENING_BEFORE.match?(pre[-1]) ? "“" : "”"
  end

  def curl(text)
    text.gsub(CURL_TOKEN) do |m|
      %w[' "].include?(m) ? curl_char(m, Regexp.last_match.pre_match) : m
    end
  end

  # The prose passes every caption, title and body line gets.
  def prose(text)
    curl(normalize_lviv(decode_entities(text.to_s)))
  end

  # --- links ------------------------------------------------------------------

  STATIC_LINKS = {
    "/contact" => "/contact/",
    "/subscribe" => "/subscribe/",
    "/donate/" => "/give/"
  }.freeze

  LEGACY_POST_URL = %r{\A(?:https?://(?:www\.)?euroteamoutreach\.org)?/blog/(\d{4})/(\d{2})/([\w-]+)/?\z}

  # Rewrite a link target that points at a moved page on this site. Links to a
  # legacy post go to its new permalink; `posts` maps "YYYY/MM/title" -> slug.
  def rewrite_href(href, posts)
    href = href.strip
    return STATIC_LINKS[href] if STATIC_LINKS.key?(href)

    if (m = href.match(LEGACY_POST_URL))
      slug = posts["#{m[1]}/#{m[2]}/#{m[3]}"] or raise "link to unknown legacy post #{href}"
      return "/blog/#{slug}/"
    end
    href
  end

  # --- body conversions -----------------------------------------------------

  VIDEO_WRAPPER_RE = %r{<div\s+class="video-?wrapper">\s*<iframe\b[^>]*?\bsrc="([^"]+)"[^>]*>\s*</iframe>\s*</div>}im

  # The one self-hosted video, its attribute line, and its caption block.
  VIDEO_RE = %r~
    <video\b[^>]*>\s*<source\s+src="([^"]+)"[^>]*>.*?</video>[ \t]*\n
    (?:\{:[^}\n]*\}[ \t]*\n)?
    (?:([^\n{][^\n]*)\n\{:[ \t]*\.caption-text[^}\n]*\}[ \t]*(?:\n|\z))?
  ~mx

  IMAGE_BLOCK_RE = %r~
    ^\[!\[[^\]]*\]\(/?assets/images/([^)\s]+)\)\]\(([^)\s]+)\)(?:\{:[^}\n]*\})?[ \t]*\n
    \{:[^}\n]*\}[ \t]*(?:\n|\z)
    (?:(?![ \t]*\n)(?!\{:)([^\n]+)\n\{:[ \t]*\.caption-text[^}\n]*\}[ \t]*(?:\n|\z))?
  ~x

  # A button, with the centred line that introduces it when there is one
  # ("View the full Week 1 photo album…", marked .article-item-center).
  BUTTON_RE = %r~
    (?:^([^\n{][^\n]*)\n\{:[^}\n]*\.article-item-center[^}\n]*\}[ \t]*\n\n)?
    ^\[([^\]\n]+)\]\(([^)\s]+)\)\{:[^}\n]*\.article-button[^}\n]*\}[ \t]*\n?
    (?:\{:[^}\n]*\}[ \t]*(?:\n|\z))?
  ~x

  ANCHOR_RE = %r{<a\s[^>]*?\bhref="([^"]+)"[^>]*>(.*?)</a>}im

  def convert_iframe(src)
    if (id = src[%r{youtube\.com/embed/([\w-]+)}, 1])
      "{{< youtube #{id} >}}"
    elsif (id = src[%r{vimeo\.com/(?:video/)?(\d+)}, 1])
      "{{< vimeo #{id} >}}"
    else
      raise "unrecognized iframe #{src}"
    end
  end

  # A legacy full-size link that names a missing file (one does: beach-2-2000w
  # is really -1600w) falls back to the largest sibling export of the same image.
  def resolve_image(rel, legacy_root, notes)
    path = File.join(legacy_root, "assets/images", rel)
    return [rel, path] if File.exist?(path)

    stem = public_id(rel).split("/").last
    candidates = Dir.glob(File.join(File.dirname(path), "*")).select do |p|
      public_id("x/#{File.basename(p)}").split("/").last == stem
    end
    raise "image not found and no sibling export: #{rel}" if candidates.empty?

    best = candidates.max_by { |p| image_size(p).first }
    fixed = File.join(File.dirname(rel), File.basename(best))
    notes << "#{rel} does not exist; used #{fixed}"
    [fixed, best]
  end

  def figure(src_id, size, caption, alt)
    parts = ["src=#{quote(src_id)}"]
    parts << "caption=#{quote(caption)}" if present?(caption)
    parts << "alt=#{quote(alt)}" if present?(alt)
    parts << "width=#{quote(size[0])}" << "height=#{quote(size[1])}"
    "{{< figure #{parts.join(' ')} >}}\n"
  end

  def video_figure(src_id, caption, cloud_base)
    video = "#{cloud_base}/video/upload/q_auto/#{src_id}.mp4"
    poster = "#{cloud_base}/video/upload/so_0,f_auto,q_auto,w_720/#{src_id}.jpg"
    caption_html = present?(caption) ? %(\n  <figcaption class="mx-auto mt-3 max-w-prose text-center text-caption text-warm-600">#{caption}</figcaption>) : ""
    <<~HTML
      <figure class="not-prose my-8 md:my-10">
        <video class="mx-auto max-h-[36rem] w-auto max-w-full rounded-eto bg-warm-100" controls preload="none" poster="#{poster}" src="#{video}"></video>#{caption_html}
      </figure>
    HTML
  end

  # Join hard-wrapped prose lines (only the 2025 posts are wrapped). A line
  # joins the one above when both are plain prose or a list item and its
  # continuation; structural lines (headings, quotes, shortcodes, HTML, rules,
  # list markers) and hard breaks (a trailing backslash) never join.
  STRUCTURAL = %r{\A\s*(?:[#>|<]|\{\{|\{\.|---|[-*+]\s|\d+\.\s|\z)}

  def unwrap(text)
    out = []
    text.each_line(chomp: true) do |line|
      prev = out.last
      if prev && !prev.strip.empty? && !prev.end_with?("\\") && !prev.lstrip.start_with?("#", "{{", "<", "|", "---") &&
         !line.strip.empty? && !line.match?(STRUCTURAL)
        out[-1] = "#{prev.rstrip} #{line.strip}"
      else
        out << line
      end
    end
    out.join("\n")
  end

  # Markdown style for the linter: "-" bullets, "_" emphasis.
  def lint_style(text)
    text = text.gsub(/^(\s*)\* /, '\1- ')
    text.gsub(/(?<![*\\\w])\*(?![\s*])([^*\n]+?)(?<![\s*])\*(?![*\w])/, '_\1_')
  end

  # The post page's title is its h1, but the legacy bodies start at h3. Shift
  # every heading so the highest one in a post is an h2.
  def shift_headings(text)
    levels = text.scan(/^(#+)\s/).map { |(h)| h.length }
    shift = levels.empty? ? 0 : levels.min - 2
    return text if shift <= 0

    text.gsub(/^(#+)(?=\s)/) { "#" * (Regexp.last_match(1).length - shift) }
  end

  # Number ordered lists 1, 2, 3 (Kramdown writes every item as "1."). Items
  # separated only by blank lines or indented continuations are one list.
  def renumber_lists(text)
    n = 0
    text.each_line.map do |line|
      if (m = line.match(/\A(\d+)\.(\s.*)\z/m))
        n += 1
        "#{n}.#{m[2]}"
      else
        n = 0 unless line.strip.empty? || line.start_with?(" ", "\t")
        line
      end
    end.join
  end

  def transform_body(body, ctx)
    notes = ctx[:notes]
    out = body.gsub("\r\n", "\n")
    out = out.gsub(/READMORE/, "")
    # An author's note to self, written as a Markdown comment.
    out = out.gsub(/^\[comment\]: <>.*\n?/, "")
    # A bare number answering a question ("17.") is not a list.
    out = out.gsub(/^(\d+)\.[ \t]*$/, '\1\.')
    out = out.gsub(VIDEO_WRAPPER_RE) { convert_iframe(Regexp.last_match(1)) }

    out = out.gsub(VIDEO_RE) do
      url = Regexp.last_match(1)
      caption = Regexp.last_match(2)
      id = "blog/#{ctx[:date][0, 4]}/#{File.basename(url, '.*').downcase}"
      ctx[:images] << { source: url, public_id: id, type: "video" }
      video_figure(id, caption && prose(caption.strip), ctx[:cloud_base])
    end

    out = out.gsub(BUTTON_RE) do
      lead, label, target = Regexp.last_match.captures
      text = prose(label.strip)
      href = rewrite_href(target, ctx[:posts])
      # The shortcode sets the lead in bold itself; it comes first, in
      # reading order.
      lead &&= "lead=#{quote(prose(lead.strip.delete_prefix('**').delete_suffix('**')))} "
      "{{< button #{lead}href=#{quote(href)} text=#{quote(text)} >}}\n"
    end

    out = out.gsub(IMAGE_BLOCK_RE) do
      thumb, target, caption = Regexp.last_match.captures
      # The link normally opens the full-size export. Two images link out to
      # another site instead; they show their thumbnail, without the link.
      full_rel = target[%r{\A/?assets/images/(.+)\z}, 1]
      notes << "image #{thumb} linked to #{target}; link dropped" unless full_rel
      full_rel ||= thumb
      rel, path = resolve_image(full_rel, ctx[:legacy_root], notes)
      id = public_id(rel)
      ctx[:images] << { source: path, public_id: id, type: "image" }
      caption = caption_text(caption, ctx[:posts])
      alt = ctx[:fixes].dig("alts", id)
      ctx[:missing_alt] << id if !present?(caption) && !present?(alt)
      figure(id, image_size(path), caption, alt)
    end

    out = strip_inline_ials(out)
    # A callout (a verse, an address, a line introducing photos) was centred
    # with .article-item-center; it keeps that as a Goldmark block attribute.
    # Every other attribute line goes; a rule straight after text would read
    # as a setext heading, so it gets a blank line above it.
    out = out.gsub(/^\{:[ \t]*\.article-item-center[ \t]*\}[ \t]*$/, "{.text-center}")
    out = out.gsub(/^\{:[^}\n]*\}[ \t]*\n?/, "")
    out = out.gsub(/([^\n])\n---[ \t]*\n/, "\\1\n\n---\n")

    out = convert_anchors(out)
    out = out.gsub(%r{<span\s+style="white-space:\s*nowrap">(.*?)</span>}i, '\1')
    out = out.gsub(%r{<br\s*/?>[ \t]*$}i, "\\")
    out = out.gsub(/[ \t]{2,}$/, "\\")
    out = rewrite_links(out, ctx[:posts])
    out = prose(out)
    out = lint_style(out)
    out = unwrap(out)
    out = renumber_lists(shift_headings(out))
    out = out.gsub(/[ \t]+$/, "").gsub(/(?<=\S) {2,}(?=\S)/, " ")
    out = out.gsub(/\n{3,}/, "\n\n").strip + "\n"
    # Testimonials written as separate quotes, one after another, are meant
    # to stay separate; the linter reads the gap as a broken blockquote.
    out = "<!-- markdownlint-disable MD028 -->\n\n#{out}" if out.match?(/^>[^\n]*(?:\n[^\n]+)*\n\n>/)
    out
  end

  # Raw <a> -> a Markdown link; the site decides new-tab behaviour by domain.
  def convert_anchors(text)
    text.gsub(ANCHOR_RE) do
      target, label = Regexp.last_match.captures
      "[#{label.strip}](#{target.gsub('&amp;', '&')})"
    end
  end

  def strip_inline_ials(text)
    text.gsub(/\)\{:[^}\n]*\}/, ")")
  end

  def rewrite_links(text, posts)
    text.gsub(/\]\(([^)\s]+)\)/) { "](#{rewrite_href(Regexp.last_match(1), posts)})" }
  end

  # One pipeline for figure and cover captions alike.
  def caption_text(raw, posts)
    raw && rewrite_links(prose(convert_anchors(strip_inline_ials(raw.strip))), posts)
  end

  # --- fixes file -------------------------------------------------------------

  # Exact-match replacements from the fixes file. Each `from` must occur exactly
  # once, so a fix that no longer matches (after a script change) fails loudly.
  def apply_replacements(text, list, slug, field, errors)
    Array(list).each do |fix|
      from = fix.fetch("from")
      count = text.scan(from).size
      if count == 1
        text = text.sub(from) { fix.fetch("to") }
      else
        errors << "#{slug} #{field}: replacement matched #{count} times: #{from[0, 60].inspect}"
      end
    end
    text
  end

  # --- russia -----------------------------------------------------------------

  RUSSIA_RE = /\bRussia(?:n|ns)?\b/

  # Lowercase "Russia"/"Russian" mid-sentence. A use at the start of a sentence,
  # a caption or a heading, or inside a quotation, is left and returned for the
  # report; the fixes file rephrases those, and the run fails while any remain.
  def lowercase_russia(text)
    kept = []
    out = text.each_line.map do |line|
      line.gsub(RUSSIA_RE) do |word|
        pre = Regexp.last_match.pre_match
        bare = pre.sub(/[\s*_“"‘(\[#>-]+\z/, "")
        initial = bare.empty? || bare.match?(/[.!?:]\z/) || bare.end_with?("caption=")
        quoted = pre.count("“") > pre.count("”")
        if initial || quoted
          kept << "#{initial ? 'sentence start' : 'in quotation'}: …#{pre[-50..] || pre}#{word}…"
          word
        else
          word.downcase
        end
      end
    end.join
    [out, kept]
  end

  # --- per-file pipeline --------------------------------------------------------

  FRONTMATTER_RE = /\A---\s*\n(.*?\n)---\s*\n?(.*)\z/m
  SOURCE_NAME_RE = /\A(\d{4})-(\d{2})-([\w-]+)\.html\.markdown\z/

  # A legacy post's key in `posts` ("YYYY/MM/title"), from its file name.
  def legacy_key(path)
    m = File.basename(path).match(SOURCE_NAME_RE) or raise "unexpected filename #{File.basename(path)}"
    m.captures.join("/")
  end

  def front_matter(text, **opts)
    YAML.safe_load(text[FRONTMATTER_RE, 1] || "", **opts) || {}
  end

  # The new slug is the post's exact date plus its legacy title slug.
  def new_slug(path)
    "#{front_matter(File.read(path))['date']}-#{legacy_key(path).split('/').last}"
  end

  def process_file(path, posts:, fixes:, legacy_root:, cloud_base:)
    year, month, title_slug = legacy_key(path).split("/")
    slug = posts.fetch(legacy_key(path))

    raw = File.read(path)
    fm_match = raw.match(FRONTMATTER_RE) or raise "no front matter"
    fm = front_matter(raw)
    date = fm["date"].to_s

    errors = []
    errors << "filename month #{year}-#{month} != date #{date}" unless date.start_with?("#{year}-#{month}")

    ctx = { notes: [], images: [], missing_alt: [], posts: posts, fixes: fixes,
            legacy_root: legacy_root, cloud_base: cloud_base, date: date }
    post_fixes = fixes.dig("posts", slug) || {}

    body = transform_body(fm_match[2], ctx)
    body = apply_replacements(body, post_fixes["body"], slug, "body", errors)
    body, kept_body = lowercase_russia(body)

    cover_rel, cover_path = resolve_image(fm["image_lg"] || fm["image"], legacy_root, ctx[:notes])
    cover_id = public_id(cover_rel)
    ctx[:images] << { source: cover_path, public_id: cover_id, type: "image" }

    title = prose(fm["title"])
    caption = caption_text(fm["caption"], posts)
    caption = apply_replacements(caption, post_fixes["caption"], slug, "caption", errors) if caption
    caption, kept_caption = caption ? lowercase_russia(caption) : [nil, []]

    # Every description is hand-written in the fixes file; the report fails a
    # post without one.
    description, kept_desc = lowercase_russia(prose(post_fixes["description"]))
    kept = kept_body + kept_caption + kept_desc

    # Legacy wrote a linked author as [name, handle, "@tw"], which a Middleman
    # helper turned into a social link. Authors are plain names now.
    author = Array(fm["author"]).first.to_s.strip
    errors << "author is not a plain name: #{author.inspect}" unless author.match?(/\A[\p{L}][\p{L} .'’-]*\z/)

    out = {
      "title" => title,
      "date" => Date.parse(date),
      "author" => author,
      "description" => present?(description) ? description : nil,
      "tags" => [],
      "cover" => cover_id,
      "caption" => caption,
      "slug" => slug,
      "aliases" => ["/blog/#{year}/#{month}/#{title_slug}/"]
    }
    ordered = FIELD_ORDER.each_with_object({}) { |k, h| h[k] = out[k] unless out[k].nil? }
    yaml = YAML.dump(ordered, line_width: -1).sub(/\A---\s*\n/, "")

    {
      slug: slug,
      content: "---\n#{yaml}---\n\n#{body}",
      images: ctx[:images],
      missing_required: REQUIRED_FIELDS.reject { |f| f == "aliases" ? out[f]&.any? : present?(out[f]) },
      description_written: present?(post_fixes["description"]),
      gaps: GAP_PATTERNS.select { |_, re| body.match?(re) || caption.to_s.match?(re) }.keys,
      residual: RESIDUAL_PATTERNS.select { |_, re| body.match?(re) }.keys,
      missing_alt: ctx[:missing_alt],
      russia_kept: kept,
      figures: body.scan("{{< figure ").size,
      errors: errors,
      notes: ctx[:notes]
    }
  end

  # --- runner -----------------------------------------------------------------

  def run(dest:, legacy_root:, fixes_path:, out_dir:, cloud_base:, dry_run:, force:)
    source = File.join(legacy_root, "blog/articles")
    files = Dir.glob(File.join(source, "*.html.markdown")).sort
    abort "No source posts found in #{source}" if files.empty?

    fixes = File.exist?(fixes_path) ? (YAML.safe_load_file(fixes_path) || {}) : {}
    posts = files.to_h { |p| [legacy_key(p), new_slug(p)] }

    FileUtils.mkdir_p(dest) unless dry_run
    results = []
    written = []
    skipped = []
    failures = []

    files.each do |path|
      r = process_file(path, posts: posts, fixes: fixes, legacy_root: legacy_root, cloud_base: cloud_base)
      results << r
      target = File.join(dest, "#{r[:slug]}.md")
      if File.exist?(target) && !force
        skipped << r[:slug]
        next
      end
      File.write(target, r[:content]) unless dry_run
      written << r[:slug]
    rescue StandardError => e
      failures << "#{File.basename(path)}: #{e.message}"
    end

    images = write_manifest(out_dir, results)
    write_audit(File.join(out_dir, "audit.csv"), results)
    diffs = write_text_diffs(out_dir, files.to_h { |p| [posts.fetch(legacy_key(p)), p] }, dest)
    report(total: files.size, results: results, written: written, skipped: skipped, diffs: diffs,
           failures: failures, images: images, dry_run: dry_run, force: force, out_dir: out_dir)
  end

  # --- review diff -------------------------------------------------------------

  # The words a reader sees, with markup stripped and quotes, case and the Lviv
  # spelling folded, so a diff of legacy against output shows only real text
  # changes: dropped words, the fixes file's edits, removed dead links.
  def reader_words(text, legacy:)
    t = text.sub(FRONTMATTER_RE) { Regexp.last_match(2) }.gsub(/<!--.*?-->/m, " ")
    if legacy
      t = t.gsub(/\{:[^}\n]*\}/, "").gsub("READMORE", " ").gsub(/!\[[^\]]*\]\([^)]*\)/, "")
      t = convert_anchors(t)
    else
      # Keep a shortcode's visible text (caption, button label), drop the rest.
      t = t.gsub(/\{\{<\s*\w+(.*?)>\}\}/m) { Regexp.last_match(1).scan(/\b(?:caption|lead|text)="((?:[^"\\]|\\.)*)"/).join(" ") }
      t = t.gsub(/^\{\.[^}\n]*\}$/, "")
    end
    t = t.gsub(/\]\([^)]*\)/, "]").gsub(%r{</?[a-z][^>]*>}i, " ").gsub(%r{https?://\S+}, " ")
    t = normalize_lviv(decode_entities(t)).tr("“”‘’", %q(""'')).downcase
    t.scan(/[\p{L}\p{N}'$%]+/)
  end

  # Writes tmp/blog-migration/diff/<slug>.diff (unified, one word per line)
  # and returns { slug => changed-word count }. Uses the system diff.
  # The words of a post file's title, caption and body, one per line.
  def word_lines(path, legacy:)
    text = File.read(path)
    fm = front_matter(text, permitted_classes: [Date])
    words = reader_words([fm["title"], fm["caption"]].compact.join(" "), legacy: legacy) +
            reader_words(text, legacy: legacy)
    "#{words.join("\n")}\n"
  end

  # `sources` maps each new slug to its legacy source file.
  def write_text_diffs(out_dir, sources, dest)
    dir = File.join(out_dir, "diff")
    FileUtils.mkdir_p(dir)
    sources.to_h do |slug, path|
      target = File.join(dest, "#{slug}.md")
      next [slug, nil] unless File.exist?(target)

      a = File.join(dir, "#{slug}.legacy.txt")
      b = File.join(dir, "#{slug}.new.txt")
      File.write(a, word_lines(path, legacy: true))
      File.write(b, word_lines(target, legacy: false))
      diff = IO.popen(["diff", "-u", a, b], &:read)
      File.write(File.join(dir, "#{slug}.diff"), diff)
      File.delete(a, b)
      [slug, diff.lines.count { |l| l.match?(/\A[-+](?![-+])/) }]
    end
  end

  # One row per unique upload. Two sources under one public ID is a collision.
  def write_manifest(out_dir, results)
    FileUtils.mkdir_p(out_dir)
    by_id = Hash.new { |h, k| h[k] = [] }
    results.flat_map { |r| r[:images] }.each { |i| by_id[i[:public_id]] << i }
    rows = by_id.map { |id, list| [id, list.map { |i| i[:source] }.uniq, list.first[:type]] }.sort
    File.open(File.join(out_dir, "images.tsv"), "w") do |f|
      rows.each { |id, sources, type| f.puts [type, id, sources.first].join("\t") }
    end
    { count: rows.size, collisions: rows.select { |_, s, _| s.size > 1 } }
  end

  def write_audit(path, results)
    CSV.open(path, "w") do |csv|
      csv << %w[slug figures description_written missing_alt residual_html gaps russia_kept notes]
      results.sort_by { |r| r[:slug] }.each do |r|
        csv << [r[:slug], r[:figures], r[:description_written] ? "yes" : "", r[:missing_alt].join("; "),
                r[:residual].join("; "), r[:gaps].join("; "), r[:russia_kept].join(" | "), r[:notes].join("; ")]
      end
    end
  end

  def report(total:, results:, written:, skipped:, diffs:, failures:, images:, dry_run:, force:, out_dir:)
    bar = "=" * 70
    puts bar, "Blog migration #{dry_run ? '(dry run — no posts written)' : 'complete'}", bar
    puts "Guard   : #{force ? 'force (overwrite all)' : 'skip-if-exists'}"
    puts "Posts   : #{total} found · #{written.size} written · #{skipped.size} skipped · #{failures.size} failed"
    puts "Uploads : #{images[:count]} unique files in #{out_dir}/images.tsv"
    puts

    errors = results.flat_map { |r| r[:errors] }
    assertions = [
      ["Post count: #{total} in == #{written.size + skipped.size} out", failures.empty? && written.size + skipped.size == total],
      ["Required front matter present", results.all? { |r| r[:missing_required].empty? }],
      ["Descriptions hand-written for every post", results.all? { |r| r[:description_written] }],
      ["Zero conversion gaps", results.all? { |r| r[:gaps].empty? }],
      ["Every figure has a caption or alt", results.all? { |r| r[:missing_alt].empty? }],
      ["Public IDs unique (one source each)", images[:collisions].empty?],
      ["Every sentence-start/quoted Russia reviewed", results.all? { |r| r[:russia_kept].empty? }],
      ["Filename months match dates; every fix matched once", errors.empty?]
    ]
    puts "VALIDATION (any FAIL fails the run):"
    assertions.each { |name, pass| puts "  [#{pass ? 'PASS' : 'FAIL'}] #{name}" }
    puts

    section = lambda do |title, rows|
      next if rows.empty?

      puts "#{title}:"
      rows.each { |row| puts "  - #{row}" }
      puts
    end
    section.call("FAILED FILES", failures)
    section.call("ERRORS", errors)
    section.call("MISSING FRONT MATTER", results.reject { |r| r[:missing_required].empty? }.map { |r| "#{r[:slug]}: #{r[:missing_required].join(', ')}" })
    section.call("CONVERSION GAPS (must be none)", results.reject { |r| r[:gaps].empty? }.map { |r| "#{r[:slug]}: #{r[:gaps].join(', ')}" })
    section.call("FIGURES NEEDING ALT TEXT (add to fixes alts:)", results.flat_map { |r| r[:missing_alt].map { |id| "#{r[:slug]}: #{id}" } })
    section.call("PUBLIC ID COLLISIONS", images[:collisions].map { |id, s, _| "#{id}: #{s.join(', ')}" })
    section.call("RUSSIA LEFT CAPITALIZED", results.flat_map { |r| r[:russia_kept].map { |k| "#{r[:slug]} #{k}" } })
    section.call("RESIDUAL RAW HTML (worklist)", results.reject { |r| r[:residual].empty? }.map { |r| "#{r[:slug]}: #{r[:residual].join(', ')}" })
    section.call("NOTES", results.flat_map { |r| r[:notes].map { |n| "#{r[:slug]}: #{n}" } })
    section.call("TEXT CHANGES vs legacy (words; review #{out_dir}/diff/<slug>.diff)",
                 diffs.select { |_, n| n&.positive? }.map { |slug, n| "#{slug}: #{n}" })
    puts bar
    assertions.all? { |_, pass| pass }
  end
end

if __FILE__ == $PROGRAM_NAME
  repo = File.expand_path("..", __dir__)
  legacy = File.expand_path("../legacy/euroteamoutreach.org/source", repo)
  cloud_base = File.read(File.join(repo, "hugo.toml"))[/cloudinaryBase\s*=\s*"([^"]+)"/, 1]
  options = {
    dest: File.join(repo, "content/blog"),
    legacy_root: legacy,
    fixes_path: File.join(repo, "scripts/blog-migration-fixes.yml"),
    out_dir: File.join(repo, "tmp/blog-migration"),
    cloud_base: cloud_base,
    dry_run: false,
    force: false
  }
  OptionParser.new do |o|
    o.banner = "Usage: ruby scripts/migrate.rb [options]"
    o.on("--legacy PATH", "Legacy Middleman source/ dir") { |v| options[:legacy_root] = File.expand_path(v) }
    o.on("--dest PATH", "Hugo content/blog dir") { |v| options[:dest] = File.expand_path(v) }
    o.on("--dry-run", "Transform + validate + report; write no posts") { options[:dry_run] = true }
    o.on("--force", "Overwrite existing posts") { options[:force] = true }
  end.parse!
  exit(Migrate.run(**options) ? 0 : 1)
end
