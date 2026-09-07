# frozen_string_literal: true

RSpec.describe RegistrationOffice do
  describe 'meta' do
    it 'has a version number' do
      expect(RegistrationOffice::VERSION).not_to be_nil
    end
  end

  describe '.[]' do
    describe 'resolving module names' do
      describe ':registration' do
        it { expect(RegistrationOffice[:registration]).to eql(RegistrationOffice::Registry) }
      end

      describe ':demand' do
        before do
          test_class =
            Class.new do
              class << self
                def registry; end
              end
            end

          stub_const('RegistryObject', test_class)
        end

        it do
          expect(RegistrationOffice[:demand, registry_object: RegistryObject])
            .to respond_to(:included).and(be_a(Module))
        end
      end
    end
  end
end
