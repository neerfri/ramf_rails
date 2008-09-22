class RamfController < ActionController::Base
  
  before_filter {|c| c.format=:amf if /x-amf/ =~ c.request.env['CONTENT_TYPE']}
  
  def gateway
    respond_to do |format|
      format.html
      format.amf do
        send_data(RAMF::Rails::Gateway.new.process(request,response), :type=>"application/x-amf")
      end
    end
  end
  
  
end