class AddWeekStartDateToTodoItems < ActiveRecord::Migration[7.1]
  def change
    add_column :todo_items, :week_start_date, :date
    
    # Set default values for existing records
    TodoItem.update_all(week_start_date: Date.current.beginning_of_week)
    
    # Make the column not null after setting defaults
    change_column_null :todo_items, :week_start_date, false
  end
end
