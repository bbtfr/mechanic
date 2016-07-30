module Cacheable
  extend ActiveSupport::Concern

  module ClassMethods
    def define_cached_methods *methods
      options = methods.extract_options!
      methods.each do |method|
        method = method.to_sym
        class_eval do
          if self.kind_of? ApplicationRecord
            define_method :"#{method}_with_cache" do |*args|
              Rails.cache.fetch([self.class.name, self.id, method, *args, options[:version]],
                expires_in: (options[:expires_in] || 1.hour)) do
                  send :"#{method}_without_cache", *args
              end
            end
          elsif self.kind_of? Class
            define_method :"#{method}_with_cache" do |*args|
              Rails.cache.fetch([self.name, method, *args, options[:version]],
                expires_in: (options[:expires_in] || 1.hour)) do
                  send :"#{method}_without_cache", *args
              end
            end
          else
            raise ArgumentError, "Invalid cached method #{method} for #{self}"
          end
          alias_method_chain method, :cache
        end
      end
    end
  end

end
