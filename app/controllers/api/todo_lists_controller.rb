module Api
  class TodoListsController < ApplicationController
    before_action :set_todo_list, only: %i[show update destroy]
    skip_forgery_protection

    LISTS_PER_PAGE = 10

    # GET /api/todolists
    def index
      per_page = [params.fetch(:per_page, LISTS_PER_PAGE).to_i, 100].min
      @pagy, @todo_lists = pagy(TodoList.order(:id), items: per_page)

      respond_to :json
    end

    # GET /api/todolists/:id
    def show
      render json: todo_list_json(@todo_list)
    end

    # POST /api/todolists
    def create
      @todo_list = TodoList.new(todo_list_params)

      if @todo_list.save
        render json: todo_list_json(@todo_list), status: :created
      else
        render json: @todo_list.errors, status: :unprocessable_entity
      end
    end

    # PUT /api/todolists/:id
    def update
      if @todo_list.update(todo_list_params)
        render json: todo_list_json(@todo_list)
      else
        render json: @todo_list.errors, status: :unprocessable_entity
      end
    end

    # DELETE /api/todolists/:id
    def destroy
      @todo_list.destroy

      render json: todo_list_json(@todo_list)
    end

    private

    def set_todo_list
      @todo_list = TodoList.find(params[:id])
    end

    def todo_list_params
      params.require(:todo_list).permit(:name)
    end

    def todo_list_json(todo_list)
      { id: todo_list.id, name: todo_list.name }
    end
  end
end
