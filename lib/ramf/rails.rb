module RAMF::Rails
  class CouldNotLoadService < StandardError; end;
  class ServiceMethodIsPublic <StandardError; end;
  class MethodNotDefinedInService <StandardError; end;
end