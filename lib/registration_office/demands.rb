# frozen_string_literal: true

require_relative 'registers'

module RegistrationOffice
  # module Demanding
  #   include RegistrationOffice[:demand]
  #   add_demand(<name>, <DemandingObject>)
  #   add_demand(:placeholder, MyClass)
  #
  #   def call
  #     demand(:placeholder).key!(:some_key)
  #   end
  # end
  module Demands
    class << self
      def included(base)
        mod = prepare_mod
        base.module_eval do
          const_set('RegistryDemand', mod)

          define_singleton_method(:add_demand) do |register_name, register_object|
            const_get('RegistryDemand').add_demand(
              register_name,
              register_object.registry # (register_name)
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
