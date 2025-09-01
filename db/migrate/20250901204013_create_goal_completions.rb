class CreateGoalCompletions < ActiveRecord::Migration[7.1]
  def change
    create_table :goal_completions do |t|
      t.references :goal, null: false, foreign_key: true
      t.date :week_start_date
      t.integer :completed_count
      t.integer :week_number
      t.integer :year

      t.timestamps
    end
  end
end
