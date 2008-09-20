#Install script for Rails Plugin Installation.
require File.join(File.dirname(__FILE__),'installer/install_helper')
include RAMF::InstallHelper

begin
  unless defined?(RAILS_ROOT)
    RAILS_ROOT = "./"
  end
  
  puts "Installing RAMF..."
  create_file_unless_exists!('config/initializers/ramf_initializer.rb')
  create_file_unless_exists!('app/controllers/ramf_controller.rb')
  create_file_unless_exists!('app/views/ramf/gateway.html.erb')
  
  
rescue Exception=>e
  puts "Error installing RAMF rails plugin.:"
  puts e.class.name + ":" + e.message
end