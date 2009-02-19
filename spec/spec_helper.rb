require 'rubygems'
require 'spec'
require 'ramf'

module SinkMock
  def method_missing(method, *args,&block);end;
end

module ActionController
  class Base
    class<<self
      def method_missing(method, *args,&block);end;
    end
    def method_missing(method, *args,&block);end;
  end
end

module ActiveRecord
  class Base
    def method_missing(method, *args,&block);end;
  end
end



require File.join(File.dirname(__FILE__),'..', 'init.rb')