# frozen_string_literal: true

RSpec.describe 'abstract full integration' do
  before do
    dealer_class =
      Class.new do
        include RegistrationOffice[:registration]

        register(
          :invalid_bicycle_configuration,
          :invalid_coupon_code,
          :bicycle_not_in_stock,
          :customer_not_solvent
        )

        def self.self_demand_key(key)
          demand.key!(key)
        end

        def demand_key(key)
          self.class.demand.key!(key)
        end
      end

    stub_const('Dealer', dealer_class)

    order_class =
      Class.new do
        include RegistrationOffice[:demand, registry_object: Dealer]

        def self.self_demand_key(key)
          demand.key!(key)
        end

        def demand_key(key)
          demand.key!(key)
        end
      end

    stub_const('Dealership::Order', order_class)
  end

  describe 'registering object' do
    describe 'demanding on its own registry' do
      context 'when called on instance' do
        it { expect(Dealer.new.demand_key(:invalid_bicycle_configuration)).to eq :invalid_bicycle_configuration }
      end

      context 'when called on class' do
        it { expect(Dealer.self_demand_key(:invalid_bicycle_configuration)).to eq :invalid_bicycle_configuration }
      end
    end

    describe '.registry.all' do
      it do
        all_keys = [:invalid_bicycle_configuration, :invalid_coupon_code, :bicycle_not_in_stock, :customer_not_solvent]
        expect(Dealer.registry.keys).to eq all_keys
      end
    end
  end

  describe 'demanding objects' do
    describe 'demanding a valid key' do
      context 'when called on instance' do
        it { expect(Dealership::Order.new.demand_key(:invalid_bicycle_configuration)).to eq :invalid_bicycle_configuration }
      end

      context 'when called on class' do
        it { expect(Dealership::Order.self_demand_key(:invalid_bicycle_configuration)).to eq :invalid_bicycle_configuration }
      end
    end

    describe 'demanding an invalid key' do
      let(:unregistered_key_error) { [RegistrationOffice::Register::UnregisteredKeyError, 'Register `placeholder` in `Dealer`: key `xxx` is not registered'] }

      context 'when called on instance' do
        it { expect { Dealership::Order.new.demand_key(:xxx) }.to raise_error(*unregistered_key_error) }
      end

      context 'when called on class' do
        it { expect { Dealership::Order.self_demand_key(:xxx) }.to raise_error(*unregistered_key_error) }
      end
    end
  end
end
