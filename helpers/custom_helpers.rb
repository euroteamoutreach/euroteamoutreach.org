module CustomHelpers
  def full_title(page_title=nil)
    page_title ||= ""
    base_title = "Euro Team Outreach - Missionaries serving Christ in Ukraine"
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
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

  def smart_robots(path)
    if !!(path =~ /thanks/)
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
    if File.exists?(file_path)
      file = File.read(file_path).force_encoding("UTF-8")
      doc = Nokogiri::HTML::DocumentFragment.parse file
      svg = doc.at_css "svg"
      if options[:class].present?
        svg["class"] = options[:class]
      end
      doc
    else
      "file not found: #{file_path}"
    end
  end
end
