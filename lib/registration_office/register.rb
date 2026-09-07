# frozen_string_literal: true

module RegistrationOffice
  # Provides a named key register.
  class Register
    class DuplicateKeyError < StandardError; end

    class UnregisteredKeyError < StandardError; end

    attr_reader :name

    def initialize(registering_object)
      @registering_object = registering_object
    end

    def register_keys(name, keys:)
      @name = name
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

    def all
      registry.to_h
    end

    private

    def identifier
      "Register `#{name}` in `#{@registering_object}`"
    end
  end
end
