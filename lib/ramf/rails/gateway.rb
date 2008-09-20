class RAMF::Rails::Gateway
  
  def process(request, response)
    @requset, @response = request, response
    @request_amf = RAMF::Deserializer::Base.new(request.body).process
    @response_amf = RAMF::AMFObject.new
    @request_amf.messages.each do |amf_message|
      response = invoke_action(amf_message)
      response_message = RAMF::AMFMessage.new :target_uri=>amf_message.response_uri + '/onResult',
                                        :response_uri=>"",
                                        :value=>response
      @response_amf.add_message(response_message)
    end
    RAMF::Serializer::Base.new(3).write(@response_amf)
  end
  
  def invoke_action(amf_message)
    service = instantize_service(amf_message.target_uri)
    action = action_name(amf_message.target_uri)
    if service.private_methods.include?(action)
      raise(RAMF::Rails::ServiceMethodIsPublic, "The method {#{action}} in class {#{service.class}} is declared as private, it must be defined as public to access it.")
    elsif !service.public_methods.include?(action)
      raise(RAMF::Rails::MethodNotDefinedInService, "The method {#{action}} in class {#{service.class}} is not declared.")
    end
    req = @requset.clone
    res = @response.clone
    controller = service_class_name(amf_message.target_uri).gsub("Controller","").gsub("::","/").underscore
    req.parameters['controller'] = req.request_parameters['controller'] = req.path_parameters['controller'] = controller
    req.parameters['action']     = req.request_parameters['action']     = req.path_parameters['action']     = action
    req.env['PATH_INFO']         = req.env['REQUEST_PATH']              = req.env['REQUEST_URI']            = "#{controller}/#{action}"
    req.env['HTTP_ACCEPT'] = ['application/x-amf' ,req.env['HTTP_ACCEPT'].to_s].join(",")
    
    service.request_amf = @request_amf
    service.ramf_params = Array(amf_message.value)
    service.process(req, res)
    service.render_amf
  end
  
  def instantize_service(target_uri)
    begin
      service_class_name(target_uri).constantize.new
    rescue NameError => e
      raise(RAMF::Rails::CouldNotLoadService, "Unable to find class file for #{service_class_name(target_uri)}")
    end
  end
  
  def service_class_name(target_uri)
    uris = target_uri[0,target_uri.rindex(".")].split(".").map(&:camelize)
    uris.push("#{uris.pop}Controller") unless uris.last.ends_with?("Controller")
    uris.join("::")
  end
  
  def action_name(target_uri)
    target_uri[target_uri.rindex(".")+1..-1].underscore
  end
end