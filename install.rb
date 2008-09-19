#Install script for Rails Plugin Installation.
begin
  require 'fileutils'
  overwrite = true
  
  puts "Installing RAMF"
  
rescue Exception=>e
  puts "Error installing RAMF rails plugin.:"
  puts e.class.name + ":" + e.message
end