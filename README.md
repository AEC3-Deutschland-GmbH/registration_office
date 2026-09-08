# RegistrationOffice

The `registration_office` gem allows registering a collection of key-value pairs. The registration is per class (or
module), which is useful for registering possible failure codes that a service may return. See also the example in
section [*Example*](#example).

## Installation

Currently, the gem is only available via GitHub:

```ruby
# Gemfile
gem 'registration_office', '0.2.0', github: 'AEC3-Deutschland-GmbH/registration_office'
```

<!--Replace `UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

    $ bundle add UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG
-->

## Usage

### Define a Register

#### Keys only

Just add `include RegistrationOffice[:registration]` to any class or model
and start registering with `register(<name>, keys: [<keys>])`:

```ruby

class MyService
  include RegistrationOffice[:registration]

  register(
    :some_name,
    keys: [
      :some_failure,
      :another_api_failure
    ]
  )
end
```

While keys can be any Ruby object, it is recommended to use `Symbol`s for readability.

#### Keys with Payload

The gem's version `v0.3.0` adds optional payload for each key:

```ruby
class MyService
  include RegistrationOffice[:registration]

  register(
    :some_name,
    keys: [
            { some_failure: { message: 'Something went wrong' } },
            :another_api_failure
    ]
  )
end

MyService.demand(:some_name).key!(:some_failure)
# => :some_failure

MyService.demand(:some_name).use!(:some_failure)
# => [:some_failure, { :message => "Something went wrong" }]

MyService.demand(:some_name).use!(:another_api_failure)
# => [:another_api_failure, []]
```

### Use a Register

The consuming class or module needs to include the `:demand` module and show their demand with `.add_demand`.

The register can then be queried by using `demand.key!(<key>)`:

```ruby

class ServiceCaller
  include RegistrationOffice[:demand]
  add_demand(:some_name, MyService)

  def call
    demand(:some_name).key!(:some_failure)
  end

  def bad_call
    demand(:some_name).key!(:unknown_key)
  end

  def unregistered_name
    demand(:i_do_not_know_you)
  end
end

ServiceCaller.call
# => :some_failure

ServiceCaller.bad_call
# => RegistrationOffice::Register::UnregisteredKeyError:
#    'Register `some_name` in `MyService`: key `unknown_key` is not registered'

ServiceCaller.unregistered_name
# => RegistrationOffice::Registers::UnregisteredRegisterNameError:
#    A register with name `i_do_not_know_you` is not registered
```

Note that you do not need to define a demand for the registering object itself.
As soon as you `register` a register, the corresponding `demand` methods (class/mdoule and instance method)
are automatically added.

### Multiple Registers

It is possible to define more than one register.
You may have guessed it: this is what the first argument in `.register` is for.
It defines the name of the register and can be named as you want.
Defining another register with the same name within the same object raises 
`RegistrationOffice::Registers::DuplicateRegisterNameError`.

**Note**

The registers are isolated within their registering object.
You can use the same name in different registering objects.
But be aware that this restricts you from using them in the same demanding objects:

```ruby
class ServiceCaller
  include RegistrationOffice[:demand]
  add_demand(:some_name, MyService)
  add_demand(:some_name, MyOtherService)
end
# => RegistrationOffice::Demand::DuplicateDemandNameError
#    "A register with name `some_name` is already demanded"

```

## Example

Assume following `BicycleDealer` class:

```ruby

class BicycleDealer
  include RegistrationOffice[:registration]

  register(
    :failures,
    keys: [
      :invalid_bicycle_configuration,
      :invalid_coupon_code,
      :bicycle_not_in_stock,
      :customer_not_solvent,
    ]
  )

  def call(customers_order)
    return demand(:failures).key!(:insult) if customers_order == :car

    if customers_order == :bicycle_with_zero_wheels
      return demand(:failures).key!(:invalid_bicycle_configuration)
    end

    Order.new.invoice(customers_order)
  end
end
```

And an `Order` class that wants to use the registered keys from `BicycleDealer`:

```ruby

class Order
  include RegistrationOffice[:demand]
  add_demand(:failures, BicycleDealer)

  def invoice(customers_order)
    case customers_order
    when :golden_bike
      demand(:failures).key!(:customer_not_solvent)
    when :cool_bike
      demand(:failures).key!(:bicycle_not_in_stock)
    else
      'thx for your order'
    end
  end
end
```

Unregistered keys raise an error:

```ruby
BicycleDealer.new.call(:car)
# raises UnregisteredKeyError:
# => RegistrationOffice::Register::UnregisteredKeyError:
#    'Register `failures` in `BicycleDealer`: key `insult` is not registered'

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

## Roadmap

If this gem proves to be useful, following topics may be added:

- Meta:
    - Publishing on https://gem.coop
    - CI/CD via GitHub Actions (`rspec`, `rubocop`, publishing)
- Features: currently nothing more planned

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can
also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the
version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version,
push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/AEC3-Deutschland-GmbH/registration_office.
This project is intended to be a safe, welcoming space for collaboration., and contributors are expected to adhere to
the [code of conduct](CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RegistrationOffice project's codebases, issue trackers, chat rooms and mailing lists is
expected to follow the [code of conduct](CODE_OF_CONDUCT.md).
