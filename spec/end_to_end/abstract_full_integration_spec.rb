# frozen_string_literal: true

RSpec.describe 'abstract full integration' do
  before do
    test_class =
      Class.new do
        include RegistrationOffice[:registration]

        register :invalid_bicycle_configuration
        register :invalid_coupon_code
        register :bicycle_not_in_stock
        register :customer_not_solvent

        def self.self_demand_key(key)
          demand.key!(key)
        end

        def demand_key(key)
          self.class.demand.key!(key)
        end
      end

    stub_const('Dealer', test_class)
  end

  before do
    test_class =
      Class.new do
        include RegistrationOffice[:demand, registry_object: Dealer]

        def self.self_demand_key(key)
          demand.key!(key)
        end

        def demand_key(key)
          demand.key!(key)
        end
      end

    stub_const('Dealership::Order', test_class)
  end

  describe 'registering object' do
    describe 'demanding on its own registry' do
      context 'on instance' do
        it { expect(Dealer.new.demand_key(:invalid_bicycle_configuration)).to eq :invalid_bicycle_configuration }
      end

      context 'on class' do
        it { expect(Dealer.self_demand_key(:invalid_bicycle_configuration)).to eq :invalid_bicycle_configuration }
      end
    end

    describe '.registry.all' do
      it { expect(Dealer.registry.keys).to eq [:invalid_bicycle_configuration, :invalid_coupon_code, :bicycle_not_in_stock, :customer_not_solvent] }
    end
  end

  describe 'demanding objects' do
    describe 'demanding a valid key' do
      context 'on instance' do
        it { expect(Dealership::Order.new.demand_key(:invalid_bicycle_configuration)).to eq :invalid_bicycle_configuration }
      end

      context 'on class' do
        it { expect(Dealership::Order.self_demand_key(:invalid_bicycle_configuration)).to eq :invalid_bicycle_configuration }
      end
    end

    describe 'demanding an invalid key' do
      context 'on instance' do
        it { expect { Dealership::Order.new.demand_key(:xxx) }.to raise_error Dealer::RegistryStore::UnregisteredKeyError, 'key `xxx` is not registered' }
      end

      context 'on class' do
        it { expect { Dealership::Order.self_demand_key(:xxx) }.to raise_error Dealer::RegistryStore::UnregisteredKeyError, 'key `xxx` is not registered' }
      end
    end
  end
end
