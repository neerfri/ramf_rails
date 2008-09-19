#Install script for Rails Plugin Installation.
begin
  require 'fileutils'
  overwrite = true
  
  puts "Installing RAMF..."
  
  puts "RAILS_ROOT:#{RAILS_ROOT}"
  
#  if !File.exist?('./config/initializers/ramf.rb')
#    FileUtils.copy_file("./vendor/plugins/rubyamf/rails_installer_files/rubyamf_config.rb", "./config/rubyamf_config.rb", false)
#  end
  
rescue Exception=>e
  puts "Error installing RAMF rails plugin.:"
  puts e.class.name + ":" + e.message
end