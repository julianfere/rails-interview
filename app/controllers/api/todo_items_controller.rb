module Api
  class TodoItemsController < ApplicationController
    before_action :set_todo_item, only: %i[show update destroy]
    skip_forgery_protection

    # GET /api/todoitems
    def index
      @todo_items = TodoItem.all

      respond_to do |format|
        format.json { render json: @todo_items.map(&:to_json) }
      end
    end

    def show
      render json: @todo_item.to_json
    end

    def create
      @todo_item = TodoItem.new(todo_item_params)

      if @todo_item.save
        render json: @todo_item.to_json, status: :created
      else
        render json: @todo_item.errors, status: :unprocessable_entity
      end
    end

    def update
      if @todo_item.update(todo_item_params)
        render json: @todo_item.to_json
      else
        render json: @todo_item.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @todo_item.destroy

      render json: @todo_item.to_json
    end

    private

    def todo_item_params
      params.require(:todo_item).permit(:name, :completed, :todo_list_id)
    end

    def set_todo_item
      @todo_item = TodoItem.find(params[:id])
    end
  end
end
