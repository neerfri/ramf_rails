#register the amf mime-type:
Mime::Type.register("application/x-amf", :amf) unless defined?(Mime::AMF)


#RAMF configuration:

#====Active Record Assosications Null Assignment
#this option controls wheter to assign associations coming from AMF when the association is set to null.
#Default is false
#RAMF::Configuration.SET_AR_NIL_ASSOCIATIONS = false