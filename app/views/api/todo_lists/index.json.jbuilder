json.data @todo_lists, :id, :name
json.pagination do
  json.current_page  @pagy.page
  json.total_pages   @pagy.pages
  json.total_count   @pagy.count
  json.per_page      @pagy.items
end
