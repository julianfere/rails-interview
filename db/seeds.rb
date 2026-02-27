TodoList.create(name: 'Setup Rails Application')
TodoList.create(name: 'Setup Docker PG database')
TodoList.create(name: 'Create todo_lists table')
TodoList.create(name: 'Create TodoList model')
TodoList.create(name: 'Create TodoList controller')

[
  { name: "Q1 2026 Engineering Backlog", count: 2_500 },
  { name: "Migration Checklist — Monolith to Microservices", count: 1_800 }
].each do |config|
  list = TodoList.create!(name: config[:name])

  items = config[:count].times.map do
    now = Time.current
    {
      name: Faker::Hacker.say_something_smart,
      completed: false,
      todo_list_id: list.id,
      created_at: now,
      updated_at: now
    }
  end

  TodoItem.insert_all(items)
end
