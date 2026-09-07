# frozen_string_literal: true

module RegistrationOffice
  # Provides a named key register.
  class Register
    class DuplicateKeyError < StandardError; end

    class UnregisteredKeyError < StandardError; end

    attr_reader :name

    def initialize(registering_object, name)
      @registering_object = registering_object
      @name = name
    end

    def register_keys(*keys)
      keys.each do |key|
        raise DuplicateKeyError, "#{identifier}: key `#{key}` already registered" if registry.key?(key)

        registry[key] = []
      end
    end

    def keys
      registry.keys
    end

    def use!(key)
      raise UnregisteredKeyError, "#{identifier}: key `#{key}` is not registered" unless key?(key)

      [key, key?(key)]
    end

    def key!(key)
      raise UnregisteredKeyError, "#{identifier}: key `#{key}` is not registered" unless key?(key)

      key
    end

    def key?(key)
      registry[key]
    end

    def registry
      @registry ||= {}
    end

    private

    def identifier
      "Register `#{name}` in `#{@registering_object}`"
    end
  end
end
