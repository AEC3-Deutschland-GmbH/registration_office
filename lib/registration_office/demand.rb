# frozen_string_literal: true

module RegistrationOffice
  module Demand
    class << self
      def [](registry_object)
        safe_constantize(registry_object)

        mod = Module.new
        prepare_mod(mod, registry_object)
        mod
      end

      private

      def safe_constantize(registry_object)
        return registry_object if registry_object.is_a?(Class) || registry_object.is_a?(Module)

        raise ArgumentError, "`#{registry_object.inspect}` must be a String or a Class or a Module" unless registry_object.is_a?(String)

        Object.const_get(registry_object)
      rescue NameError
        raise ArgumentError, "`#{registry_object}` is not a known Class or Module"
      end

      def prepare_mod(mod, registry_object)
        raise ArgumentError, "`#{registry_object.inspect}` does not respond to #registry" unless registry_object.respond_to?(:registry)

        # This is evaluated withing the dynamically created, nested module "RegistryDemand"
        mod.module_eval do
          # Eq. to `def self.included(base)`
          define_singleton_method :included do |base|
            # This is evaluated withing the including class/module
            base.module_eval do
              const_set('RegistryDemand', mod)

              define_singleton_method(:demand) { const_get('RegistryDemand') }
              define_method(:demand) { self.class.const_get('RegistryDemand') }
            end
          end

          # "Delegated" methods
          define_singleton_method(:key!) { |key| registry_object.registry.key!(key) }
          define_singleton_method(:use!) { |key| registry_object.registry.use!(key) }
          define_singleton_method(:keys) { registry_object.registry.keys }
        end
      end
    end
  end
end
