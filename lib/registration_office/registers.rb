# frozen_string_literal: true

module RegistrationOffice
  # Provides a register of registers
  class Registers
    class DuplicateRegisterNameError < StandardError; end

    class UnregisteredRegisterNameError < StandardError; end

    def register_a_register(register_name, register)
      if register_registry.key?(register_name)
        raise DuplicateRegisterNameError, "A register with name `#{register_name}` is already registered"
      end

      register_registry[register_name] = register
    end

    def fetch(register_name)
      unless register_registry.key?(register_name)
        raise UnregisteredRegisterNameError, "A register with name `#{register_name}` is not registered"
      end

      register_registry[register_name]
    end

    def all
      register_registry
    end

    private

    def register_registry
      @register_registry ||= {}
    end
  end
end
