# frozen_string_literal: true

RSpec.describe RegistrationOffice::Registry do
  describe '.included' do
    context 'constant and method declaration' do
      before do
        test_class =
          Class.new do
            include RegistrationOffice::Registry
          end

        stub_const('RegisteringClass', test_class)
      end

      it 'defines a RegistryStore' do
        expect { RegisteringClass::RegistryStore }.not_to raise_error
      end

      it { expect(RegisteringClass).to respond_to(:registry) }

      describe '.register' do
        it 'is defined as private singleton method' do
          expect { RegisteringClass.register }.to raise_error NoMethodError, "private method 'register' called for class RegisteringClass"
        end

        it 'is not defined as instance method' do
          expect { RegisteringClass.new.register }.to raise_error NoMethodError, "undefined method 'register' for an instance of RegisteringClass"
        end
      end
    end

    context 'after including' do
      describe 'methods' do
        before do
          test_class =
            Class.new do
              include RegistrationOffice::Registry
            end

          stub_const('RegisteringClass', test_class)
        end

        context 'on class' do
          it { expect(RegisteringClass.registry).to respond_to(:key?) }
          it { expect(RegisteringClass.registry).to respond_to(:all) }
          it { expect(RegisteringClass.registry).to respond_to(:key!) }
        end

        context 'on instance' do
          it { expect(RegisteringClass.new.registry).to respond_to(:key?) }
          it { expect(RegisteringClass.new.registry).to respond_to(:all) }
          it { expect(RegisteringClass.new.registry).to respond_to(:key!) }
        end
      end

      describe '.register' do
        describe 'behavior' do
          context 'when key was already declared' do
            before do
              test_class =
                Class.new do
                  include RegistrationOffice::Registry
                end

              stub_const('RegisteringClass', test_class)
            end

            it do
              expect do
                RegisteringClass.class_eval do
                  register :key_one
                  register :key_one
                end
              end.to raise_error RegisteringClass::RegistryStore::DuplicateKey, 'key `key_one` already registered'
            end
          end

          context 'when multiple keys are declared' do
            before do
              test_class =
                Class.new do
                  include RegistrationOffice::Registry

                  register :key_one
                  register :key_two
                end

              stub_const('RegisteringClass', test_class)
            end

            describe '.key!' do
              subject { RegisteringClass }

              it 'returns the key when registered' do
                expect(subject.registry.key!(:key_one)).to eql(:key_one)
              end

              it 'raises RegistryStore::UnregisteredKey when registered' do
                expect { subject.registry.key!(:xxx) }.to raise_error subject::RegistryStore::UnregisteredKey, 'key `xxx` is not registered'
              end
            end

            describe '#key!' do
              subject { RegisteringClass.new }

              it 'returns the key when registered' do
                expect(subject.registry.key!(:key_one)).to eql(:key_one)
              end

              it 'raises RegistryStore::UnregisteredKey when registered' do
                expect { subject.registry.key!(:xxx) }.to raise_error RegisteringClass::RegistryStore::UnregisteredKey, 'key `xxx` is not registered'
              end
            end
          end
        end
      end

      describe '.registry' do
        before do
          test_class =
            Class.new do
              include RegistrationOffice::Registry

              register :key_one
              register :key_two
            end

          stub_const('RegisteringClass', test_class)
        end

        it { expect(RegisteringClass.registry).to eq RegisteringClass::RegistryStore }

        describe '.all' do
          it { expect(RegisteringClass.registry.all).to eq({ key_one: [], key_two: [] }) }
        end

        describe '.keys' do
          it { expect(RegisteringClass.registry.keys).to eq([:key_one, :key_two]) }
        end
      end

      describe '.demand' do
        before do
          test_class =
            Class.new do
              include RegistrationOffice::Registry

              register :key_one
              register :key_two
            end

          stub_const('RegisteringClass', test_class)
        end

        describe '#demand for itself' do
          context 'on class' do
            it { expect(RegisteringClass.demand).to respond_to(:key!) }
            it { expect(RegisteringClass.demand).to respond_to(:use!) }
          end

          context 'on instance' do
            it { expect(RegisteringClass.new.demand).to respond_to(:key!) }
            it { expect(RegisteringClass.new.demand).to respond_to(:use!) }
          end
        end
      end
    end
  end
end
