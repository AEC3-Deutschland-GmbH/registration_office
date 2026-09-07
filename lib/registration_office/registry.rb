# frozen_string_literal: true

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
          const_set('MultipleRegistriesError', Class.new(StandardError))
          const_set('UnregisteredKeyError', Class.new(StandardError))
          const_set('DuplicateKeyError', Class.new(StandardError))

          class << self
            def registry
              @registry ||= {}
            end

            alias_method :all, :registry

            def keys
              registry.keys
            end

            def use!(key)
              raise const_get('UnregisteredKeyError'), "key `#{key}` is not registered" unless key?(key)

              [key, key?(key)]
            end

            def key!(key)
              raise const_get('UnregisteredKeyError'), "key `#{key}` is not registered" unless key?(key)

              key
            end

            def key?(key)
              registry[key]
            end

            private

            def register(*keys)
              raise const_get('MultipleRegistriesError'), 'registering is only allowed once' if @registry

              keys.each do |key|
                raise const_get('DuplicateKeyError'), "key `#{key}` already registered" if registry.key?(key)

                registry[key] = []
              end
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
