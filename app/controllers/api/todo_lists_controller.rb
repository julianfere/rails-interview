module Api
  class TodoListsController < ApplicationController
    before_action :set_todo_list, only: %i[show update destroy]
    skip_forgery_protection

    # GET /api/todolists
    def index
      per_page = [params.fetch(:per_page, Pagination::LISTS_PER_PAGE).to_i, 100].min
      @pagy, @todo_lists = pagy(TodoList.order(:id), items: per_page)

      respond_to :json
    end

    # GET /api/todolists/:id
    def show
      respond_to :json
    end

    # POST /api/todolists
    def create
      @todo_list = TodoList.new(todo_list_params)

      if @todo_list.save
        respond_to do |format|
          format.json { render :create, status: :created }
        end
      else
        render json: @todo_list.errors, status: :unprocessable_entity
      end
    end

    # PUT /api/todolists/:id
    def update
      if @todo_list.update(todo_list_params)
        respond_to :json
      else
        render json: @todo_list.errors, status: :unprocessable_entity
      end
    end

    # DELETE /api/todolists/:id
    def destroy
      @todo_list.destroy

      respond_to :json
    end

    private

    def set_todo_list
      @todo_list = TodoList.find(params[:id])
    end

    def todo_list_params
      params.require(:todo_list).permit(:name)
    end
  end
end
