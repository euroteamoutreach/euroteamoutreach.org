xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0", "xmlns:media" => "http://search.yahoo.com/mrss/" do
  xml.channel do
    site_url = "#{data.site.url}/"
    xml.title data.site.title
    xml.id URI.join(site_url, blog.options.prefix.to_s)
    xml.link "href" => URI.join(site_url, blog.options.prefix.to_s)
    xml.link "href" => URI.join(site_url, current_page.path), "rel" => "self"
    xml.updated(blog.articles.first.date.to_time.iso8601) unless blog.articles.empty?
    xml.author { xml.name "Euro Team Outreach, Inc." }

    blog.articles[0..9].each do |article|
      xml.item do
        xml.title article.title
        xml.link "rel" => "alternate", "href" => URI.join(site_url, article.url)
        xml.id URI.join(site_url, article.url)
        xml.published article.date.to_time.iso8601
        xml.updated File.mtime(article.source_file).iso8601
        xml.author { xml.name feed_author_name(article.data.author) }
        if article.data.image
          xml.tag!("media:content", {
            "url" => URI.join(site_url, image_path(article.data.image)),
            "medium" => "image",
            "width" => "500",
            "type" => "image/jpg"
          })
        end
        xml.summary article.summary, "type" => "html"
        xml.content article.body, "type" => "html"
      end
    end
  end
end
