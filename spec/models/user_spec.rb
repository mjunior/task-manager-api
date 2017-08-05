require 'rails_helper'

RSpec.describe User, type: :model do

  let(:user) { build(:user)}
  let(:fake_token) { 'abc-123_xyz[987]' }

  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  it { is_expected.to validate_confirmation_of(:password) }
  it { is_expected.to allow_value('meu@email.com.br').for(:password) }
  it { is_expected.to validate_uniqueness_of(:auth_token) }

  describe '#info' do
    it 'Retorna e-mail,Data de criação e um Token' do
      user.save!
      allow(Devise).to receive(:friendly_token).and_return(fake_token)
      
      expect(user.info).to eq("#{user.email} - #{user.created_at} - Token: #{Devise.friendly_token}")
    end
  end

  describe '#generate_authentication_token!' do
    it 'Gera um token unico' do
      allow(Devise).to receive(:friendly_token).and_return(fake_token)
      
      user.generate_authentication_token!

      expect(user.auth_token).to eq(fake_token)
    end

    it 'Gera um novo token se o atual já é utilizado' do
      allow(Devise).to receive(:friendly_token).and_return('abc123','abc123',fake_token)
      existing_user = create(:user)
      user.generate_authentication_token!

      expect(user.auth_token).not_to eq(existing_user.auth_token)
    end
  end

end
