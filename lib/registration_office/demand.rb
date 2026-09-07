# frozen_string_literal: true

require_relative 'demands'

module RegistrationOffice
  # Defines the "receiving end" of a register, i.e. the demanding (consuming) object.
  # This module is not intended to be included directly.
  # Instead, the +.[]+ singleton method should be used,
  # which returns a new module that can be included.
  module Demand
    class << self
      def included(base)
        mod = prepare_mod
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

      def prepare_mod
        Module.new do
          class << self
            def demands
              @demands ||= Registers.new
            end

            def demand(register_name)
              demands.fetch(register_name)
            end

            def add_demand(register_name, register)
              demands.register_a_register(register_name, register)
            end
          end
        end
      end
    end
  end
end
