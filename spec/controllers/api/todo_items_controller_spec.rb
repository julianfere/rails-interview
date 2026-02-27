require 'rails_helper'

describe Api::TodoItemsController do
  render_views

  describe 'GET index' do
    let!(:todo_list) { TodoList.create(name: 'Setup RoR project') }
    let!(:todo_item) { TodoItem.create(name: 'Create a new RoR project', todo_list: todo_list) }

    context 'when format is HTML' do
      it 'raises a routing error' do
        expect {
          get :index, params: { todo_list_id: todo_list.id }
        }.to raise_error(ActionController::RoutingError, 'Not supported format')
      end
    end

    context 'when format is JSON' do
      it 'returns a success code' do
        get :index, params: { todo_list_id: todo_list.id }, format: :json

        expect(response.status).to eq(200)
      end

      it 'includes todo item records in the data key' do
        get :index, params: { todo_list_id: todo_list.id }, format: :json

        body = JSON.parse(response.body)
        todo_items = body['data']

        aggregate_failures 'includes the id, name, completed and todo_list_id' do
          expect(todo_items.count).to eq(1)
          expect(todo_items[0].keys).to match_array(['id', 'name', 'completed', 'todo_list_id'])
          expect(todo_items[0]['id']).to eq(todo_item.id)
          expect(todo_items[0]['name']).to eq(todo_item.name)
          expect(todo_items[0]['completed']).to eq(todo_item.completed)
          expect(todo_items[0]['todo_list_id']).to eq(todo_item.todo_list_id)
        end
      end

      it 'includes pagination metadata' do
        get :index, params: { todo_list_id: todo_list.id }, format: :json

        pagination = JSON.parse(response.body)['pagination']

        aggregate_failures 'includes pagination keys' do
          expect(pagination.keys).to match_array(['current_page', 'total_pages', 'total_count', 'per_page'])
          expect(pagination['current_page']).to eq(1)
          expect(pagination['total_count']).to eq(1)
        end
      end

      context 'when there are more than 10 records' do
        before { 10.times { |i| TodoItem.create(name: "Item #{i}", todo_list: todo_list) } }

        it 'paginates to 10 per page by default' do
          get :index, params: { todo_list_id: todo_list.id }, format: :json

          body = JSON.parse(response.body)

          expect(body['data'].count).to eq(10)
          expect(body['pagination']['total_pages']).to eq(2)
        end

        it 'returns page 2 with ?page=2' do
          get :index, params: { todo_list_id: todo_list.id, page: 2 }, format: :json

          body = JSON.parse(response.body)

          expect(body['data'].count).to eq(1)
          expect(body['pagination']['current_page']).to eq(2)
        end

        it 'respects custom per_page param' do
          get :index, params: { todo_list_id: todo_list.id, per_page: 5 }, format: :json

          body = JSON.parse(response.body)

          expect(body['data'].count).to eq(5)
          expect(body['pagination']['total_pages']).to eq(3)
        end

        it 'caps per_page at 100' do
          get :index, params: { todo_list_id: todo_list.id, per_page: 999 }, format: :json

          expect(JSON.parse(response.body)['pagination']['per_page']).to eq(100)
        end
      end
    end
  end

  describe 'GET show' do
    let!(:todo_list) { TodoList.create(name: 'Setup RoR project') }
    let!(:todo_item) { TodoItem.create(name: 'Create a new RoR project', todo_list: todo_list) }

    it 'returns a success code' do
      get :show, params: { todo_list_id: todo_list.id, id: todo_item.id }, format: :json

      expect(response.status).to eq(200)
    end

    it 'returns the requested record' do
      get :show, params: { todo_list_id: todo_list.id, id: todo_item.id }, format: :json

      returned_todo_item = JSON.parse(response.body)

      aggregate_failures 'includes the id, name, completed and todo_list_id' do
        expect(returned_todo_item.keys).to match_array(['id', 'name', 'completed', 'todo_list_id'])
        expect(returned_todo_item['id']).to eq(todo_item.id)
        expect(returned_todo_item['name']).to eq(todo_item.name)
        expect(returned_todo_item['completed']).to eq(todo_item.completed)
        expect(returned_todo_item['todo_list_id']).to eq(todo_item.todo_list_id)
      end
    end
  end

  describe 'POST create' do
    let!(:todo_list) { TodoList.create(name: 'Setup RoR project') }

    context 'with valid parameters' do
      let(:valid_params) do
        {
          todo_list_id: todo_list.id,
          todo_item: {
            name: 'Create a new RoR project',
            completed: false
          }
        }
      end

      it 'creates a new record' do
        expect {
          post :create, params: valid_params, format: :json
        }.to change(TodoItem, :count).by(1)
      end

      it 'returns the created record' do
        post :create, params: valid_params, format: :json

        created_todo_item = JSON.parse(response.body)

        aggregate_failures 'includes the id, name, completed and todo_list_id' do
          expect(created_todo_item.keys).to match_array(['id', 'name', 'completed', 'todo_list_id'])
          expect(created_todo_item['name']).to eq(valid_params[:todo_item][:name])
          expect(created_todo_item['completed']).to eq(valid_params[:todo_item][:completed])
          expect(created_todo_item['todo_list_id']).to eq(todo_list.id)
        end
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          todo_list_id: todo_list.id,
          todo_item: {
            name: '',
            completed: false
          }
        }
      end

      it 'does not create a new record' do
        expect {
          post :create, params: invalid_params, format: :json
        }.not_to change(TodoItem, :count)
      end

      it 'returns error messages' do
        post :create, params: invalid_params, format: :json

        errors = JSON.parse(response.body)

        expect(errors.keys).to match_array(['name'])
        expect(errors['name']).to include("can't be blank")
      end
    end
  end

  describe 'PUT update' do
    let!(:todo_list) { TodoList.create(name: 'Setup RoR project') }
    let!(:todo_item) { TodoItem.create(name: 'Create a new RoR project', todo_list: todo_list) }

    context 'with valid parameters' do
      let(:valid_params) do
        {
          todo_list_id: todo_list.id,
          id: todo_item.id,
          todo_item: {
            name: 'Create a new RoR project',
            completed: true
          }
        }
      end

      it 'updates the record' do
        put :update, params: valid_params, format: :json

        expect(todo_item.reload.completed).to eq(true)
      end

      it 'returns the updated record' do
        put :update, params: valid_params, format: :json

        updated_todo_item = JSON.parse(response.body)

        aggregate_failures 'includes the id, name, completed and todo_list_id' do
          expect(updated_todo_item.keys).to match_array(['id', 'name', 'completed', 'todo_list_id'])
          expect(updated_todo_item['id']).to eq(todo_item.id)
          expect(updated_todo_item['name']).to eq(valid_params[:todo_item][:name])
          expect(updated_todo_item['completed']).to eq(valid_params[:todo_item][:completed])
          expect(updated_todo_item['todo_list_id']).to eq(todo_list.id)
        end
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          todo_list_id: todo_list.id,
          id: todo_item.id,
          todo_item: {
            name: '',
            completed: true
          }
        }
      end

      it 'does not update the record' do
        put :update, params: invalid_params, format: :json

        expect(todo_item.reload.name).not_to eq('')
      end

      it 'returns error messages' do
        put :update, params: invalid_params, format: :json

        errors = JSON.parse(response.body)

        expect(errors.keys).to match_array(['name'])
        expect(errors['name']).to include("can't be blank")
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:todo_list) { TodoList.create(name: 'Setup RoR project') }
    let!(:todo_item) { TodoItem.create(name: 'Create a new RoR project', todo_list: todo_list) }

    it 'deletes the record' do
      expect {
        delete :destroy, params: { todo_list_id: todo_list.id, id: todo_item.id }, format: :json
      }.to change(TodoItem, :count).by(-1)
    end

    it 'returns the deleted record' do
      delete :destroy, params: { todo_list_id: todo_list.id, id: todo_item.id }, format: :json

      deleted_todo_item = JSON.parse(response.body)

      aggregate_failures 'includes the id, name, completed and todo_list_id' do
        expect(deleted_todo_item.keys).to match_array(['id', 'name', 'completed', 'todo_list_id'])
        expect(deleted_todo_item['id']).to eq(todo_item.id)
        expect(deleted_todo_item['name']).to eq(todo_item.name)
        expect(deleted_todo_item['completed']).to eq(todo_item.completed)
        expect(deleted_todo_item['todo_list_id']).to eq(todo_item.todo_list_id)
      end
    end
  end
end
