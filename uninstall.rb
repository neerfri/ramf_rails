require File.join(File.dirname(__FILE__),'installer/install_helper')
include RAMF::InstallHelper

begin
  unless defined?(RAILS_ROOT)
    RAILS_ROOT = "./"
  end
  
  puts "Removing RAMF plugin..."
  remove_file!('config/initializers/ramf_initializer.rb', false)
  remove_file!('app/controllers/ramf_controller.rb', false)
  remove_file!('app/views/ramf/gateway.html.erb')
  
  
rescue Exception=>e
  puts "Error installing RAMF rails plugin.:"
  puts e.class.name + ":" + e.message
end
