require 'rails_helper'

describe Api::TodoListsController do
  render_views

  describe 'GET index' do
    let!(:todo_list) { TodoList.create(name: 'Setup RoR project') }

    context 'when format is HTML' do
      it 'raises a routing error' do
        expect {
          get :index
        }.to raise_error(ActionController::RoutingError, 'Not supported format')
      end
    end

    context 'when format is JSON' do
      it 'returns a success code' do
        get :index, format: :json

        expect(response.status).to eq(200)
      end

      it 'includes todo list records in the data key' do
        get :index, format: :json

        body = JSON.parse(response.body)
        todo_lists = body['data']

        aggregate_failures 'includes the id and name' do
          expect(todo_lists.count).to eq(1)
          expect(todo_lists[0].keys).to match_array(['id', 'name'])
          expect(todo_lists[0]['id']).to eq(todo_list.id)
          expect(todo_lists[0]['name']).to eq(todo_list.name)
        end
      end

      it 'includes pagination metadata' do
        get :index, format: :json

        pagination = JSON.parse(response.body)['pagination']

        aggregate_failures 'includes pagination keys' do
          expect(pagination.keys).to match_array(['current_page', 'total_pages', 'total_count', 'per_page'])
          expect(pagination['current_page']).to eq(1)
          expect(pagination['total_count']).to eq(1)
        end
      end

      context 'when there are more than 10 records' do
        before { 10.times { |i| TodoList.create(name: "List #{i}") } }

        it 'paginates to 10 per page by default' do
          get :index, format: :json

          body = JSON.parse(response.body)

          expect(body['data'].count).to eq(10)
          expect(body['pagination']['total_pages']).to eq(2)
        end

        it 'returns page 2 with ?page=2' do
          get :index, params: { page: 2 }, format: :json

          body = JSON.parse(response.body)

          expect(body['data'].count).to eq(1)
          expect(body['pagination']['current_page']).to eq(2)
        end

        it 'respects custom per_page param' do
          get :index, params: { per_page: 5 }, format: :json

          body = JSON.parse(response.body)

          expect(body['data'].count).to eq(5)
          expect(body['pagination']['total_pages']).to eq(3)
        end

        it 'caps per_page at 100' do
          get :index, params: { per_page: 999 }, format: :json

          expect(JSON.parse(response.body)['pagination']['per_page']).to eq(100)
        end
      end
    end
  end

  describe 'GET show' do
    let!(:todo_list) { TodoList.create(name: 'Setup RoR project') }

    it 'returns a success code' do
      get :show, params: { id: todo_list.id }, format: :json

      expect(response.status).to eq(200)
    end

    it 'returns the requested record' do
      get :show, params: { id: todo_list.id }, format: :json

      returned_todo_list = JSON.parse(response.body)

      aggregate_failures 'includes the id and name' do
        expect(returned_todo_list.keys).to match_array(['id', 'name'])
        expect(returned_todo_list['id']).to eq(todo_list.id)
        expect(returned_todo_list['name']).to eq(todo_list.name)
      end
    end
  end

  describe 'POST create' do
    context 'with valid parameters' do
      let(:valid_params) { { todo_list: { name: 'Setup RoR project' } } }

      it 'creates a new record' do
        expect {
          post :create, params: valid_params, format: :json
        }.to change(TodoList, :count).by(1)
      end

      it 'returns the created record' do
        post :create, params: valid_params, format: :json

        created_todo_list = JSON.parse(response.body)

        aggregate_failures 'includes the id and name' do
          expect(created_todo_list.keys).to match_array(['id', 'name'])
          expect(created_todo_list['name']).to eq(valid_params[:todo_list][:name])
        end
      end

      it 'returns a created status code' do
        post :create, params: valid_params, format: :json

        expect(response.status).to eq(201)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) { { todo_list: { name: '' } } }

      it 'does not create a new record' do
        expect {
          post :create, params: invalid_params, format: :json
        }.not_to change(TodoList, :count)
      end

      it 'returns error messages' do
        post :create, params: invalid_params, format: :json

        errors = JSON.parse(response.body)

        expect(errors['name']).to include("can't be blank")
      end

      it 'returns an unprocessable entity status code' do
        post :create, params: invalid_params, format: :json

        expect(response.status).to eq(422)
      end
    end
  end

  describe 'PUT update' do
    let!(:todo_list) { TodoList.create(name: 'Setup RoR project') }

    context 'with valid parameters' do
      let(:valid_params) { { id: todo_list.id, todo_list: { name: 'Updated list name' } } }

      it 'updates the record' do
        put :update, params: valid_params, format: :json

        expect(todo_list.reload.name).to eq('Updated list name')
      end

      it 'returns the updated record' do
        put :update, params: valid_params, format: :json

        updated_todo_list = JSON.parse(response.body)

        aggregate_failures 'includes the id and name' do
          expect(updated_todo_list.keys).to match_array(['id', 'name'])
          expect(updated_todo_list['id']).to eq(todo_list.id)
          expect(updated_todo_list['name']).to eq(valid_params[:todo_list][:name])
        end
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) { { id: todo_list.id, todo_list: { name: '' } } }

      it 'does not update the record' do
        put :update, params: invalid_params, format: :json

        expect(todo_list.reload.name).to eq('Setup RoR project')
      end

      it 'returns error messages' do
        put :update, params: invalid_params, format: :json

        errors = JSON.parse(response.body)

        expect(errors['name']).to include("can't be blank")
      end

      it 'returns an unprocessable entity status code' do
        put :update, params: invalid_params, format: :json

        expect(response.status).to eq(422)
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:todo_list) { TodoList.create(name: 'Setup RoR project') }

    it 'deletes the record' do
      expect {
        delete :destroy, params: { id: todo_list.id }, format: :json
      }.to change(TodoList, :count).by(-1)
    end

    it 'returns the deleted record' do
      delete :destroy, params: { id: todo_list.id }, format: :json

      deleted_todo_list = JSON.parse(response.body)

      aggregate_failures 'includes the id and name' do
        expect(deleted_todo_list.keys).to match_array(['id', 'name'])
        expect(deleted_todo_list['id']).to eq(todo_list.id)
        expect(deleted_todo_list['name']).to eq(todo_list.name)
      end
    end
  end
end
