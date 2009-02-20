module RAMF::Rails::RamfControllerLogic

  def self.included(base)
    super
    base.before_filter {|c| c.request.format=:amf if /x-amf/ =~ c.request.env['CONTENT_TYPE']}
    base.class_eval do
      def log_processing_with_ramf
        if is_amf_ping_request? || request.content_type && !request.content_type.amf?
          log_processing_without_ramf
        end
      end
      alias_method_chain :log_processing, :ramf

      def perform_action_with_ramf
        total_time = [ Benchmark::measure{ perform_action_without_ramf }.real, 0.0001 ].max

        log_message  = "Completed in #{sprintf("%.0f", total_time * 1000)}ms"

        components = []
        components << "View: %.0f" % (@view_runtime * 1000) if defined?(@view_runtime)
        if Object.const_defined?("ActiveRecord") && ActiveRecord::Base.connected?
          db_runtime = ActiveRecord::Base.connection.reset_runtime
          db_runtime += @db_rt_before_render if @db_rt_before_render
          db_runtime += @db_rt_after_render if @db_rt_after_render
          components << "DB: %.0f" % (db_runtime * 1000)
        end
        if @serialize_time && @deserialize_time
          components << sprintf("RAMF: %.0f/%.0f",@serialize_time * 1000, @deserialize_time* 1000)
        end

        log_message << " (#{components.join(', ')})" unless components.empty?

        log_message << " | #{headers["Status"]}"
        log_message << " [#{complete_request_uri rescue "unknown"}]"

        logger.info log_message
      end
      alias_method_chain :perform_action, :ramf
    end
    
  end

  def gateway
    respond_to do |format|
      format.html
      format.amf do
        send_data(process_ramf_request(request, response), :type=>"application/x-amf")
      end
    end
  end


  private

  def process_ramf_request(request, response)
    @request, @response = request, response
    @serialize_time = Benchmark::realtime { @request_amf = RAMF::Deserializer::Base.new(request.body).process }
    log_processing
    logger.info "Ping request, answewring with acknoladgement" if is_amf_ping_request?
    @response_amf = @request_amf.process(@request, @response, @request_amf)
    ret = nil
    @deserialize_time = Benchmark::realtime {ret = RAMF::Serializer::Base.new.write(@response_amf, @scope || RAMF::Configuration::DEFAULT_SCOPE)}
    ret
  end
  
  def is_amf_ping_request?
    @request_amf.messages.first.value.first.operation == 5 rescue nil
  end
  
end

class LoggerFilter < DelegateClass(::ActiveSupport::BufferedLogger)
  def initialize(logger)
    @logger = logger
    super(@logger)
  end
  
  
  def info(message = nil, progname = nil, &block)
    if message =~ /Completed in \d*ms (\([^\)]*\)|) [|] (\d* \w*|) \[.*\]/ && !($1=~/RAMF/)
      #Supress Complete message, RamfController will show it with RAMF data.
      #@logger.info("**********Supressed:" + message, progname, &block)
    else
      @logger.info(message, progname, &block)
    end
  end
end