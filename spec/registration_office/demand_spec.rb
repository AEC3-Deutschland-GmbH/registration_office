# frozen_string_literal: true

RSpec.describe RegistrationOffice::Demand do
  def stub_registry_class
    test_class =
      Class.new do
        include RegistrationOffice::Registry
      end

    stub_const('RegistryObject', test_class)
  end

  def stub_registry_module
    test_module =
      Module.new do
        include RegistrationOffice::Registry
      end

    stub_const('RegistryObject', test_module)
  end

  describe '.[]' do
    it 'returns a Module' do
      stub_registry_class
      expect(RegistrationOffice::Demand[RegistryObject]).to be_a(Module)
    end
  end

  describe '.safe_constantize' do
    subject(:call_described_method) { RegistrationOffice::Demand.send(:safe_constantize, registry_object) }

    context 'when given registry object is a Module' do
      let(:registry_object) { RegistryObject }

      before { stub_registry_module }

      it { expect { call_described_method }.not_to raise_error }
      it { is_expected.to be registry_object }
    end

    context 'when given registry object is a Class' do
      let(:registry_object) { RegistryObject }

      before { stub_registry_class }

      it { expect { call_described_method }.not_to raise_error }
      it { is_expected.to be registry_object }
    end

    context 'when given registry object is a String' do
      context 'that does not define any Class or Module' do
        let(:registry_object) { 'xxx' }

        it { expect { call_described_method }.to raise_error ArgumentError, '`xxx` is not a known Class or Module' }
      end

      context 'that defines a known Class or Module' do
        let(:registry_object) { RegistryObject.to_s }

        before { stub_registry_class }

        it { expect { call_described_method }.not_to raise_error }
        it { is_expected.to be RegistryObject }
      end
    end
  end

  describe '.prepare_mod' do
    let!(:dynamic_module) { stub_const('DynamicModule', Module.new) }

    describe 'DynamicModule' do
      before { RegistrationOffice::Demand.send(:prepare_mod, dynamic_module, stub_registry_class) }

      it 'defines .included' do
        expect(DynamicModule).to respond_to(:included)
      end

      it { expect { Module.new.include(DynamicModule) }.not_to raise_error }
      it { expect { Class.new.include(DynamicModule) }.not_to raise_error }
    end

    context 'when included' do
      before do
        RegistrationOffice::Demand.send(:prepare_mod, dynamic_module, stub_registry_class)
        test_class =
          Class.new do
            include DynamicModule
          end

        stub_const('DemandingObject', test_class)
      end

      describe 'singleton methods and constants' do
        it { expect(DemandingObject).to respond_to(:demand) }
        it { expect(DemandingObject).to be_const_defined(:RegistryDemand) }

        describe 'delegated via #demand' do
          it { expect(DemandingObject.demand).to respond_to(:key!) }
          it { expect(DemandingObject.demand).to respond_to(:use!) }
          it { expect(DemandingObject.demand).to respond_to(:keys) }
        end
      end

      describe 'instance methods' do
        it { expect(DemandingObject.new).to respond_to(:demand) }

        describe 'delegated via #demand' do
          it { expect(DemandingObject.new.demand).to respond_to(:key!) }
          it { expect(DemandingObject.new.demand).to respond_to(:use!) }
          it { expect(DemandingObject.new.demand).to respond_to(:keys) }
        end
      end
    end
  end
end
