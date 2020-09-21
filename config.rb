activate :directory_indexes

set :relative_links, true
set :haml, { format: :html5 }
set :markdown, auto_ids: false

# Disable Haml warnings
Haml::TempleEngine.disable_option_validator!

page "/*.xml", layout: false
page "/*.json", layout: false
page "/*.txt", layout: false
page "/404.html", directory_index: false

set :css_dir, "assets/stylesheets"
set :images_dir, "assets/images"
set :js_dir, "assets/javascripts"

activate :blog do |blog|
  blog.prefix = "blog"
  blog.permalink = "{year}/{month}/{title}.html"
  blog.sources = "articles/{year}-{month}-{title}.html"
  blog.summary_separator = /(READMORE)/
  blog.layout = "article_layout"
  blog.new_article_template = File.expand_path("article-template.erb", File.dirname(__FILE__))
end

configure :build do
  activate :external_pipeline,
           name: :gulp,
           command: "yarn production",
           source: ".tmp",
           latency: 1

  activate :gzip

  ignore "assets/javascripts/all.js"
  ignore "assets/stylesheets/site"

  activate :minify_html do |html|
    html.remove_quotes = false
    html.remove_intertag_spaces = true
  end
end
