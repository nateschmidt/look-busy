class CreateAdHocTodos < ActiveRecord::Migration[7.1]
  def change
    create_table :ad_hoc_todos do |t|
      t.text :description, null: false
      t.references :user, null: false, foreign_key: true
      t.boolean :completed, default: false, null: false

      t.timestamps
    end
  end
end
