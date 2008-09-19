#Install script for Rails Plugin Installation.
begin
  require 'fileutils'
  overwrite = true
  
rescue Exception=>e
  puts "Error installing RAMF rails plugin.:"
  puts e.class.name + ":" + e.message
end