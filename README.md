# RegistrationOffice

The `registration_office` gem allows registering a collection of key-value pairs.
The registration is per class (or module), which is useful for registering possible failure codes that a service may return.
See also the example in section *Usage*.

## Installation

TODO

<!--Replace `UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

    $ bundle add UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG
-->

## Usage

### Define a Register

Just add `include RegistrationOffice[:registration]` to any class or model and start registering with `register <key>`:

```ruby
class MyService
  include RegistrationOffice[:registration]
  
  register :some_failure
  register :another_api_failure
end
```

While keys can be any Ruby object, it is recommended to use `Symbol`s for readability.

### Use a Register

The consuming class or module needs to include the `:demand` module that defines the target `registry_object`.

The register can then be queried by using `demand.key!(<key>)`:

```ruby
class ServiceCaller
  include RegistrationOffice[:demand, registry_object: MyService]
  
  def call
    demand.key!(:some_failure)
  end
  
  def bad_call
    demand.key!(:unknown_key)
  end
end

ServiceCaller.call
# => :some_failure

ServiceCaller.bad_call
# => MyService::RegistryStore::UnregisteredKeyError: 'key `some_failure` is not registered'
```

### Example

Assume following `BicycleDealer` class:

```ruby
class BicycleDealer
  include RegistrationOffice[:registration]

  register :invalid_bicycle_configuration
  register :invalid_coupon_code
  register :bicycle_not_in_stock
  register :customer_not_solvent

  def call(customers_order)
    return demand.key!(:insult) if customers_order == :car

    if customers_order == :bicycle_with_zero_wheels
      return demand.key!(:invalid_bicycle_configuration)
    end

    Order.new.invoice(customers_order)
  end
end
```
And an `Order` class that wants to use the registered keys from `BicycleDealer`:

```ruby
class Order
 include RegistrationOffice[:demand, registry_object: BicycleDealer]

  def invoice(customers_order)
    case customers_order
    when :golden_bike
      demand.key!(:customer_not_solvent)
    when :cool_bike
      demand.key!(:bicycle_not_in_stock)
    else
      'thx for your order'
    end
  end
end
```

Unregistered keys raise an error that is nested in the registering class:

```ruby
BicycleDealer.new.call(:car)
# raises UnregisteredKeyError:
# => Dealer::RegistryStore::UnregisteredKeyError: 'key `insult` is not registered'

BicycleDealer.new.call(:golden_bike)
# => :customer_not_solvent
```

Get all registered keys with `registry.keys`

```ruby
BicycleDealer.registry.keys
 # => [:invalid_bicycle_configuration, :invalid_coupon_code, ...]
```

Which is the same as `demand.keys` within demanding objects

```ruby
Order.demand.keys
# => [:invalid_bicycle_configuration, :invalid_coupon_code, ...]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/AEC3-Deutschland-GmbH/registration_office.
This project is intended to be a safe, welcoming space for collaboration., and contributors are expected to adhere to the [code of conduct](CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RegistrationOffice project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](CODE_OF_CONDUCT.md).
