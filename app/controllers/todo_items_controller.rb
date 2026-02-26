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
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append("todo_items", partial: "todo_items/todo_item", locals: { todo_item: @todo_item }),
            turbo_stream.update("new_todo_item") { "" }
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
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(@todo_item, partial: "todo_items/todo_item", locals: { todo_item: @todo_item })
        end
        format.html { redirect_to todo_list_path(@todo_list) }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @todo_item.destroy

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove(@todo_item)
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
