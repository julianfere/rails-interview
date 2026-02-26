require 'rails_helper'

describe Api::TodoItemsController do
  render_views

  describe 'GET index' do
    let!(:todo_list) { TodoList.create(name: 'Setup RoR project') }
    let!(:todo_item) { TodoItem.create(name: 'Create a new RoR project', todo_list: todo_list) }

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

      it 'includes todo item records' do
        get :index, format: :json

        todo_items = JSON.parse(response.body)

        aggregate_failures 'includes the id, name, completed and todo_list_id' do
          expect(todo_items.count).to eq(1)
          expect(todo_items[0].keys).to match_array(['id', 'name', 'completed', 'todo_list_id'])
          expect(todo_items[0]['id']).to eq(todo_item.id)
          expect(todo_items[0]['name']).to eq(todo_item.name)
          expect(todo_items[0]['completed']).to eq(todo_item.completed)
          expect(todo_items[0]['todo_list_id']).to eq(todo_item.todo_list_id)
        end
      end
    end
  end

  describe 'GET show' do
    let!(:todo_list) { TodoList.create(name: 'Setup RoR project') }
    let!(:todo_item) { TodoItem.create(name: 'Create a new RoR project', todo_list: todo_list) }

    it 'returns a success code' do
      get :show, params: { id: todo_item.id }, format: :json

      expect(response.status).to eq(200)
    end

    it 'returns the requested record' do
      get :show, params: { id: todo_item.id }, format: :json

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
          todo_item: {
            name: 'Create a new RoR project',
            completed: false,
            todo_list_id: todo_list.id
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
          expect(created_todo_item['todo_list_id']).to eq(valid_params[:todo_item][:todo_list_id])
        end
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          todo_item: {
            name: '',
            completed: false,
            todo_list_id: todo_list.id
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
          id: todo_item.id,
          todo_item: {
            name: 'Create a new RoR project',
            completed: true,
            todo_list_id: todo_list.id
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
          expect(updated_todo_item['todo_list_id']).to eq(valid_params[:todo_item][:todo_list_id])
        end
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          id: todo_item.id,
          todo_item: {
            name: '',
            completed: true,
            todo_list_id: todo_list.id
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
        delete :destroy, params: { id: todo_item.id }, format: :json
      }.to change(TodoItem, :count).by(-1)
    end

    it 'returns the deleted record' do
      delete :destroy, params: { id: todo_item.id }, format: :json

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
