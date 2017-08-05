require 'rails_helper'

RSpec.describe User, type: :model do

  let(:user) { build(:user)}

  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  it { is_expected.to validate_confirmation_of(:password) }
  it { is_expected.to allow_value('meu@email.com.br').for(:password) }
  it { is_expected.to validate_uniqueness_of(:auth_token) }

  describe '#info' do
    it 'Retorna e-mail,Data de criação e um Token' do
      user.save!
      allow(Devise).to receive(:friendly_token).and_return('meu_token_123_xyz')
      
      expect(user.info).to eq("#{user.email} - #{user.created_at} - Token: #{Devise.friendly_token}")
    end
  end

end
