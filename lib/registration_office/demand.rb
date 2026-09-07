# frozen_string_literal: true

require_relative 'demands'

module RegistrationOffice
  # Defines the "receiving end" of a register, i.e. the demanding (consuming) object.
  # This module is not intended to be included directly.
  # Instead, the +.[]+ singleton method should be used,
  # which returns a new module that can be included.
  module Demand
    class << self
      # @param registry_object [Object] The Ruby object (class, module) that defined the register which should be used.
      #
      # @return [Module]
      def [](registry_object)
        safe_constantize(registry_object)

        mod = Module.new
        prepare_mod(mod, registry_object)
        mod
      end

      private

      def safe_constantize(registry_object)
        return registry_object if registry_object.is_a?(Class) || registry_object.is_a?(Module)

        unless registry_object.is_a?(String)
          raise ArgumentError, "`#{registry_object.inspect}` must be a String or a Class or a Module"
        end

        Object.const_get(registry_object)
      rescue NameError
        raise ArgumentError, "`#{registry_object}` is not a known Class or Module"
      end

      # rubocop:disable-next Metrics/MethodLength
      def prepare_mod(mod, registry_object)
        unless registry_object.respond_to?(:registry)
          raise ArgumentError, "`#{registry_object.inspect}` does not respond to #registry"
        end

        # This is evaluated withing the dynamically created, nested module "RegistryDemand"
        mod.module_eval do
          include Demands

          add_demand(:placeholder, registry_object)
          # Eq. to `def self.included(base)`
          define_singleton_method :included do |base|
            # This is evaluated withing the including class/module
            base.module_eval do
              const_set('RegistryDemand', mod)

              define_singleton_method(:demand) { const_get('RegistryDemand').demand(:placeholder) }
              define_method(:demand) { self.class.const_get('RegistryDemand').demand(:placeholder) }
            end
          end
        end
      end
    end
  end
end
