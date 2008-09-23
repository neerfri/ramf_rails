module RAMF::ActiveRecordExtensions
  
  def self.included(klass)
    klass.class_eval do
      
      flex_remoting_transient :attributes, :attributes_cache, :changed_attributes, :new_record
      
      def self.flex_members
        self.name=="ActiveRecord::Base" ? [] : column_names.map(&:to_sym)
      end
      
    end
  end
  
end
