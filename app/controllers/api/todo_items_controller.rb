module Api
  class TodoItemsController < ApplicationController
    before_action :set_todo_list
    before_action :set_todo_item, only: %i[show update destroy]
    skip_forgery_protection

    # GET /api/todolists/:todo_list_id/todoitems
    def index
      @todo_items = @todo_list.todo_items

      respond_to do |format|
        format.json { render json: @todo_items.map(&:to_json) }
      end
    end

    # GET /api/todolists/:todo_list_id/todoitems/:id
    def show
      render json: @todo_item.to_json
    end

    # POST /api/todolists/:todo_list_id/todoitems
    def create
      @todo_item = @todo_list.todo_items.new(todo_item_params)

      if @todo_item.save
        render json: @todo_item.to_json, status: :created
      else
        render json: @todo_item.errors, status: :unprocessable_entity
      end
    end

    # PUT /api/todolists/:todo_list_id/todoitems/:id
    def update
      if @todo_item.update(todo_item_params)
        render json: @todo_item.to_json
      else
        render json: @todo_item.errors, status: :unprocessable_entity
      end
    end

    # DELETE /api/todolists/:todo_list_id/todoitems/:id
    def destroy
      @todo_item.destroy

      render json: @todo_item.to_json
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
