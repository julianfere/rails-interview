class TodoItem < ApplicationRecord
  belongs_to :todo_list

  validates :name, presence: true

  def to_json(_options = {})
    {
      id: id,
      name: name,
      completed: completed,
      todo_list_id: todo_list_id
    }
  end
end
