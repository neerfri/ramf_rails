class RamfController < ActionController::Base
  
  before_filter {|c| c.format=:amf if /x-amf/ =~ c.request.env['CONTENT_TYPE']}
  
  def gateway
    respond_to do |format|
      format.html
      format.amf do
        amf = RAMF::Rails::Gateway.new.process(request,response)
        render :text=>amf.inspect
      end
    end
  end
  
  
end