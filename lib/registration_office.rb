# frozen_string_literal: true

require_relative 'registration_office/version'
require_relative 'registration_office/registry'
require_relative 'registration_office/demand'

# Assume following BicycleDealer class:
#   class BicycleDealer
#     include RegistrationOffice[:registration]
#
#     register(
#       :invalid_bicycle_configuration,
#       :invalid_coupon_code,
#       :bicycle_not_in_stock,
#       :customer_not_solvent,
#     )
#
#     def call(customers_order)
#       return demand.key!(:insult) if customers_order == :car
#
#       if customers_order == :bicycle_with_zero_wheels
#         return demand.key!(:invalid_bicycle_configuration)
#       end
#
#       Order.new.invoice(customers_order)
#     end
#   end
#
# And an Order class that wants to use the registered keys from BicycleDealer:
#   class Order
#    include RegistrationOffice[:demand, registry_object: BicycleDealer]
#
#     def invoice(customers_order)
#       case customers_order
#       when :golden_bike
#         demand.key!(:customer_not_solvent)
#       when :cool_bike
#         demand.key!(:bicycle_not_in_stock)
#       else
#         'thx for your order'
#       end
#     end
#   end
#
# Unregistered keys raise an error:
#   BicycleDealer.new.call(:car)
#   # raises UnregisteredKeyError:
#   # => RegistrationOffice::Register::UnregisteredKeyError: 'key `insult` is not registered'
#
#   BicycleDealer.new.call(:golden_bike)
#   # => :customer_not_solvent
#
# Get all registered keys with +registry.keys+
#   BicycleDealer.registry.keys
#   # => [:invalid_bicycle_configuration, :invalid_coupon_code, ...]
# Which is the same as +demand.keys+ within demanding objects
#   Order.demand.keys
#   # => [:invalid_bicycle_configuration, :invalid_coupon_code, ...]
module RegistrationOffice
  def self.[](module_name)
    case module_name
    when :registration
      Registry
    when :demand
      Demand
    end
  end
end
