require 'rails_helper'


RSpec.describe 'Users API', type: :request do
  let!(:user){ create(:user) }
  let!(:user_id){ user.id }

  before{ host! 'api.taskmanager.test'}

  describe 'GET /users/:id' do
    before do
      header = { 'Accept' => 'application/vnd.taskmanager.v1' }
      get "/users/#{user_id}", params: {}, headers: header
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
  

  describe 'POST /users' do

    before do
      header = {'Accept' => 'application/vnd.taskmanager.v1'}
      post '/users', params: {user: user_params}, headers: header
    end

    context 'Quando os parametros para criação do usuário são validos' do
      let(:user_params){ attributes_for(:user) }

      it 'Retorna código 201 :created' do
        expect(response).to have_http_status(:created)
      end

      it 'Retorna o JSON do usuário cadastrado' do
        user_response = JSON.parse(response.body)
        expect(user_response['email']).to eq(user_params[:email])
      end
    end

    context 'Quando os parametros para criação do usuário NÃO são validos' do 
      let(:user_params){ attributes_for(:user, email: "invalid_mail") }

      it 'Retorna codigo unprocessable_entity' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'Retorna mensagens de errors' do
        user_response = JSON.parse(response.body)
        expect(user_response).to have_key('errors')
      end
    end
  end
end