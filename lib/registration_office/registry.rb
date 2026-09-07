# frozen_string_literal: true

require_relative 'register'
require_relative 'registers'

module RegistrationOffice
  # Provides the methods +register+ and +registry+ when included.
  module Registry
    # rubocop:disable-next Metrics/AbcSize, Metrics/MethodLength, Metrics/BlockLength
    def self.included(base)
      # This is evaluated withing the including class/module
      base.module_eval do
        mod = const_set('RegistryStore', Module.new)

        # This is evaluated withing the dynamically created, nested module "RegistryStore"
        mod.module_eval do
          define_singleton_method(:registering_object) { base }

          class << self
            def registers
              @registers ||= Registers.new
            end

            def registry(name)
              registers.fetch(name)
            end

            def all
              registry.registry
            end

            def use!(key)
              registry.use!(key)
            end

            def key!(key)
              registry.key!(key)
            end

            def key?(key)
              registry.key?(key)
            end

            private

            def register(register_name, keys:)
              register = Register.new(registering_object).tap { it.register_keys(register_name, keys:) }
              registers.register_a_register(register_name, register)
              registering_object.add_demand(register_name, registering_object)
            end
          end
        end

        # This is evaluated on "self" for the including class/module
        class << self
          def registry(name)
            const_get('RegistryStore').registry(name)
          end

          private

          def register(...)
            const_get('RegistryStore').send(:register, ...)
          end
        end

        # "Delegate" #registry to class
        def registry(name)
          self.class.registry(name)
        end

        include RegistrationOffice[:demand]
      end
    end
  end
end
