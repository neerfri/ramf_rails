$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

begin
  RAMF
  require 'ramf'
  require 'ramf/rails/action_processor'
  ActionController::Base.send(:include, RAMF::ActionControllerExtensions)
  ActiveRecord::Base.send(:include, RAMF::ActiveRecordExtensions) if defined?(ActiveRecord::Base)
rescue NameError => e
  warn("WARNING: RAMF gem not found, Stopped loading ramf_rails !")
end

