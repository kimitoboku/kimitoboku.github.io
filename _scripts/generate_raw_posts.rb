# frozen_string_literal: true

require "fileutils"
require "jekyll"

destination = File.expand_path(ARGV.fetch(0, "_site"))
configuration = Jekyll.configuration("destination" => destination)
site = Jekyll::Site.new(configuration)

site.reset
site.read

site.posts.docs.each do |post|
  relative_path = "#{post.url.delete_prefix("/").delete_suffix("/")}.md"
  destination_path = site.in_dest_dir(relative_path)

  FileUtils.mkdir_p(File.dirname(destination_path))
  File.binwrite(destination_path, File.binread(post.path))
end

puts "Generated #{site.posts.docs.length} raw Markdown files in #{destination}"
