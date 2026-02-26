class TodoListsController < ApplicationController
  before_action :set_todo_list, only: %i[show edit update destroy]

  # GET /todolists
  def index
    @todo_lists = TodoList.all

    respond_to :html
  end

  # GET /todolists/new
  def new
    @todo_list = TodoList.new

    respond_to :html
  end

  # POST /todolists
  def create
    @todo_list = TodoList.new(todo_list_params)

    if @todo_list.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append("todo_lists", partial: "todo_list", locals: { todo_list: @todo_list }),
            turbo_stream.update("new_todo_list") { link_to 'Add Todo List', new_todo_list_path }
          ]
        end
        format.html { redirect_to todo_list_path(@todo_list) }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /todolists/:id
  def show
    respond_to :html
  end

  # GET /todolists/:id/edit
  def edit
    respond_to :html
  end

  # PATCH/PUT /todolists/:id
  def update
    if @todo_list.update(todo_list_params)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(@todo_list, partial: "todo_list", locals: { todo_list: @todo_list })
        end
        format.html { redirect_to todo_list_path(@todo_list) }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /todolists/:id
  def destroy
    @todo_list.destroy

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove(@todo_list)
      end
      format.html { redirect_to todo_lists_path }
    end
  end

  private

  def set_todo_list
    @todo_list = TodoList.find(params[:id])
  end

  def todo_list_params
    params.require(:todo_list).permit(:name)
  end
end
