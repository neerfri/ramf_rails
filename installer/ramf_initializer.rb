#register the amf mime-type:
Mime::Type.register("application/x-amf", :amf) unless defined?(Mime::AMF)