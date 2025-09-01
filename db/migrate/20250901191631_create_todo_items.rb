class CreateTodoItems < ActiveRecord::Migration[7.1]
  def change
    create_table :todo_items do |t|
      t.text :description, null: false
      t.references :user, null: false, foreign_key: true
      t.string :source_type, null: false
      t.integer :source_id, null: false
      t.boolean :completed, default: false, null: false

      t.timestamps
    end
  end
end
