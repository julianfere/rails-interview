json.data @todo_items do |todo_item|
  json.extract! todo_item, :id, :name, :completed, :todo_list_id
end
json.pagination do
  json.current_page @pagy.page
  json.total_pages  @pagy.pages
  json.total_count  @pagy.count
  json.per_page     @pagy.items
end
