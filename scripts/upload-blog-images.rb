#!/usr/bin/env ruby
# frozen_string_literal: true

# upload-blog-images.rb — upload the legacy blog's images (and its one video)
# to Cloudinary under the exact public IDs scripts/migrate.rb wrote into the
# posts.
#
# Reads tmp/blog-migration/images.tsv (type, public ID, source), written by
# migrate.rb. A source is a local file, or a URL that Cloudinary fetches
# itself (the video on the legacy asset host).
#
# Uploads through the signed Upload API with explicit public IDs, because UI
# uploads add a random suffix (…_pgk6xo) that the posts could not predict.
# overwrite=false makes a re-run safe: an ID that already exists is left as
# it is, so an interrupted run can simply be run again.
#
# Credentials come from CLOUDINARY_URL (cloudinary://key:secret@cloud) in the
# environment. They are never written to the repo. Keep them in a file
# outside it and source that file for the run:
#
#   set -a; source ~/.config/eto/cloudinary.env; set +a
#   ruby scripts/upload-blog-images.rb            # upload what is missing
#   ruby scripts/upload-blog-images.rb --verify   # check every ID delivers (no credentials needed)
#
# The env file holds one line, CLOUDINARY_URL=cloudinary://KEY:SECRET@euro-team-outreach
# (chmod 600). Make a dedicated key for the run in the Cloudinary console
# (Settings → API Keys → Generate New API Key, role Master Admin: the
# read-only roles cannot upload) and delete it afterwards. Leave the
# account's original "root" key alone; Bible First Online v1 may use it.
#
# The account's upload limit is 100 MB. The legacy video was 592 MB, so it
# was re-encoded (ffmpeg, libx264 crf 23, maxrate 2M, 720p) and uploaded from
# the local file; since its ID now exists, a re-run skips it.
#
# Ruby stdlib only.

require "net/http"
require "uri"
require "digest"
require "optparse"

MANIFEST = File.expand_path("../tmp/blog-migration/images.tsv", __dir__)
CLOUD_BASE = File.read(File.expand_path("../hugo.toml", __dir__))[/cloudinaryBase\s*=\s*"([^"]+)"/, 1]

def load_rows
  abort "No manifest at #{MANIFEST}; run scripts/migrate.rb first" unless File.exist?(MANIFEST)
  File.readlines(MANIFEST, chomp: true).map { |line| line.split("\t", 3) }
end

def credentials
  url = ENV.fetch("CLOUDINARY_URL") { abort "CLOUDINARY_URL is not set (source your env file first)" }
  m = url.match(%r{\Acloudinary://([^:]+):([^@]+)@(.+)\z}) or abort "CLOUDINARY_URL is not cloudinary://key:secret@cloud"
  { key: m[1], secret: m[2], cloud: m[3] }
end

# Signed upload over an open connection to api.cloudinary.com. The signature
# covers every param except file, api_key and the resource type, sorted by
# name (Cloudinary's signing rules). A URL source is fetched by Cloudinary.
def upload(http, type, public_id, source, creds)
  params = {
    "asset_folder" => File.dirname(public_id),
    "overwrite" => "false",
    "public_id" => public_id,
    "timestamp" => Time.now.to_i.to_s
  }
  to_sign = params.sort.map { |k, v| "#{k}=#{v}" }.join("&")
  params["signature"] = Digest::SHA1.hexdigest(to_sign + creds[:secret])
  params["api_key"] = creds[:key]

  req = Net::HTTP::Post.new("/v1_1/#{creds[:cloud]}/#{type}/upload")
  file = source.start_with?("http") ? source : File.open(source, "rb")
  req.set_form([["file", file], *params.to_a], "multipart/form-data")
  http.request(req)
ensure
  file.close if file.respond_to?(:close)
end

verify = false
OptionParser.new do |o|
  o.on("--verify", "Check every public ID delivers from Cloudinary") { verify = true }
end.parse!

rows = load_rows

if verify
  cdn = URI(CLOUD_BASE)
  missing = Net::HTTP.start(cdn.host, cdn.port, use_ssl: true) do |http|
    rows.reject do |type, id, _|
      ext = type == "video" ? ".mp4" : ""
      http.head("#{cdn.path}/#{type}/upload/#{id}#{ext}").is_a?(Net::HTTPSuccess)
    end
  end
  puts "#{rows.size - missing.size}/#{rows.size} deliver from Cloudinary"
  missing.each { |type, id, _| puts "  MISSING #{type} #{id}" }
  exit(missing.empty? ? 0 : 1)
end

creds = credentials
failures = 0
Net::HTTP.start("api.cloudinary.com", 443, use_ssl: true, read_timeout: 300) do |http|
  rows.each_with_index do |(type, id, source), i|
    res = upload(http, type, id, source, creds)
    if res.is_a?(Net::HTTPSuccess)
      status = res.body.include?('"existing":true') ? "exists" : "uploaded"
      puts format("%3d/%d  %-8s %s", i + 1, rows.size, status, id)
    else
      failures += 1
      puts format("%3d/%d  %-8s %s", i + 1, rows.size, "FAILED", id)
      puts "        #{res.code} #{res.body[0, 200]}"
    end
  end
end
puts failures.zero? ? "All #{rows.size} in place." : "#{failures} failed; fix and re-run (existing IDs are skipped)."
exit(failures.zero? ? 0 : 1)
