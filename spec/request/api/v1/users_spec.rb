require 'rails_helper'


RSpec.describe 'Users API', type: :request do
  let!(:user){ create(:user) }
  let!(:user_id){ user.id }
  let!(:headers)do
    {
      'Accept' => 'application/vnd.taskmanager.v1',
      'Content-Type' => Mime[:json].to_s,
      'Authorization' => user.auth_token
    }
  end

  before{ host! 'api.taskmanager.test'}

  describe 'GET /users/:id' do
    before do
      get "/users/#{user_id}", params: {}, headers: headers
    end

    context 'Quando o usuário existe' do
      it 'Retorna o usuário' do
        expect(json_body[:id]).to eq(user_id)
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
      post '/users', params: {user: user_params}.to_json, headers: headers
    end

    context 'Quando os parametros para criação do usuário são validos' do
      let(:user_params){ attributes_for(:user) }

      it 'Retorna código 201 :created' do
        expect(response).to have_http_status(:created)
      end

      it 'Retorna o JSON do usuário cadastrado' do
        expect(json_body[:email]).to eq(user_params[:email])
      end
    end

    context 'Quando os parametros para criação do usuário NÃO são validos' do 
      let(:user_params){ attributes_for(:user, email: "invalid_mail") }

      it 'Retorna codigo unprocessable_entity' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'Retorna mensagens de errors' do
       expect(json_body).to have_key(:errors)
      end
    end
  end

  describe 'PUT /users/:id' do
    before do
      put "/users/#{user_id}", params: {user: user_params}.to_json, headers: headers
    end
    
    context 'Quando a requisição for valida' do
      let(:user_params) {{email: 'new_email@taskmanager.dev.br'}}

      it 'Retorna status OK' do
        expect(response).to have_http_status(:ok)
      end

      it 'Retorna os dados do usuario retornado' do
        expect(json_body[:email]).to eq(user_params[:email])
      end
    end

    context 'Quando a requisição NÃO for invalida' do
      let(:user_params){ {email: 'invalid_mail'} }

      it 'Retorna requisição não processada' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'Verifica a chave de erros na resposta' do
        expect(json_body).to have_key(:errors)
      end
    end
  end

  describe 'DELETE /users/:id' do
    
    before do
      delete "/users/#{user_id}", params: {}, headers: headers
    end

    it 'A requisição deleta o usuário e retorna 204' do
      expect(response).to have_http_status(:no_content)
    end

    it 'O usuário deletado não deve ser encontrado' do
      expect(User.find_by(id: user_id)).to be_nil
    end
  end
end