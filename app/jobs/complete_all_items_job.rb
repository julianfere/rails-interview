class CompleteAllItemsJob < ApplicationJob
  queue_as :default

  TARGET_BATCHES = 10
  MIN_BATCH_SIZE = 50
  MAX_BATCH_SIZE = 1000

  def perform(todo_list_id)
    todo_list = TodoList.find(todo_list_id)

    pending = todo_list.todo_items.where(completed: false)
    total   = pending.count
    return if total.zero?

    # Calcula un batch size dinamico, lo hice para que se note el proceso en la UI, pero sin comprometer la perfo
    batch_size = [(total / TARGET_BATCHES.to_f).ceil, MIN_BATCH_SIZE].max.clamp(MIN_BATCH_SIZE, MAX_BATCH_SIZE)

    pending.find_in_batches(batch_size: batch_size) do |batch|
      ids = batch.map(&:id)

      TodoItem.where(id: ids).update_all(completed: true, updated_at: Time.current)

      todo_list.reload
      all_items = todo_list.todo_items.order(completed: :asc, id: :asc)
      Turbo::StreamsChannel.broadcast_replace_to(
        "todo_list_#{todo_list.id}",
        target: "todo_list_items_#{todo_list.id}",
        partial: "todo_lists/todo_items_list",
        locals: { todo_list: todo_list, todo_items: all_items }
      )

      # Updatea la progress bar
      Turbo::StreamsChannel.broadcast_replace_to(
        "todo_list_#{todo_list.id}",
        target: "todo_list_header_#{todo_list.id}",
        partial: "todo_lists/todo_list_header",
        locals: { todo_list: todo_list, completing: true }
      )
    end


    todo_list.reload
    Turbo::StreamsChannel.broadcast_replace_to(
      "todo_list_#{todo_list.id}",
      target: "todo_list_header_#{todo_list.id}",
      partial: "todo_lists/todo_list_header",
      locals: { todo_list: todo_list, completing: false }
    )

    Turbo::StreamsChannel.broadcast_append_to(
      "todo_list_#{todo_list.id}",
      target: "toast_container",
      partial: "shared/toast",
      locals: { message: "All items in \"#{todo_list.name}\" completed!", type: :success }
    )
  end
end
