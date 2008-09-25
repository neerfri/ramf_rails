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
      
      flex_members_writer do |obj, key, value|
        if obj.class.column_names.include?(key.to_s)
          #the member is a column in the table
          obj.send("#{key}=", value) unless value.is_a?(Float) && value.nan?
        elsif (reflection = obj.class.reflect_on_association(key))
          unless !RAMF::Configuration.SET_AR_NIL_ASSOCIATIONS && value.nil?
            obj.send("#{key}=", value)
          end
        end
      end
      
    end
  end
  
end
