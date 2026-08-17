# frozen_string_literal: true

require "cgi"
require "fileutils"
require "jekyll"
require "open3"
require "optparse"
require "yaml"

WIDTH = 1200
HEIGHT = 630
MAX_TITLE_LINES = 4
FONT_SIZES = [70, 64, 58, 52, 46].freeze
FONT_FAMILY = "Noto Sans CJK JP, Noto Sans JP, sans-serif"

options = {}
OptionParser.new do |parser|
  parser.banner = "Usage: generate_ogp_images.rb [--config PATH] [--output DIRECTORY]"
  parser.on("--config PATH", "Write generated Jekyll defaults") { |path| options[:config] = path }
  parser.on("--output DIRECTORY", "Write PNG files below this directory") { |path| options[:output] = path }
end.parse!

abort "Specify --config, --output, or both" if options.empty?

def character_width(character)
  case character
  when /\s/
    0.35
  when /[\x00-\x7f]/
    0.68
  else
    1.0
  end
end

def split_token(token, max_width)
  parts = [String.new]
  widths = [0.0]

  token.scan(/\X/).each do |character|
    width = character_width(character)
    if widths.last + width > max_width && !parts.last.empty?
      parts << String.new
      widths << 0.0
    end

    parts[-1] << character
    widths[-1] += width
  end

  parts.zip(widths)
end

def wrap_title(title, font_size)
  max_width = 940.0 / font_size
  lines = []
  current_line = String.new
  current_width = 0.0
  space_width = character_width(" ")

  title.strip.split(/\s+/).each do |token|
    token_parts = split_token(token, max_width)
    token_parts.each_with_index do |(part, width), index|
      required_width = current_line.empty? ? width : space_width + width
      if current_width + required_width > max_width && !current_line.empty?
        lines << current_line
        current_line = String.new
        current_width = 0.0
      end

      unless current_line.empty?
        current_line << " "
        current_width += space_width
      end

      current_line << part
      current_width += width

      if index < token_parts.length - 1
        lines << current_line
        current_line = String.new
        current_width = 0.0
      end
    end
  end

  lines << current_line unless current_line.empty?
  lines
end

def title_layout(title)
  FONT_SIZES.each do |font_size|
    lines = wrap_title(title, font_size)
    line_height = font_size * 1.28
    estimated_height = ((lines.length - 1) * line_height) + (font_size * 1.1)
    return [font_size, lines] if lines.length <= MAX_TITLE_LINES && estimated_height <= 240
  end

  font_size = FONT_SIZES.last
  lines = wrap_title(title, font_size)
  visible_lines = lines.first(MAX_TITLE_LINES)
  visible_lines[-1] = "#{visible_lines[-1].sub(/.{0,2}\z/, "")}…"
  [font_size, visible_lines]
end

def accent_color(layout)
  {
    "paper" => "#0f766e",
    "scrap" => "#b45309",
  }.fetch(layout, "#4f46e5")
end

def svg_for(post, site)
  title = post.data.fetch("title", "Untitled").to_s
  layout = post.data.fetch("layout", "post").to_s
  font_size, lines = title_layout(title)
  line_height = (font_size * 1.28).round
  first_line_y = 314 - ((lines.length - 1) * line_height / 2.0)
  accent = accent_color(layout)
  escaped_site_title = CGI.escapeHTML(site.config.fetch("title", "").to_s)
  escaped_label = CGI.escapeHTML(layout.upcase)

  title_elements = lines.each_with_index.map do |line, index|
    y = first_line_y + (index * line_height)
    <<~SVG.chomp
      <text x="100" y="#{y.round}" fill="#0f172a" font-family="#{FONT_FAMILY}" font-size="#{font_size}" font-weight="700">#{CGI.escapeHTML(line)}</text>
    SVG
  end.join("\n")

  <<~SVG
    <svg xmlns="http://www.w3.org/2000/svg" width="#{WIDTH}" height="#{HEIGHT}" viewBox="0 0 #{WIDTH} #{HEIGHT}">
      <defs>
        <linearGradient id="background" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0" stop-color="#eef2ff" />
          <stop offset="0.52" stop-color="#f8fafc" />
          <stop offset="1" stop-color="#ecfeff" />
        </linearGradient>
        <filter id="shadow" x="-20%" y="-20%" width="140%" height="140%">
          <feDropShadow dx="0" dy="12" stdDeviation="18" flood-color="#0f172a" flood-opacity="0.12" />
        </filter>
      </defs>

      <rect width="#{WIDTH}" height="#{HEIGHT}" fill="url(#background)" />
      <circle cx="1110" cy="56" r="190" fill="#{accent}" opacity="0.10" />
      <circle cx="78" cy="590" r="145" fill="#{accent}" opacity="0.08" />
      <path d="M840 0 L1200 0 L1200 240 Z" fill="#{accent}" opacity="0.06" />

      <rect x="48" y="48" width="1104" height="534" rx="36" fill="#ffffff" fill-opacity="0.94" filter="url(#shadow)" />
      <rect x="82" y="86" width="12" height="72" rx="6" fill="#{accent}" />
      <text x="116" y="126" fill="#{accent}" font-family="#{FONT_FAMILY}" font-size="27" font-weight="700" letter-spacing="3">#{escaped_label}</text>

      #{title_elements}

      <line x1="100" y1="492" x2="1100" y2="492" stroke="#e2e8f0" stroke-width="2" />
      <text x="100" y="538" fill="#475569" font-family="#{FONT_FAMILY}" font-size="24" font-weight="500">#{escaped_site_title}</text>
      <text x="1100" y="538" fill="#64748b" font-family="#{FONT_FAMILY}" font-size="23" text-anchor="end">#{post.date.strftime("%Y.%m.%d")}</text>
    </svg>
  SVG
end

configuration = Jekyll.configuration({})
site = Jekyll::Site.new(configuration)
site.reset
site.read

posts = site.posts.docs.reject { |post| post.data["image"] }

if options[:config]
  defaults = posts.map do |post|
    image_path = "/image/ogp#{post.url.delete_suffix("/")}.png"
    {
      "scope" => { "path" => post.relative_path, "type" => "posts" },
      "values" => {
        "image" => {
          "path" => image_path,
          "width" => WIDTH,
          "height" => HEIGHT,
          "alt" => "#{post.data.fetch("title", "Untitled")}のOGP画像",
        },
      },
    }
  end

  config_path = File.expand_path(options[:config])
  FileUtils.mkdir_p(File.dirname(config_path))
  File.write(config_path, { "keep_files" => ["image/ogp"], "defaults" => defaults }.to_yaml)
  puts "Generated OGP configuration for #{defaults.length} posts in #{config_path}"
end

if options[:output]
  renderer = ENV.fetch("RSVG_CONVERT", "rsvg-convert")
  output_root = File.expand_path(options[:output])

  posts.each do |post|
    relative_path = "image/ogp#{post.url.delete_suffix("/")}.png"
    output_path = Jekyll.sanitized_path(output_root, relative_path)
    FileUtils.mkdir_p(File.dirname(output_path))

    _stdout, stderr, status = Open3.capture3(
      renderer,
      "--format", "png",
      "--width", WIDTH.to_s,
      "--height", HEIGHT.to_s,
      "--output", output_path,
      stdin_data: svg_for(post, site)
    )
    abort "Failed to render #{post.relative_path}: #{stderr}" unless status.success?
  end

  puts "Generated #{posts.length} OGP images in #{output_root}"
end
