# frozen_string_literal: true

RSpec.describe RegistrationOffice::Demand do
  def stub_registry_class
    test_class =
      Class.new do
        include RegistrationOffice::Registry

        register(:some_name, keys: [])
      end

    stub_const('RegistryObject', test_class)
  end

  def stub_registry_module
    test_module =
      Module.new do
        include RegistrationOffice::Registry

        register(:some_name, keys: [])
      end

    stub_const('RegistryObject', test_module)
  end

  describe '.prepare_mod' do
    let!(:dynamic_module) { stub_const('DynamicModule', Module.new) }

    describe 'DynamicModule' do
      it { expect { Module.new.include(RegistrationOffice::Demand.send(:prepare_mod, dynamic_module)) }.not_to raise_error }
      it { expect { Class.new.include(RegistrationOffice::Demand.send(:prepare_mod, dynamic_module)) }.not_to raise_error }
    end
  end

  describe '.included' do
    RSpec.shared_examples_for 'an object with demands' do |stubbed_registry_object|
      before do
        stub =
          case stubbed_registry_object
          when :class
            stub_registry_class
          when :module
            stub_registry_module
          end

        test_class =
          Class.new do
            include RegistrationOffice::Demand

            add_demand(:some_name, stub)
          end

        stub_const('DemandingObject', test_class)
      end

      describe 'singleton methods and constants' do
        it { expect(DemandingObject).to respond_to(:demand) }
        it { expect(DemandingObject).to respond_to(:add_demand) }
        it { expect(DemandingObject).to be_const_defined(:RegistryDemand) }

        describe 'delegated via #demand' do
          it { expect(DemandingObject.demand(:some_name)).to respond_to(:key!) }
          it { expect(DemandingObject.demand(:some_name)).to respond_to(:use!) }
          it { expect(DemandingObject.demand(:some_name)).to respond_to(:keys) }
        end
      end

      describe 'instance methods' do
        it { expect(DemandingObject.new).to respond_to(:demand) }

        describe 'delegated via #demand' do
          it { expect(DemandingObject.new.demand(:some_name)).to respond_to(:key!) }
          it { expect(DemandingObject.new.demand(:some_name)).to respond_to(:use!) }
          it { expect(DemandingObject.new.demand(:some_name)).to respond_to(:keys) }
        end
      end
    end

    context 'when included as class' do
      it_behaves_like 'an object with demands', :class
    end

    context 'when included as module' do
      it_behaves_like 'an object with demands', :module
    end

    context 'when another demand with the same name is demanded' do
      let(:double_demand) do
        stubbed_register_object1 = stub_registry_class
        stubbed_register_object2 = stub_registry_module
        test_class =
          Class.new do
            include RegistrationOffice::Demand

            add_demand(:some_name, stubbed_register_object1)
            add_demand(:some_name, stubbed_register_object2)
          end

        stub_const('DemandingObject', test_class)
      end

      it do
        expect { double_demand }.to raise_error(
                                      RegistrationOffice::Demand::DuplicateDemandNameError,
                                      'A register with name `some_name` is already demanded'
                                    )
      end
    end
  end
end
