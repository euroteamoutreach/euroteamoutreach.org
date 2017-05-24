# This file is for reference only. Actual settings for the production
# environment are stored in the build configuation block in config.rb.

activate :asset_hash, ignore: %r{^files/.*}
activate :asset_host, host: "https://d2amb9pccla9r3.cloudfront.net"

# https://github.com/Aupajo/middleman-search_engine_sitemap
set :url_root, "https://euroteamoutreach.org"
activate :search_engine_sitemap

# https://github.com/fredjean/middleman-s3_sync
activate :s3_sync do |s3|
  s3.bucket = "euroteamoutreach.org"
  s3.aws_access_key_id = ENV["ETO_AWS_ACCESS_KEY_ID"]
  s3.aws_secret_access_key = ENV["ETO_AWS_SECRET_ACCESS_KEY"]
  s3.prefer_gzip = true
  s3.index_document = "index.html"
  s3.error_document = "404.html"
end

# https://github.com/fredjean/middleman-s3_sync#http-caching
default_caching_policy max_age: (60 * 60 * 24 * 365)
caching_policy "text/html", public: true, max_age: 0, must_revalidate: true
