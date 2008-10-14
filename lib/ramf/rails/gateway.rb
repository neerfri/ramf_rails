class RAMF::Rails::Gateway
  
  def process(request, response)
    @request, @response = request, response
    @request_amf = RAMF::Deserializer::Base.new(request.body).process
    @response_amf = @request_amf.process
    debugger
    RAMF::Serializer::Base.new.write(@response_amf, @scope || RAMF::Configuration::DEFAULT_SCOPE)
  end
  
  def invoke_action(amf_message)
    action = action_name(amf_message.target_uri)
    path = "/#{service_class_name(amf_message.target_uri).gsub("Controller","").gsub("::","/").underscore}/#{action}"

    req = ActionController::CgiRequest.new(@request.cgi, @request.session_options)
    res = ActionController::CgiResponse.new(@response.instance_variable_get("@cgi"))
    req.instance_variable_set("@env", req.env.clone)
    req.env["PATH_INFO"] = req.env["REQUEST_PATH"] = req.env["REQUEST_URI"] = path
    req.env['HTTP_ACCEPT'] = 'application/x-amf'
   begin
      service = ActionController::Routing::Routes.recognize(req).new
   rescue ActionController::RoutingError=>e
      raise(RAMF::Rails::CouldNotLoadService, "Unable to find class file for #{service_class_name(amf_message.target_uri)}")
   end
   if service.private_methods.include?(action)
     raise(RAMF::Rails::ServiceMethodIsPublic, "The method {#{action}} in class {#{service.class}} is declared as private, it must be defined as public to access it.")
   elsif !service.public_methods.include?(action)
     raise(RAMF::Rails::MethodNotDefinedInService, "The method {#{action}} in class {#{service.class}} is not declared.")
   end
   
    service.request_amf = @request_amf
    service.ramf_params = Array(amf_message.value)
    service.process(req, res)
    @request.session.data.merge!(service.request.session.data)
    @scope = service.amf_scope || RAMF::Configuration::DEFAULT_SCOPE
    RAILS_DEFAULT_LOGGER.info "Serializing response in scope:#{@scope}"
    if service.exception_happend?
      RAILS_DEFAULT_LOGGER.info "Exception: #{service.rescued_exception.class}: #{service.rescued_exception.message}"
      RAILS_DEFAULT_LOGGER.info service.rescued_exception.backtrace.join("\n")
      
      RAMF::AMFMessage.new :target_uri=>amf_message.response_uri + "/onStatus",
                           :response_uri=>"",
                           :value=>service.rescued_exception
    else
      RAMF::AMFMessage.new :target_uri=>amf_message.response_uri + "/onResult",
                           :response_uri=>"",
                           :value=>service.render_amf
    end
  end
end

class RAMF::Rails::ActionProcessor
  RAMF::OperationProcessorsManger.add_operation_processor(RAMF::Rails::ActionProcessor)
  def self.will_process?(operation)
    #handle any regular remoting_message and any non messaging amf requests
    operation.remoting_message? || !operation.messaging?
  end
  
  def self.process(operation)
    path = "/#{operation.service.gsub("Controller","").gsub("::","/").underscore}/#{operation.method}"
    req = @request.clone
    res = @response.clone
    req.env["PATH_INFO"] = req.env["REQUEST_PATH"] = req.env["REQUEST_URI"] = path
    req.env['HTTP_ACCEPT'] = 'application/x-amf'
    begin
      service = ActionController::Routing::Routes.recognize(req).new
    rescue ActionController::RoutingError=>e
      raise(RAMF::Rails::CouldNotLoadService, "Unable to find class file for #{operation.service}")
    end
    if service.private_methods.include?(action)
      raise(RAMF::Rails::ServiceMethodIsPublic, "The method {#{action}} in class {#{service.class}} is declared as private, it must be defined as public to access it.")
    elsif !service.public_methods(true).include?(action)
      raise(RAMF::Rails::MethodNotDefinedInService, "The method {#{action}} in class {#{service.class}} is not declared.")
    end
    service.request_amf = @request_amf
    service.ramf_params = Array(operations.args)
    service.credentials = operation.credentials
    service.process(req, res)
    @scope = service.amf_scope || RAMF::Configuration::DEFAULT_SCOPE
    if service.exception_happend?
      raise service.rescued_exception
    else
      service.render_amf
    end
  end
end

class RAMF::Rails::LoginProcessor
  RAMF::OperationProcessorsManger.add_operation_processor(RAMF::Rails::LoginProcessor)
  def self.will_process?(operation)
    operation.messaging? && operation.login?
  end
  
  def self.process(operation)
    "Logging in #{operation.credentials.inspect}"
  end
end
