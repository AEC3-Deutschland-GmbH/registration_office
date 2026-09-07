# frozen_string_literal: true

RSpec.describe RegistrationOffice::Registry do
  describe '.included' do
    describe 'constant and method declaration' do
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
          expect { RegisteringClass.register }
            .to raise_error NoMethodError, "private method 'register' called for class RegisteringClass"
        end

        it 'is not defined as instance method' do
          expect { RegisteringClass.new.register }
            .to raise_error NoMethodError, "undefined method 'register' for an instance of RegisteringClass"
        end
      end
    end

    describe 'after including' do
      describe '.register' do
        describe 'behavior' do
          context 'when a register with same name was already declared' do
            before do
              test_class =
                Class.new do
                  include RegistrationOffice::Registry

                  register(:some_name, keys: [:a])
                  register(:some_other_name, keys: [:b])
                end

              stub_const('RegisteringClass', test_class)
            end

            let(:register_duplicate_registers) do
              RegisteringClass.class_eval do
                register(:some_name, keys: [:c])
              end
            end

            it do
              expect { register_duplicate_registers }
                .to raise_error(
                      RegistrationOffice::Registers::DuplicateRegisterNameError,
                      'A register with name `some_name` is already registered'
                    )
            end
          end

          context 'when key was already declared' do
            before do
              test_class =
                Class.new do
                  include RegistrationOffice::Registry
                end

              stub_const('RegisteringClass', test_class)
            end

            let(:register_duplicate_key) do
              RegisteringClass.class_eval do
                register(:some_name, keys: [:key_one, :key_one])
              end
            end

            it do
              expect { register_duplicate_key }
                .to raise_error(
                      RegistrationOffice::Register::DuplicateKeyError,
                      'Register `some_name` in `RegisteringClass`: key `key_one` already registered'
                    )
            end
          end

          context 'when multiple keys are declared' do
            before do
              test_class =
                Class.new do
                  include RegistrationOffice::Registry

                  register(:some_name, keys: [:key_one, :key_two])
                end

              stub_const('RegisteringClass', test_class)
            end

            describe '.key!' do
              subject(:registering_class) { RegisteringClass }

              it 'returns the key when registered' do
                expect(registering_class.registry(:some_name).key!(:key_one)).to be :key_one
              end

              it 'raises RegistrationOffice::Register::UnregisteredKeyError when not registered' do
                expect { registering_class.registry(:some_name).key!(:xxx) }
                  .to raise_error(
                        RegistrationOffice::Register::UnregisteredKeyError,
                        'Register `some_name` in `RegisteringClass`: key `xxx` is not registered'
                      )
              end
            end

            describe '#key!' do
              subject(:registering_instance) { RegisteringClass.new }

              it 'returns the key when registered' do
                expect(registering_instance.registry(:some_name).key!(:key_one)).to be :key_one
              end

              it 'raises RegistrationOffice::Register::UnregisteredKeyError when not registered' do
                expect { registering_instance.registry(:some_name).key!(:xxx) }
                  .to raise_error(
                        RegistrationOffice::Register::UnregisteredKeyError,
                        'Register `some_name` in `RegisteringClass`: key `xxx` is not registered'
                      )
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

              register(:some_name, keys: [:key_one, :key_two])
            end

          stub_const('RegisteringClass', test_class)
        end

        it { expect(RegisteringClass.registry(:some_name)).to be_a RegistrationOffice::Register }

        describe '.all' do
          it { expect(RegisteringClass.registry(:some_name).all).to eq({ key_one: [], key_two: [] }) }
        end

        describe '.keys' do
          it { expect(RegisteringClass.registry(:some_name).keys).to eq([:key_one, :key_two]) }
        end
      end

      describe '.demand' do
        before do
          test_class =
            Class.new do
              include RegistrationOffice::Registry

              register(:some_name, keys: [:key_one, :key_two])
            end

          stub_const('RegisteringClass', test_class)
        end

        describe '#demand for itself' do
          context 'when called on class' do
            it { expect(RegisteringClass.demand(:some_name)).to respond_to(:key!) }
            it { expect(RegisteringClass.demand(:some_name)).to respond_to(:use!) }
          end

          context 'when called on instance' do
            it { expect(RegisteringClass.new.demand(:some_name)).to respond_to(:key!) }
            it { expect(RegisteringClass.new.demand(:some_name)).to respond_to(:use!) }
          end
        end
      end
    end
  end
end
