class RAMF::Rails::Gateway
  
  def process(request, response)
    @request, @response = request, response
    @request_amf = RAMF::Deserializer::Base.new(request.body).process
    @response_amf = @request_amf.process(@request, @response, @request_amf)
    RAMF::Serializer::Base.new.write(@response_amf, @scope || RAMF::Configuration::DEFAULT_SCOPE)
  end
  
end
