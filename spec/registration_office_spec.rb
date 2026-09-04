# frozen_string_literal: true

RSpec.describe RegistrationOffice do
  describe 'meta' do
    it 'has a version number' do
      expect(RegistrationOffice::VERSION).not_to be nil
    end
  end

  it 'does something useful' do
    expect(false).to eq(true)
  end
end
