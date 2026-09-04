# frozen_string_literal: true

require_relative 'registration_office/version'
require_relative 'registration_office/registry'
require_relative 'registration_office/demand'

module RegistrationOffice
  def self.[](module_name, registry_object: nil)
    case module_name
    when :registration
      Registry
    when :demand
      Demand[registry_object]
    end
  end
end
