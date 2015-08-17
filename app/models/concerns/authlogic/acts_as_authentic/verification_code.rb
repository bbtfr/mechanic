module Authlogic
  module ActsAsAuthentic
    # This module is responsible for maintaining the verification code. For more information the single access token and how to use it,
    # see the Authlogic::Session::Params module.
    module VerificationCode
      def self.included(klass)
        klass.class_eval do
          extend Config
          add_acts_as_authentic_module(Methods)
        end
      end

      # All configuration for the verification code aspect of acts_as_authentic.
      module Config
        # The single access token is used for authentication via URLs, such as a private feed. That being said,
        # if the user changes their password, that token probably shouldn't change. If it did, the user would have
        # to update all of their URLs. So be default this is option is disabled, if you need it, feel free to turn
        # it on.
        #
        # * <tt>Default:</tt> false
        # * <tt>Accepts:</tt> Boolean
        def change_verification_code_with_password(value = nil)
          rw_config(:change_verification_code_with_password, value, false)
        end
        alias_method :change_verification_code_with_password=, :change_verification_code_with_password
      end

      # All method, for the verification code aspect of acts_as_authentic.
      module Methods
        def self.included(klass)
          return if !klass.column_names.include?("verification_code")

          klass.class_eval do
            include InstanceMethods
            before_validation :reset_verification_code, :if => :reset_verification_code?
            after_password_set(:reset_verification_code, :if => :change_verification_code_with_password?) if respond_to?(:after_password_set)
          end
        end

        module InstanceMethods
          # Resets the verification_code to a random friendly token.
          def reset_verification_code
            self.verification_code = Authlogic::Random.friendly_token
          end

          # same as reset_verification_code, but then saves the record.
          def reset_verification_code!
            reset_verification_code
            save_without_session_maintenance
          end

          # validate verification code
          def valid_verification_code? verification_code
            self.verification_code && self.verification_code == verification_code
          end

          protected
            def reset_verification_code?
              verification_code.blank?
            end

            def change_verification_code_with_password?
              self.class.change_verification_code_with_password == true
            end
        end
      end
    end
  end
end
