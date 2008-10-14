class RAMF::Rails::Gateway
  
  def process_amf(request, response)
    @request, @response = request, response
    @request_amf = RAMF::Deserializer::Base.new(request.body).process
    @response_amf = @request_amf.process(self)
    debugger
    RAMF::Serializer::Base.new.write(@response_amf, @scope || RAMF::Configuration::DEFAULT_SCOPE)
  end
  
  def process(operation)
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
    if service.private_methods.include?(operation.method)
      raise(RAMF::Rails::ServiceMethodIsPublic, "The method {#{operation.method}} in class {#{service.class}} is declared as private, it must be defined as public to access it.")
    elsif !service.public_methods(true).include?(operation.method)
      raise(RAMF::Rails::MethodNotDefinedInService, "The method {#{operation.method}} in class {#{service.class}} is not declared.")
    end
    service.request_amf = @request_amf
    service.ramf_params = Array(operation.args)
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

class RAMF::Rails::ActionProcessor
  
  def self.will_process?(operation)
    #handle any regular remoting_message and any non messaging amf requests
    operation.remoting_message? || !operation.messaging?
  end
  
  def self.process(operation)
    path = "/#{operation.service.gsub("Controller","").gsub("::","/").underscore}/#{operation.method}"
    debugger
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
#  RAMF::OperationProcessorsManger.add_operation_processor(RAMF::Rails::LoginProcessor)
  def self.will_process?(operation)
    operation.messaging? && operation.login?
  end
  
  def self.process(operation)
    "Logging in #{operation.credentials.inspect}"
  end
end
