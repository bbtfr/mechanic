module Authlogic
  module Session
    module RWField
      def self.included(klass)
        klass.class_eval do
          extend ClassMethods
          include InstanceMethods
        end
      end

      # RWField configuration
      module ClassMethods
        attr_accessor :rw_fields
        def rw_field field
          (self.rw_fields ||= []) << field
          attr_accessor field
        end
      end

      # RWField related instance methods
      module InstanceMethods
        # Accepts the rw_fields credentials combination in hash form.
        def credentials=(value)
          super
          values = value.is_a?(Array) ? value : [value]
          if values.first.is_a?(Hash)
            values.first.with_indifferent_access.slice(*self.class.rw_fields).each do |field, value|
              next if value.nil?
              send("#{field}=", value)
            end
          end
        end
      end
    end
  end
end
