class CreateRecurringMeetings < ActiveRecord::Migration[7.1]
  def change
    create_table :recurring_meetings do |t|
      t.string :name, null: false
      t.string :person, null: false
      t.integer :frequency, null: false, default: 0
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :recurring_meetings, [:user_id, :name], unique: true
  end
end
