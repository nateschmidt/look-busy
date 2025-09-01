class CreateGoals < ActiveRecord::Migration[7.1]
  def change
    create_table :goals do |t|
      t.string :description, null: false
      t.integer :target_count, null: false, default: 1
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :goals, [:user_id, :description], unique: true
  end
end
