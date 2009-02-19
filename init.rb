$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

begin
  RAMF
  require 'ramf/rails'
  require 'ramf/action_controller_extensions'
  require 'ramf/active_record_extensions'
  require 'ramf/configuration'
  require 'ramf/rails/action_processor'
  require 'ramf/rails/ramf_controller_logic'
  ActionController::Base.send(:include, RAMF::ActionControllerExtensions)
  ActiveRecord::Base.send(:include, RAMF::ActiveRecordExtensions) if defined?(ActiveRecord::Base)
#rescue NameError => e
#  warn("WARNING: RAMF gem not found, Stopped loading ramf_rails !")
end

