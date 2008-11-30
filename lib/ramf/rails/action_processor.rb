class RAMF::Rails::ActionProcessor
  RAMF::OperationProcessorsManager.add_operation_processor(self)
  
  class << self
    
    def will_process?(operation, *args)
      #handle any regular remoting_message and any non messaging amf requests
      operation.remoting_message? || !operation.messaging?
    end
    
    def process(operation, request, response, incoming_amf_object)
      controller = operation.service.gsub(/Controller$/,"")
      controller_in_path = controller.gsub("::","/").underscore
      path = "/#{controller_in_path}/#{operation.method}"
      req = request.clone
      req.unmemoize_all if req.respond_to?(:unmemoize_all) #this will handle Rails 2.2.2 memoization
      res = response.clone
      req.env["PATH_INFO"] = req.env["REQUEST_PATH"] = req.env["REQUEST_URI"] = path
      req.env['HTTP_ACCEPT'] = 'application/x-amf'
      begin
        service = "#{controller}Controller".constantize.new
        req.path_parameters = {:controller=>controller_in_path, :action=>operation.method}
      rescue ActionController::RoutingError=>e
        raise(RAMF::Rails::CouldNotLoadService, "Unable to find class file for #{operation.service}")
      end
      if service.private_methods.include?(operation.method)
        raise(RAMF::Rails::ServiceMethodIsPublic, "The method {#{operation.method}} in class {#{service.class}} is declared as private, it must be defined as public to access it.")
      elsif !service.public_methods(true).include?(operation.method)
        raise(RAMF::Rails::MethodNotDefinedInService, "The method {#{operation.method}} in class {#{service.class}} is not declared.")
      end
      service.request_amf = incoming_amf_object
      service.credentials = operation.credentials
      
      args = Array(operation.args)
      service.ramf_params = args
      args.first.to_params.each {|k,v| req.parameters[k] = v} if args.size==1 && args.first.respond_to?(:to_params)
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
