require 'rails_helper'

describe TodoListsController do
  render_views

  before { ActiveJob::Base.queue_adapter = :test }
  after  { ActiveJob::Base.queue_adapter = :async }

  describe 'POST #complete_all' do
    let!(:todo_list) { TodoList.create!(name: 'My List') }

    context 'when there are pending items' do
      let!(:pending_items) do
        3.times.map { TodoItem.create!(name: 'Pending task', completed: false, todo_list: todo_list) }
      end
      let!(:done_item) { TodoItem.create!(name: 'Done task', completed: true, todo_list: todo_list) }

      it 'enqueues a CompleteAllItemsJob' do
        expect {
          post :complete_all, params: { id: todo_list.id }, format: :turbo_stream
        }.to have_enqueued_job(CompleteAllItemsJob).with(todo_list.id)
      end

      it 'returns a turbo_stream response' do
        post :complete_all, params: { id: todo_list.id }, format: :turbo_stream

        expect(response.media_type).to eq('text/vnd.turbo-stream.html')
      end

      it 'returns 200 OK' do
        post :complete_all, params: { id: todo_list.id }, format: :turbo_stream

        expect(response.status).to eq(200)
      end

      it 'replaces the header with completing: true' do
        post :complete_all, params: { id: todo_list.id }, format: :turbo_stream

        expect(response.body).to include("todo_list_header_#{todo_list.id}")
        expect(response.body).to include('Completing')
      end

      it 'includes an info toast with pending count' do
        post :complete_all, params: { id: todo_list.id }, format: :turbo_stream

        expect(response.body).to include('Completing 3 items in background')
      end

      it 'does not complete items synchronously' do
        post :complete_all, params: { id: todo_list.id }, format: :turbo_stream

        expect(todo_list.todo_items.where(completed: false).count).to eq(3)
      end
    end

    context 'when all items are already completed' do
      let!(:done_items) do
        2.times.map { TodoItem.create!(name: 'Done task', completed: true, todo_list: todo_list) }
      end

      it 'does not enqueue a job' do
        expect {
          post :complete_all, params: { id: todo_list.id }, format: :turbo_stream
        }.not_to have_enqueued_job(CompleteAllItemsJob)
      end

      it 'returns a turbo_stream response' do
        post :complete_all, params: { id: todo_list.id }, format: :turbo_stream

        expect(response.media_type).to eq('text/vnd.turbo-stream.html')
      end

      it 'includes an info toast saying already completed' do
        post :complete_all, params: { id: todo_list.id }, format: :turbo_stream

        expect(response.body).to include('All items already completed')
      end
    end

    context 'when the list has no items' do
      it 'does not enqueue a job' do
        expect {
          post :complete_all, params: { id: todo_list.id }, format: :turbo_stream
        }.not_to have_enqueued_job(CompleteAllItemsJob)
      end

      it 'includes an info toast saying already completed' do
        post :complete_all, params: { id: todo_list.id }, format: :turbo_stream

        expect(response.body).to include('All items already completed')
      end
    end
  end
end
