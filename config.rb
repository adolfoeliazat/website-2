##
# Compass
###

# Determine root locale
root_locale = (ENV["LOCALE"] ? ENV["LOCALE"].to_sym : :nl)
# Accessible as `root_locale` in helpers and `config[:root_locale]` in templates
set :root_locale, root_locale

activate :i18n, mount_at_root: root_locale, langs: [:nl, :de]

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", layout: false
# page "/path/to/file.html", layout: :otherlayout

# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

if root_locale == :nl
  # Redirect :de pages
  with_layout :redirect do
    page "/de/*"
  end
end

# Ignore blog for other languages
if root_locale == :de
  ignore "/blog/nl/*"
  ignore "/jobs/nl/*"
elsif root_locale == :nl
  ignore "/blog/de/*"
  ignore "/jobs/de/*"
end

# # Prevent other locales from building (breaks page_classes)
# if root_locale == :nl
#   (langs - [root_locale, :de]).each do |locale|
#     ignore "/#{locale}/*"
#   end
# else
#   (langs - [root_locale]).each do |locale|
#     ignore "/#{locale}/*"
#   end
# end

page "/*.xml", layout: false
page "/*.json", layout: false
page "/*.txt", layout: false

ignore "/fonts/icons/selection.json"

redirect "workshop-convenant-mt.html", to: "convenant-medische-technologie.html"
redirect "elearning.html", to: "e-learning.html"
redirect "elearning-starterkit.html", to: "e-learning-starterkit.html"
redirect "hosting.html", to: "hosting-security.html" if root_locale == :nl
redirect "hosting-security.html", to: "hosting.html" if root_locale == :de
redirect "capp.html", to: "capp-lms.html"
redirect "capp-lms.html", to: "capp-bilden.html" if root_locale == :de
redirect "kundenreferenzen.html", to: "kundenstimmen.html"
redirect "learningspaces.html", to: "capp-agile-learning.html" if root_locale == :nl

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Reload the browser automatically whenever files change
# activate :livereload
# activate :livereload, host: "127.0.0.1"

# Blog
Time.zone = "CET"

activate :blog do |blog|
  blog.name = "blog"
  blog.prefix = "blog"
  blog.permalink = ":title"
  case root_locale
  when :nl
    blog.sources = "/nl/{year}-{month}-{day}-{title}.html"
  when :de
    blog.sources = "/de/{year}-{month}-{day}-{title}.html"
  end
  blog.tag_template = "blog/tag.html"
  # blog.calendar_template = "blog/calendar.html"
  blog.paginate = true
  blog.page_link = "{num}"
  blog.per_page = 10
end

activate :blog do |blog|
  blog.name = "jobs"
  blog.prefix = "jobs"
  blog.permalink = ":title"
  case root_locale
  when :nl
    blog.sources = "/nl/{title}.html"
  when :de
    blog.sources = "/de/{title}.html"
  end
  blog.paginate = false
end

page "blog/*", layout: :blog_post_layout
page "blog/tags/*", layout: :blog_layout
page "blog/index.html", layout: :blog_layout
page "blog/feed.xml", layout: false
page "jobs/*", layout: :jobs_post_layout
page "jobs/index.html", layout: :jobs_layout
page "jobs/feed.xml", layout: false

activate :directory_indexes

activate :autoprefixer do |config|
  config.browsers = ["last 3 versions", "Explorer >= 9"]
end

set :relative_links, true
set :css_dir, "stylesheets"
set :js_dir, "javascripts"
set :images_dir, "images"

# Middleman syntax (https://github.com/middleman/middleman-syntax)
activate :syntax #, line_numbers: true

set :markdown_engine, :kramdown
set :markdown, input: "GFM", auto_ids: false

#set :markdown_engine, :redcarpet
#set :markdown, fenced_code_blocks: true, smartypants: true

###
# Build
###

configure :build do
  # For example, change the Compass output style for deployment
  activate :minify_css

  # Minify Javascript on build
  activate :minify_javascript

  # Enable cache buster
  activate :asset_hash, ignore: "images/blog/featured"

  # Use relative URLs
  # activate :relative_assets

  # Or use a different image path
  # set :http_prefix, "/Content/images/"
