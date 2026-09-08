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
        key_as_hash, actual_key = key_to_hash(key)
        raise DuplicateKeyError, "#{identifier}: key `#{actual_key}` already registered" if registry.key?(actual_key)

        registry.merge!(key_as_hash)
      end
    end

    def keys
      registry.keys
    end

    def use!(key)
      raise UnregisteredKeyError, "#{identifier}: key `#{key}` is not registered" unless key?(key)

      [key, registry[key]]
    end

    def key!(key)
      raise UnregisteredKeyError, "#{identifier}: key `#{key}` is not registered" unless key?(key)

      key
    end

    def key?(key)
      registry.key?(key)
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

    def key_to_hash(key)
      if key.is_a?(Hash)
        [key, key.keys.first]
      else
        [{ key => [] }, key]
      end
    end
  end
end
