require 'nokogiri'
require 'deep_merge'
require 'require_all'
require 'yaml'
require 'date'
require 'net/http'
require 'fileutils'
require_all 'lib'


time_now = Time.now


# Resolve working directory when called from symlink
symlinked = `readlink -f "#{$0}"`
Dir.chdir(File.dirname(symlinked))


CONFIG = YamlHelper.load_config
recents = YamlHelper.load_recents


puts "\n### Wallpaper downloader - Bing\n\n"


# Check if enough time has passed since the last change
if recents[:last_time].class == Integer &&
    time_now.to_date < Time.at(recents[:last_time]).to_date + CONFIG[:delay_in_days]
  puts "Not enough days have passed since the last run."
  exit true
end



# Get data about today's wallpaper

bing_response = NetHelper.get_with_redirect('https://binged.it/2ZButYc')

xml_doc = Nokogiri::XML(bing_response.body)

pic_url = xml_doc.at_xpath('/images/image/url').inner_html.gsub(/^(.+?)&.*$/, '\1')

pic_name, pic_ext = pic_url.scan(/^.*=([^&?\/]*?)\.(\w+?)$/)[0]

# Check if wallpaper already exists
Dir.children(CONFIG[:wallpaper_dir]).each do |existing_pic|
  existing_name = existing_pic.scan(/bing_\d{8}-\d{6}_(.*)/)[0][0]

  if existing_name == "#{pic_name}.#{pic_ext}"
    puts "This wallpaper was already downloaded."
    exit true
  end
end

recents[:history] << {
  :start_date => xml_doc.at_xpath('/images/image/startdate').inner_html,
  :end_date => xml_doc.at_xpath('/images/image/enddate').inner_html,
  :file_name => "#{pic_name}.#{pic_ext}",
  :copyright => xml_doc.at_xpath('/images/image/copyright').inner_text
}



# Download the new wallpaper

FileUtils.mkdir_p(CONFIG[:wallpaper_dir]) unless Dir.exist?(CONFIG[:wallpaper_dir])

pic_file_path = "#{CONFIG[:wallpaper_dir]}/bing_#{time_now.strftime('%Y%m%d-%H%M%S')}_#{pic_name}.#{pic_ext}"

NetHelper.download_file("http://www.bing.com/#{pic_url}", pic_file_path)


# Set the background!
system("gsettings set org.gnome.desktop.background picture-uri file:///#{pic_file_path}")


puts 'New wallpaper downloaded and set.'

recents[:last_time] = time_now.to_i
File.write('recent.yml', recents.to_yaml)
