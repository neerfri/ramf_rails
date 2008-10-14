module RAMF::ActionControllerExtensions
  
  def self.included(klass)
    klass.class_eval do
      attr_reader :render_amf, :rescued_exception, :amf_scope
      attr_accessor :request_amf
      attr_accessor :ramf_params
      attr_accessor :credentials
      alias_method :rubyamf_params, :ramf_params #TODO: remove if not needed
    
      def render_with_amf(options = nil, extra_options = {}, &block)
        if options && options.is_a?(Hash) && options.keys.include?(:amf)
          @render_amf = options[:amf]
          @amf_scope = options[:scope]
          @performed_render = true
        else
          render_without_amf(options, extra_options, &block)
        end
      end
      alias_method_chain :render, :amf
      
      def is_amf
        request_amf ? true : false
      end
      
      def exception_happend?
        !rescued_exception.nil?
      end
      
    end
  end
end