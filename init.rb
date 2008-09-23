$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'ramf'
ActionController::Base.send(:include, RAMF::ActionControllerExtensions)
ActiveRecord::Base.send(:include, RAMF::ActiveRecordExtensions) if defined?(ActiveRecord::Base)
