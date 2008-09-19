$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'ramf'
ActionController::Base.send(:include, RAMF::ActionControllerExtensions)
#require 'lib/action_controller_extensions'