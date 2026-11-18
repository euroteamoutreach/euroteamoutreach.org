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
# Ruby stdlib only.

require "net/http"
require "uri"
require "digest"
require "optparse"

MANIFEST = File.expand_path("../tmp/blog-migration/images.tsv", __dir__)
CLOUD_BASE = File.read(File.expand_path("../hugo.toml", __dir__))[/cloudinaryBase\s*=\s*"([^"]+)"/, 1]

def rows
  abort "No manifest at #{MANIFEST}; run scripts/migrate.rb first" unless File.exist?(MANIFEST)
  File.readlines(MANIFEST, chomp: true).map { |line| line.split("\t", 3) }
end

def credentials
  url = ENV.fetch("CLOUDINARY_URL") { abort "CLOUDINARY_URL is not set (source your env file first)" }
  m = url.match(%r{\Acloudinary://([^:]+):([^@]+)@(.+)\z}) or abort "CLOUDINARY_URL is not cloudinary://key:secret@cloud"
  { key: m[1], secret: m[2], cloud: m[3] }
end

# Signed upload. The signature covers every param except file, api_key and
# the resource type, sorted by name (Cloudinary's signing rules).
def upload(type, public_id, source, creds)
  params = {
    "asset_folder" => File.dirname(public_id),
    "overwrite" => "false",
    "public_id" => public_id,
    "timestamp" => Time.now.to_i.to_s
  }
  to_sign = params.sort.map { |k, v| "#{k}=#{v}" }.join("&")
  params["signature"] = Digest::SHA1.hexdigest(to_sign + creds[:secret])
  params["api_key"] = creds[:key]

  uri = URI("https://api.cloudinary.com/v1_1/#{creds[:cloud]}/#{type}/upload")
  req = Net::HTTP::Post.new(uri)
  file = source.start_with?("http") ? source : File.open(source, "rb")
  req.set_form([["file", file], *params.to_a], "multipart/form-data")
  res = Net::HTTP.start(uri.host, uri.port, use_ssl: true, read_timeout: 300) { |http| http.request(req) }
  file.close if file.respond_to?(:close)
  res
end

def delivered?(type, public_id)
  ext = type == "video" ? ".mp4" : ""
  uri = URI("#{CLOUD_BASE}/#{type}/upload/#{public_id}#{ext}")
  res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.head(uri.request_uri) }
  res.is_a?(Net::HTTPSuccess)
end

verify = false
OptionParser.new do |o|
  o.on("--verify", "Check every public ID delivers from Cloudinary") { verify = true }
end.parse!

if verify
  missing = rows.reject { |type, id, _| delivered?(type, id) }
  puts "#{rows.size - missing.size}/#{rows.size} deliver from Cloudinary"
  missing.each { |type, id, _| puts "  MISSING #{type} #{id}" }
  exit(missing.empty? ? 0 : 1)
end

creds = credentials
failures = 0
rows.each_with_index do |(type, id, source), i|
  res = upload(type, id, source, creds)
  status = res.is_a?(Net::HTTPSuccess) ? (res.body.include?('"existing":true') ? "exists" : "uploaded") : "FAILED #{res.code} #{res.body[0, 200]}"
  failures += 1 if status.start_with?("FAILED")
  puts format("%3d/%d  %-8s %s", i + 1, rows.size, status.split.first, id)
  puts "        #{status}" if status.start_with?("FAILED")
end
puts failures.zero? ? "All #{rows.size} in place." : "#{failures} failed; fix and re-run (existing IDs are skipped)."
exit(failures.zero? ? 0 : 1)
