require 'rails_helper'

describe CompleteAllItemsJob do
  let!(:todo_list) { TodoList.create!(name: 'My List') }

  describe '#perform' do
    context 'when all items are pending' do
      let!(:items) do
        5.times.map { TodoItem.create!(name: 'Task', completed: false, todo_list: todo_list) }
      end

      it 'marks every item as completed' do
        described_class.new.perform(todo_list.id)

        expect(todo_list.todo_items.where(completed: false).count).to eq(0)
      end

      it 'sets completed: true for all items' do
        described_class.new.perform(todo_list.id)

        expect(todo_list.todo_items.pluck(:completed).uniq).to eq([true])
      end
    end

    context 'when some items are already completed' do
      let!(:pending_items) do
        3.times.map { TodoItem.create!(name: 'Pending', completed: false, todo_list: todo_list) }
      end
      let!(:done_items) do
        2.times.map { TodoItem.create!(name: 'Done', completed: true, todo_list: todo_list) }
      end

      it 'completes only the pending items' do
        described_class.new.perform(todo_list.id)

        expect(todo_list.todo_items.where(completed: false).count).to eq(0)
        expect(todo_list.todo_items.where(completed: true).count).to eq(5)
      end

      it 'does not touch already-completed items updated_at' do
        original_timestamps = done_items.map { |i| i.reload.updated_at }

        # freeze time so any touch would be identical — we verify by count, not timestamp
        expect {
          described_class.new.perform(todo_list.id)
        }.not_to change { done_items.map { |i| i.reload.updated_at } }
      end
    end

    context 'when the list has no pending items' do
      let!(:done_items) do
        3.times.map { TodoItem.create!(name: 'Done', completed: true, todo_list: todo_list) }
      end

      it 'does nothing and does not raise' do
        expect { described_class.new.perform(todo_list.id) }.not_to raise_error
      end

      it 'leaves all items completed' do
        described_class.new.perform(todo_list.id)

        expect(todo_list.todo_items.where(completed: false).count).to eq(0)
      end
    end

    context 'when the list has no items at all' do
      it 'does not raise' do
        expect { described_class.new.perform(todo_list.id) }.not_to raise_error
      end
    end

    context 'with more items than MIN_BATCH_SIZE' do
      before { stub_const('CompleteAllItemsJob::MIN_BATCH_SIZE', 3) }

      let!(:items) do
        7.times.map { TodoItem.create!(name: 'Task', completed: false, todo_list: todo_list) }
      end

      it 'completes all items across multiple batches' do
        described_class.new.perform(todo_list.id)

        expect(todo_list.todo_items.where(completed: false).count).to eq(0)
      end

      it 'uses batch SQL (update_all) instead of per-record saves' do
        call_count = 0
        allow(TodoItem).to receive(:where).and_wrap_original do |original, *args|
          relation = original.call(*args)
          allow(relation).to receive(:update_all).and_wrap_original do |orig_update, *uargs|
            call_count += 1
            orig_update.call(*uargs)
          end
          relation
        end

        described_class.new.perform(todo_list.id)

        # 7 items with MIN_BATCH_SIZE 3: dynamic batch_size = ceil(7/5) = 2, clamped to min 3
        # → 3 batches → 3 update_all calls, not 7
        expect(call_count).to eq(3)
      end
    end

    context 'broadcasts' do
      let!(:items) do
        2.times.map { TodoItem.create!(name: 'Task', completed: false, todo_list: todo_list) }
      end

      it 'broadcasts a replace for the items container' do
        broadcast_targets = []
        allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to) do |stream, **opts|
          broadcast_targets << opts[:target]
        end

        described_class.new.perform(todo_list.id)

        expect(broadcast_targets).to include("todo_list_items_#{todo_list.id}")
      end

      it 'broadcasts a final header replace with completing: false' do
        final_broadcast = nil
        allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to) do |stream, **opts|
          final_broadcast = opts if opts[:target] == "todo_list_header_#{todo_list.id}"
        end

        described_class.new.perform(todo_list.id)

        expect(final_broadcast[:locals][:completing]).to eq(false)
      end

      it 'broadcasts a success toast at the end' do
        toast_appended = false
        allow(Turbo::StreamsChannel).to receive(:broadcast_append_to) do |stream, **opts|
          toast_appended = true if opts[:target] == 'toast_container'
        end

        described_class.new.perform(todo_list.id)

        expect(toast_appended).to be(true)
      end
    end
  end
end
