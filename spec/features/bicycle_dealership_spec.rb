# frozen_string_literal: true

RSpec.describe 'bicycle dealership' do
  before do
    dealer_class =
      Class.new do
        include RegistrationOffice[:registration]

        register(
          :failures,
          keys:
            [
              :invalid_bicycle_configuration,
              :invalid_coupon_code,
              :bicycle_not_in_stock,
              { customer_not_solvent: { message: 'Sent the Collector!' } }
            ]
        )

        def call(customers_order)
          return demand(:failures).key!(:insult) if customers_order == :car

          return demand(:failures).key!(:invalid_bicycle_configuration) if customers_order == :bicycle_with_zero_wheels

          Dealership::Order.new.invoice(customers_order)
        end
      end

    stub_const('Dealer', dealer_class)

    order_class =
      Class.new do
        include RegistrationOffice[:demand]

        add_demand(:failures, Dealer)

        def invoice(customers_order)
          case customers_order
          when :golden_bike
            demand(:failures).use!(:customer_not_solvent)
          when :cool_bike
            demand(:failures).key!(:bicycle_not_in_stock)
          else
            'thx for your order'
          end
        end
      end

    stub_const('Dealership::Order', order_class)

    supervisor_class =
      Module.new do
        include RegistrationOffice[:demand]

        add_demand(:failures, Dealer)

        def self.supervise
          demand(:failures).keys
        end
      end

    stub_const('Company::Supervisor', supervisor_class)
  end

  describe 'the Dealer' do
    context 'when ordering a :car' do
      it 'tries to insult the customer but this raises UnregisteredKeyError' do
        expect { Dealer.new.call(:car) }
          .to raise_error(
                RegistrationOffice::Register::UnregisteredKeyError,
                'Register `failures` in `Dealer`: key `insult` is not registered'
              )
      end
    end

    context 'when ordering a :bicycle_with_zero_wheels' do
      it 'answers :invalid_bicycle_configuration' do
        expect(Dealer.new.call(:bicycle_with_zero_wheels)).to eq :invalid_bicycle_configuration
      end
    end

    context 'when ordering a :golden_bike' do
      it 'must reject the order because the customer is not rich enough' do
        expect(Dealer.new.call(:golden_bike)).to eq [:customer_not_solvent, { message: 'Sent the Collector!' }]
      end
    end

    context 'when ordering a cool_bike' do
      it 'must admit that the cool bike is out of stock' do
        expect(Dealer.new.call(:cool_bike)).to eq :bicycle_not_in_stock
      end
    end
  end

  describe 'the Supervisor' do
    it 'wants to see possible failures during ordering' do
      all_keys = [:invalid_bicycle_configuration, :invalid_coupon_code, :bicycle_not_in_stock, :customer_not_solvent]
      expect(Company::Supervisor.supervise).to eq all_keys
    end
  end
end
