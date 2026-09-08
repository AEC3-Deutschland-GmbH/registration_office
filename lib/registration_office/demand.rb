# frozen_string_literal: true

module RegistrationOffice
  # Defines the "receiving end" of a register, i.e. the demanding (consuming) object.
  # This module is not intended to be included directly.
  # Instead, the +.[]+ singleton method should be used,
  # which returns a new module that can be included.
  module Demand
    class DuplicateDemandNameError < StandardError; end

    class << self
      # rubocop:disable-next Metrics/MethodLength
      def included(base)
        return if registry_demand_already_defined?(base)

        mod = prepare_mod(Module.new)
        base.module_eval do
          const_set('RegistryDemand', mod)

          define_singleton_method(:add_demand) do |register_name, register_object|
            const_get('RegistryDemand').add_demand(
              register_name,
              register_object.registry(register_name)
            )
          end

          define_singleton_method(:demand) { |register_name| const_get('RegistryDemand').demand(register_name) }
          define_method(:demand) { |register_name| self.class.const_get('RegistryDemand').demand(register_name) }
        end
      end

      private

      def registry_demand_already_defined?(base)
        defined?(base::RegistryDemand)
      end

      # rubocop:disable-next Metrics/MethodLength
      def prepare_mod(mod)
        mod.module_eval do
          class << self
            def demands
              @demands ||= Registers.new
            end

            def demand(register_name)
              demands.fetch(register_name)
            end

            def add_demand(register_name, register)
              demands.register_a_register(register_name, register)
            rescue Registers::DuplicateRegisterNameError
              raise(
                DuplicateDemandNameError,
                "A register with name `#{register_name}` is already demanded"
              )
            end
          end
        end

        mod
      end
    end
  end
end