end

###
# Deploy
###

# Deploy for each locale
case root_locale
when :nl
  activate :deploy do |deploy|
    deploy.method = :git
    deploy.remote = "git@github.com:DefactoSoftware/website.git"
  end
when :de
  activate :deploy do |deploy|
    deploy.method = :git
    deploy.remote = "git@github.com:DefactoSoftware/website-de.git"
  end
end

###
# Ready callback
###

ready do
  sprockets.import_asset "jquery.js"

  # validate data/downloads.yml
  validate_downloads(data.downloads)
end

after_build do
  # rename CNAME for gh-pages after build
  File.rename "build/CNAME.html", "build/CNAME"
end

###
# Helpers
###

helpers do
  # Get full locale (eg. nl_NL)
  def full_locale(lang=I18n.locale.to_s)
    case lang
      when "en"
        "en_US"
      else
        "#{lang.downcase}_#{lang.upcase}"
    end
  end

  # Get full url
  def full_url(url, locale = I18n.locale)
    URI.join("http://#{I18n.t('CNAME', locale: locale)}", url).to_s
  end

  # Use frontmatter for I18n titles
  def page_title(page, appendCompanyName=true)
    appendTitle = appendCompanyName ? " - Defacto" : ""
    return page.data.title.send(I18n.locale) + appendTitle if
      page.data.title.is_a?(Hash) && page.data.title[I18n.locale]
    return page.data.title + appendTitle if page.data.title
    "Defacto - Developing People"
  end

  # Use frontmatter for meta description
  def meta_description(page = current_page)
    return yield_content(:meta_description) if content_for?(:meta_description)
    return page.data.description.send(I18n.locale) if
      page.data.description.is_a?(Hash) && page.data.description[I18n.locale]
    return page.data.description if page.data.description
    return Nokogiri::HTML(page.summary(160)).text if is_blog_article?
    t("head.default_description")
  end

  # Page body classes
  def page_classes(path = current_path.dup, options = {})
    # Prevent page classes from being translated
    unless I18n.locale == :nl || is_blog?
      default_path = sitemap.resources.select do |resource|
        resource.proxied_to == current_page.proxied_to &&
          resource.metadata[:options][:lang] == :nl
      end.first
      path = default_path.destination_path.dup if default_path
    end

    # Create classes from path
    classes = super(path.sub(/^[a-z]{2}\//, ""), options)

    if is_blog_index?
      # Replace `blog_#_index` with `blog_index`
      classes.sub!(/blog_\d+_index/, "blog_index")
    elsif is_blog_article?
      classes += " blog-article"
    end

    # Prepend language class
    classes.prepend("#{I18n.locale} ")
  end

  # Localized link_to
  def locale_link_to(*args, &block)
    url_arg_index = block_given? ? 0 : 1
    options_index = block_given? ? 1 : 2
    args[options_index] ||= {}
    options = args[options_index].dup
    args[url_arg_index] = locale_url_for(args[url_arg_index], options)
    link_to(*args, &block)
  end

  # Localized url_for
  def locale_url_for(url, options={})
    locale = options[:locale] || I18n.locale
    options[:relative] = false
    url_parts = url.split("#")
    url_parts[0] = extensions[:i18n].localized_path(url_parts[0], locale) ||
                   url_parts[0]
    url = url_parts.join("#")
    url = url_for(url, options)
    # Replace leading locale url segment with domain
    url.sub("/#{locale}/", full_url("/", locale))
  end

  # Link_to with active class if current_page
  def nav_link_to(text, url, options = {})
    is_active = url_for(url.split("#")[0], relative: false) ==
                url_for(current_page.url, relative: false)
    options[:class] ||= ""
    options[:class] << " active" if is_active
    locale_link_to(text, url, options)
  end

  # Country flags
  def country_flags
    flag_titles = { nl: "Nederlands", de: "Deutsch", en: "English" }
    html = ""
    (langs - [I18n.locale]).each do |lang|
      img = image_tag("flags/#{lang}.gif", alt: flag_titles[lang])
      if is_blog_index?
        url = full_url("/blog/", lang)
      elsif jobs_index?
        url = full_url("/jobs/", lang)
      elsif current_page.data.unique_for_locale == true
        url = full_url("", lang)
      else
        locale_root_path = current_page.locale_root_path
        url = locale_root_path ? locale_root_path : "/"
      end
      html << locale_link_to(img, url, title: flag_titles[lang], locale: lang)
    end
    html
  end

  # Href langs
  def href_langs
    html = ""
    langs.each do |lang|
      if is_blog_index?
        url = full_url("/blog/", lang)
      elsif jobs_page?
        url = full_url("/jobs/", lang)
      else
        locale_root_path = current_page.locale_root_path
        url = locale_root_path ? locale_root_path : "/"
        url = full_url locale_url_for(url, locale: lang)
      end
      html << tag(:link, rel: "alternate", href: url, hreflang: "#{lang}-#{lang}") + "\n    "
    end
    html
  end

  def root_url?
    current_page.url == "/"
  end

  def capp_agile_url?
    current_page.url == "/capp-agile-learning/"
  end

  def logo
    if root_url?
      image_link = "-invert"
    elsif capp_agile_url?
      image_link = "-white"
    end
    img = image_tag("logos/defacto#{image_link}.svg", alt: "Defacto", onerror: "this.src='/images/defacto#{image_link}.png'; this.onerror=null;")
    locale_link_to(img, "/")
  end

  # Use frontmatter for white nav trigger on certain pages
  def nav_white?
    current_page.data.nav_white
  end

  # String to markdown
  def markitdown(string)
    # Kramdown::Document.new(string, config[:markdown]).to_html
    # Redcarpet::Markdown.new(Redcarpet::Render::HTML, config[:markdown]).render(string)
    Tilt['markdown'].new { string }.render(scope=self)
  end

  # Get avatar url for team members
  def team_avatar_url(person)
    return person.avatar if person.avatar
    avatar = gravatar_for(person.email)
    return avatar if avatar
    avatar = "/images/team/#{person.firstname.downcase}.jpg"
    return avatar if sitemap.find_resource_by_path(avatar)
    false
  end

  # Email to gravatar
  def gravatar_for(email)
    return false unless email
    hash = Digest::MD5.hexdigest(email.chomp.downcase)
    url = "http://www.gravatar.com/avatar/#{hash}.png?d=404"
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    response.code.to_i == 404 ? false : "https://secure.gravatar.com/avatar/#{hash}.png"
  end

  # Is blog?
  def is_blog?(page = current_page)
    page.url.start_with?("/blog/")
  end

  # Is blog index?
  def is_blog_index?(page = current_page)
    (page.url =~ %r{^\/blog\/(\d+\/)?$}).present?
  end

  # Is jobs?
  def jobs_page?(page = current_page)
    page.url.start_with?("/jobs/")
  end

  # Is jobs index?
  def jobs_index?(page = current_page)
    (page.url =~ %r{^\/jobs\/(\d+\/)?$}).present?
  end

  # Get blog author
  def blog_author(article)
    author = article.data.author
    author = author.present? ? author.capitalize : author
    data.team.find{ |person| person[:firstname] == author }
  end

  # Get blog author name
  def blog_author_name(author)
    "#{author.firstname} #{author.prefix} #{author.lastname}"
  end

  # Capitalize tagnames
  def capitalize(tagname)
    tagname = tagname.slice(0, 1).capitalize + tagname.slice(1..-1)
    tagname.gsub(/-[a-z]/, &:upcase)
  end

  # Used to validate data/downloads.yml
  def validate_downloads(hash)
    hash.each do |key, value|
      if value.is_a?(Hash)
        validate_downloads(value)
      elsif value.is_a?(String)
        unless sitemap.find_resource_by_path(value)
          hash[key] = false
          puts "\033[31mWARNING: Download link does not exist '#{value}'\033[0m"
        end
      end
    end
  end
end
