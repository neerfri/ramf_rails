class RAMF::Rails::ActionProcessor
  RAMF::OperationProcessorsManager.add_operation_processor(self)
  
  class << self
    
    def will_process?(operation, *args)
      #handle any regular remoting_message and any non messaging amf requests
      operation.remoting_message? || !operation.messaging?
    end
    
    def process(operation, request, response, incoming_amf_object)
      path = "/#{operation.service.gsub("Controller","").gsub("::","/").underscore}/#{operation.method}"
      req = request.clone
      res = response.clone
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
      service.request_amf = incoming_amf_object
      service.ramf_params = Array(operations.args)
      service.credentials = operation.credentials
      service.process(req, res)
      #TODO: need to implement scope saving
  #    @scope = service.amf_scope || RAMF::Configuration::DEFAULT_SCOPE
      if service.exception_happend?
        raise service.rescued_exception
      else
        service.render_amf
      end
    end
  end
  
end
