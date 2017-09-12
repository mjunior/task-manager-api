require 'rails_helper'

RSpec.describe 'Tasks Api', type: :request do
  before{ host! 'api.taskmanager.test'}

  let!(:user) { create(:user) }
  let!(:headers)do
    {
      'Accept' => 'application/vnd.taskmanager.v1',
      'Content-Type' => Mime[:json].to_s,
      'Authorization' => user.auth_token
    }
  end

  describe 'GET /tasks' do
    before do
      create_list(:task, 5, user_id: user.id)
      get '/tasks', params: {}, headers: headers
    end
    it 'Responde status :OK' do
      expect(response).to have_http_status(:ok)
    end
    it 'Verifica o retorno das tarefas ' do
      expect(json_body[:tasks].count).to eq(5)
    end

  end

  describe 'GET /tasks/:id' do
    let(:task){ create(:task, user_id: user.id)}

    before do
      get "/tasks/#{task.id}", params: {}, headers: headers
    end

    it 'Retornar código 200 :ok' do
      expect(response).to have_http_status(:ok)
    end

    it 'Retorna o json da tarefa' do
      expect(json_body[:title]).to eq(task.title)
    end
  end
end