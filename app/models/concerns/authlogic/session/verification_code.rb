module Authlogic
  module Session
    # Handles authenticating via a traditional username and verification_code.
    module VerificationCode
      def self.included(klass)
        klass.class_eval do
          extend Config
          include InstanceMethods
          validate :validate_by_verification_code, :if => :authenticating_with_verification_code?

          class << self
            attr_accessor :configured_verification_code_methods
          end
        end
      end

      # VerificationCode configuration
      module Config
        # Works exactly like login_field, but for the verification_code instead. Returns :verification_code if a login_field exists.
        #
        # * <tt>Default:</tt> :verification_code
        # * <tt>Accepts:</tt> Symbol or String
        def verification_code_field(value = nil)
          rw_config(:verification_code_field, value, login_field && :verification_code)
        end
        alias_method :verification_code_field=, :verification_code_field

        # The name of the method in your model used to verify the verification_code. This should be an instance method. It should also
        # be prepared to accept a raw verification_code and a crytped verification_code.
        #
        # * <tt>Default:</tt> "valid_verification_code?"
        # * <tt>Accepts:</tt> Symbol or String
        def verify_verification_code_method(value = nil)
          rw_config(:verify_verification_code_method, value, "valid_verification_code?")
        end
        alias_method :verify_verification_code_method=, :verify_verification_code_method
      end

      # VerificationCode related instance methods
      module InstanceMethods
        def initialize(*args)
          if !self.class.configured_verification_code_methods
            configure_verification_code_methods
            self.class.configured_verification_code_methods = true
          end
          super
        end

        # Returns the login_field / verification_code_field credentials combination in hash form.
        def credentials
          if authenticating_with_verification_code?
            details = {}
            details[login_field.to_sym] = send(login_field)
            details[verification_code_field.to_sym] = "<protected>"
            details
          else
            super
          end
        end

        # Accepts the login_field / verification_code_field credentials combination in hash form.
        def credentials=(value)
          super
          values = value.is_a?(Array) ? value : [value]
          if values.first.is_a?(Hash)
            values.first.with_indifferent_access.slice(login_field, verification_code_field).each do |field, value|
              next if value.nil?
              send("#{field}=", value)
            end
          end
        end

        def invalid_verification_code?
          invalid_verification_code == true
        end

        private
          def configure_verification_code_methods
            if verification_code_field
              self.class.send(:attr_writer, verification_code_field) if !respond_to?("#{verification_code_field}=")
              self.class.send(:attr_reader, verification_code_field) if !respond_to?(verification_code_field)
            end
          end

          def authenticating_with_password?
            login_field && !send("protected_#{password_field}").nil?
          end

          def authenticating_with_verification_code?
            login_field && !send(verification_code_field).nil?
          end

          def validate_by_verification_code
            self.invalid_verification_code = false

            # check for blank fields
            errors.add(login_field, I18n.t('error_messages.login_blank', :default => "cannot be blank")) if send(login_field).blank?
            errors.add(verification_code_field, I18n.t('error_messages.verification_code_blank', :default => "cannot be blank")) if send(verification_code_field).blank?
            return if errors.count > 0

            # check for unknown login
            self.attempted_record = search_for_record(find_by_login_method, send(login_field))
            if attempted_record.blank?
              generalize_credentials_error_messages? ?
                add_general_credentials_error :
                errors.add(login_field, I18n.t('error_messages.login_not_found', :default => "is not valid"))
              return
            end

            # check for invalid verification_code
            if !attempted_record.send(verify_verification_code_method, send(verification_code_field))
              self.invalid_verification_code = true
              generalize_credentials_error_messages? ?
                add_general_credentials_error :
                errors.add(verification_code_field, I18n.t('error_messages.verification_code_invalid', :default => "is not valid"))
              return
            end
          end

          attr_accessor :invalid_verification_code

          def verification_code_field
            self.class.verification_code_field
          end

          def verify_verification_code_method
            self.class.verify_verification_code_method
          end
      end
    end
  end
end
