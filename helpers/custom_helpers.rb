module CustomHelpers
  def full_title(site_title, page_title = nil)
    page_title ||= ""
    if page_title.empty?
      site_title
    else
      "#{page_title} | #{site_title}"
    end
  end

  def home_smart_path(path)
    if !!(path =~ /index/)
      "#"
    else
      "/"
    end
  end

  def ministries_smart_path(path)
    if !!(path =~ /index/)
      "#ministries"
    else
      "/#ministries"
    end
  end

  def social_link_for(author)
    if author.to_s.include?("@tw") # We have a Twitter handle
      "<a href=\"https://twitter.com/#{author[1]}\">#{author[0]}</a>"
    elsif author.to_s.include?("@ig") # We have an Instagram handle
      "<a href=\"https://instagram.com/#{author[1]}\">#{author[0]}</a>"
    elsif author.to_s.include?("@fb") # We have an Facebook handle
      "<a href=\"https://facebook.com/#{author[1]}\">#{author[0]}</a>"
    else
      author.to_s
    end
  end

  def feed_author_name(author)
    if author.is_a? Array
      author[0].to_s
    else
      author.to_s
    end
  end

  def smart_robots(path, env)
    if !!(path =~ /thanks/) || env != "production"
      "noindex, nofollow"
    else
      "index, follow"
    end
  end

  # https://robots.thoughtbot.com/organized-workflow-for-svg
  # https://gist.github.com/bitmanic/0047ef8d7eaec0bf31bb
  def inline_svg(filename, options = {})
    root = Middleman::Application.root
    file_path = "#{root}/source/assets/images/#{filename}"
    if File.exist?(file_path)
      file = File.read(file_path).force_encoding("UTF-8")
      doc = Nokogiri::HTML::DocumentFragment.parse file
      svg = doc.at_css "svg"
      svg["class"] = options[:class] if options[:class].present?
      doc
    else
      "file not found: #{file_path}"
    end
  end

  def article_og_desc_for(article, site_desc)
    !article.summary.nil? ? strip_tags(article.summary) : site_desc.to_s
  end
end
