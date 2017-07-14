require 'rails_helper'


RSpec.describe 'Users API', type: :request do
  let!(:user){ create(:user) }
  let!(:user_id){ user.id }

  before{ host! 'api.taskmanager.test'}

  describe 'GET /users/:id' do
    before do
      headers = { 'Accept' => 'application/vnd.taskmanager.v1' }
      get "/users/#{user_id}", params: {}, headers: headers
    end

    context 'Quando o usuário existe' do
      it 'Retorna o usuário' do
        user_response = JSON.parse(response.body)
        expect(user_response['id']).to eq(user_id)
      end

      it 'A Requisição retorna OK (200)' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'Quando o usuário NÃO existe' do
      let!(:user_id){ 9000 }
      it 'A Requisição retorna NOT_FOUND (404)' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

end