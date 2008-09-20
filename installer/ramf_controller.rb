class RamfController < ActionController::Base
  
  def gateway
    respond_to do |format|
      format.html {render :layout=>false}
      format.amf { }
    end
  end
  
#  def rescue_action(e)
#    raise e
#    #TODO: handle thrown exceptions...
#  end
end