#Install script for Rails Plugin Installation.
require File.join(File.dirname(__FILE__),'installer/install_helper')
include RAMF::InstallHelper

begin
  require 'fileutils'
  
  unless defined?(RAILS_ROOT)
    RAILS_ROOT = "./"
  end
  
  puts "Installing RAMF..."
  
  
  if !File.exist?(file = file_in_app('config/initializers/ramf_initializer.rb'))
    FileUtils.copy_file(file_in_installer('ramf_initializer.rb'), file, false)
  end
  
rescue Exception=>e
  puts "Error installing RAMF rails plugin.:"
  puts e.class.name + ":" + e.message
end