module RAMF::ActiveRecordExtensions
  
  def self.included(klass)
    klass.class_eval do
      
      flex_remoting_transient :attributes, :attributes_cache, :changed_attributes, :new_record
      
      def self.flex_members
        self.name=="ActiveRecord::Base" ? [] : column_names.map(&:to_sym)
      end
      
      flex_members_reader do |instance, member|
        instance.class.column_names.include?(member.to_s) ? instance[member] : instance.send(member)
      end
      
    end
  end
  
end
