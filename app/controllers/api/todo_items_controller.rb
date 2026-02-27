module Api
  class TodoItemsController < ApplicationController
    before_action :set_todo_list
    before_action :set_todo_item, only: %i[show update destroy]
    skip_forgery_protection

    ITEMS_PER_PAGE = 10

    # GET /api/todolists/:todo_list_id/todoitems
    def index
      per_page = [params.fetch(:per_page, ITEMS_PER_PAGE).to_i, 100].min
      @pagy, @todo_items = pagy(@todo_list.todo_items.order(completed: :asc, id: :asc), items: per_page)

      respond_to :json
    end

    # GET /api/todolists/:todo_list_id/todoitems/:id
    def show
      respond_to :json
    end

    # POST /api/todolists/:todo_list_id/todoitems
    def create
      @todo_item = @todo_list.todo_items.new(todo_item_params)

      if @todo_item.save
        respond_to do |format|
          format.json { render :create, status: :created }
        end
      else
        render json: @todo_item.errors, status: :unprocessable_entity
      end
    end

    # PUT /api/todolists/:todo_list_id/todoitems/:id
    def update
      if @todo_item.update(todo_item_params)
        respond_to :json
      else
        render json: @todo_item.errors, status: :unprocessable_entity
      end
    end

    # DELETE /api/todolists/:todo_list_id/todoitems/:id
    def destroy
      @todo_item.destroy

      respond_to :json
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
end
