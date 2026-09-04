# frozen_string_literal: true

RSpec.describe RegistrationOffice do
  describe 'meta' do
    it 'has a version number' do
      expect(RegistrationOffice::VERSION).not_to be nil
    end
  end

  describe '.[]' do
    describe 'resolving module names' do
      it { expect(RegistrationOffice[:registration]).to eql(RegistrationOffice::Registry) }

      it do
        stub_const(
          'RegistryObject',
          Class.new do
            class << self
              def registry; end
            end
          end
        )

        expect(RegistrationOffice[:demand, registry_object: RegistryObject]).to respond_to(:included).and(be_a(Module))
      end
    end
  end
end
