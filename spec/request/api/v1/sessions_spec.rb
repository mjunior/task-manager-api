require 'rails_helper'
RSpec.describe 'Session API', type: :request do
  before { host! 'api.task-manager.dev' }
  let!(:user) { create(:user) }
  let!(:headers) do
    {
      'Accept' => 'application/vnd.taskmanager.v1',
      'Content-Type' => Mime[:json].to_s
    }
  end

  describe 'POST /sessions' do
    before do
      post '/sessions', params:{session: credentials}.to_json, headers: headers
    end

    context 'Quando as credenciais estão corretas' do
      let(:credentials) {{ email: user.email, password: '123456' }}
      
      it 'A requisição deve retornar OK' do
        expect(response).to have_http_status(:ok)
      end

      it 'A requisição retorna os dados do usuario logado com o token' do
        user.reload
        expect(json_body).to have_key(:auth_token)
        expect(json_body[:auth_token]).to eq(user.auth_token)
      end
    end

    context 'Quando as credenciais estão INCORRETAS' do
      let(:credentials) {{ email: user.email, password: 'invalid_pw' }}
      
      it 'A requisição deve retornar UNAUTHORIZED' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'A requisição retorna os erros' do
        expect(json_body).to have_key(:errors)
      end
    end
  end

  describe 'DELETE /sessions/:id' do
    let(:auth_token){ user.auth_token }

    before do
      delete "/sessions/#{auth_token}", params: {}, headers: headers
    end

    it 'Retorna HTTP Status :no_content' do
      expect(response).to have_http_status(:no_content)
    end

    it 'Altera o token o usuário' do
      expect(User.find_by(auth_token: auth_token)).to be_nil
    end
    
      
  end
end