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

  describe 'POST /tasks' do
    let(:task_params){ attributes_for(:task) }
    
    before do
      post '/tasks', params: { task: task_params }.to_json, headers: headers
    end

    context 'Quando os dados estão corretos' do
      it 'retorna http status 201 :created' do
        expect(response).to have_http_status(:created)
      end

      it 'Certifica-se que tarefa foi salva no bancoe' do
        expect(Task.find_by(title: task_params[:title])).not_to be_nil
      end

      it 'Retorna as informações da tarefa criada' do
        expect(json_body[:title]).to eq(task_params[:title])
      end

      it 'Cerifica-se que a tarefa esta sendo associada ao usuário logado' do
        expect(json_body[:user_id]).to eq(user.id)
      end
    end

    context 'Quando os dados são INVALIDOS' do
      let(:task_params){ attributes_for(:task, title: ' ')}

      it 'Retorna status code 422 :unprocessable_entity' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'Certifica-se que a tarefa não foi salva' do
        expect(Task.find_by(title: task_params[:title])).to be_nil
      end

      it 'Certifica-se que JSON tem erro de Titulo' do
        expect(json_body[:errors]).to have_key(:title)
      end
    end
  end

  describe 'PATCH /tasks/:id' do
    let!(:task){ create(:task, user_id: user.id)}
    let!(:task_params){ {title: "Atualizando titulo da tarefa"} }

    before do
      put "/tasks/#{task.id}", params: {task: task_params}.to_json, headers: headers
    end

    context 'Quando os dados de update estão corretos' do      
      it 'Retorna codigo 200 :ok' do
        expect(response).to have_http_status(:ok)
      end

      it 'Certifica-se que o campo foi atualizado' do
        expect(json_body[:title]).to eq(task_params[:title])
      end

      it 'Certifica-se que o os dadaos foram atualizados no banco' do
        expect(Task.find_by(title: task_params[:title])).not_to be_nil
      end
    end

    context 'Quando os dados de update NÂO estão corretos' do
       let!(:task_params){ {title: " "} }      
      it 'Retorna codigo 422 :unprocessable_entity' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'Certifica-se do erro no campo titulo' do
        expect(json_body[:errors]).to have_key(:title)
      end

      it 'Certifica-se que o os dadaos NÂO foram atualizados no banco' do
        expect(Task.find_by(title: task_params[:title])).to be_nil
      end
    end
  end

  describe 'DELETE /tasks/:id' do
    let!(:task){ create(:task, user_id: user.id)}

    before do
      delete "/tasks/#{task.id}", params: {}, headers: headers
    end

    it 'Recebe codigo de retorno :no_content' do
      expect(response).to have_http_status(:no_content)
    end

    it 'Não encontra a tarefa no banco de dados' do
      expect{ Task.find(task.id)}.to raise_error(ActiveRecord::RecordNotFound)
    end

  end

end