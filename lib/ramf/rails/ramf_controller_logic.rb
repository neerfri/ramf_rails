module RAMF::Rails::RamfControllerLogic

  def self.included(base)
    super
    base.before_filter {|c| c.request.format=:amf if /x-amf/ =~ c.request.env['CONTENT_TYPE']}
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
    @request_amf = RAMF::Deserializer::Base.new(request.body).process
    @response_amf = @request_amf.process(@request, @response, @request_amf)
    RAMF::Serializer::Base.new.write(@response_amf, @scope || RAMF::Configuration::DEFAULT_SCOPE)
  end

end