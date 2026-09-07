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

            def registry(name = :placeholder)
              registers.fetch(name)
            end

            def all
              registry.registry
            end

            def keys
              registry.keys
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

            def register(*keys, name: :placeholder)
              register = Register.new(registering_object).tap { it.register_keys(name, keys:) }
              registers.register_a_register(name, register)
            end
          end
        end

        # This is evaluated on "self" for the including class/module
        class << self
          def registry
            const_get('RegistryStore')
          end

          private

          def register(...)
            const_get('RegistryStore').send(:register, ...)
          end
        end

        # "Delegate" #registry to class
        def registry
          self.class.registry
        end

        include RegistrationOffice[:demand, registry_object: base]
      end
    end
  end
end
