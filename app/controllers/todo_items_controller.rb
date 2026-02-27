class TodoItemsController < ApplicationController
  before_action :set_todo_list
  before_action :set_todo_item, only: %i[edit update destroy]

  def new
    @todo_item = @todo_list.todo_items.new
  end

  def edit
    respond_to :html
  end

  def create
    @todo_item = @todo_list.todo_items.new(todo_item_params)

    if @todo_item.save
      @todo_list = TodoList.includes(:todo_items).find(@todo_list.id)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append("todo_items_#{@todo_list.id}", partial: "todo_items/todo_item", locals: { todo_item: @todo_item }),
            turbo_stream.update("new_todo_item_#{@todo_list.id}") do
              helpers.link_to t("todo_items.add_item"), helpers.new_todo_list_todo_item_path(@todo_list), class: "add-item-trigger"
            end,
            turbo_stream.replace("todo_list_header_#{@todo_list.id}", partial: "todo_lists/todo_list_header", locals: { todo_list: @todo_list }),
            toast_stream(t("todo_items.created", name: @todo_item.name))
          ]
        end
        format.html { redirect_to todo_list_path(@todo_list) }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @todo_item.update(todo_item_params)
      @todo_list = TodoList.includes(:todo_items).find(@todo_list.id)
      respond_to do |format|
        format.turbo_stream do
          completed_changed = @todo_item.saved_change_to_completed?
          message = if completed_changed
            @todo_item.completed? ? t("todo_items.completed", name: @todo_item.name) : t("todo_items.marked_pending", name: @todo_item.name)
          else
            t("todo_items.updated", name: @todo_item.name)
          end
          render turbo_stream: [
            turbo_stream.replace(@todo_item, partial: "todo_items/todo_item", locals: { todo_item: @todo_item }),
            turbo_stream.replace("todo_list_header_#{@todo_list.id}", partial: "todo_lists/todo_list_header", locals: { todo_list: @todo_list }),
            toast_stream(message)
          ]
        end
        format.html { redirect_to todo_list_path(@todo_list) }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @todo_item.destroy
    @todo_list = TodoList.includes(:todo_items).find(@todo_list.id)

    respond_to do |format|
      format.turbo_stream do
        item_name = @todo_item.name
        render turbo_stream: [
          turbo_stream.remove(@todo_item),
          turbo_stream.replace("todo_list_header_#{@todo_list.id}", partial: "todo_lists/todo_list_header", locals: { todo_list: @todo_list }),
          toast_stream(t("todo_items.destroyed", name: item_name))
        ]
      end
      format.html { redirect_to todo_list_path(@todo_list) }
    end
  end

  private

  def set_todo_list
    @todo_list = TodoList.find(params[:todo_list_id])
  end

  def set_todo_item
    @todo_item = @todo_list.todo_items.find(params[:id])
  end

  def todo_item_params
    params.require(:todo_item).permit(:name, :completed)
  end
end
