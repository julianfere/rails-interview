class TodoListsController < ApplicationController
  before_action :set_todo_list, only: %i[show edit update destroy]

  LISTS_PER_PAGE = 10

  # GET /todolists
  def index
    @pagy, @todo_lists = pagy(TodoList.includes(:todo_items).order(:id), items: LISTS_PER_PAGE)

    respond_to :html
  end

  # GET /todolists/more
  def more
    @pagy, @todo_lists = pagy(TodoList.includes(:todo_items).order(:id), items: LISTS_PER_PAGE)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.append("todo_lists",
            partial: "todo_lists/todo_list_collection",
            locals: { todo_lists: @todo_lists }),
          turbo_stream.replace("load_more_lists",
            partial: "todo_lists/load_more_lists",
            locals: { pagy: @pagy })
        ]
      end
    end
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
          @pagy, _lists = pagy(TodoList.order(:id), items: LISTS_PER_PAGE)
          render turbo_stream: [
            turbo_stream.append("todo_lists", partial: "todo_list", locals: { todo_list: @todo_list }),
            turbo_stream.update("new_todo_list", partial: "todo_lists/new_list_trigger"),
            turbo_stream.replace("load_more_lists",
              partial: "todo_lists/load_more_lists",
              locals: { pagy: @pagy }),
            toast_stream("List \"#{@todo_list.name}\" created")
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
    @pagy, @todo_items = pagy(@todo_list.todo_items.order(:id), items: 10)

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
          render turbo_stream: [
            turbo_stream.replace(@todo_list, partial: "todo_list", locals: { todo_list: @todo_list }),
            toast_stream("List \"#{@todo_list.name}\" updated")
          ]
        end
        format.html { redirect_to todo_list_path(@todo_list) }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /todolists/:id
  def destroy
    name = @todo_list.name
    @todo_list.destroy

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove(@todo_list),
          toast_stream("List \"#{name}\" deleted", type: :error)
        ]
      end
      format.html { redirect_to todo_lists_path }
    end
  end

  private

  def set_todo_list
    @todo_list = TodoList.includes(:todo_items).find(params[:id])
  end

  def todo_list_params
    params.require(:todo_list).permit(:name)
  end
end
