class AddActiveToGoals < ActiveRecord::Migration[7.1]
  def change
    add_column :goals, :active, :boolean, default: true, null: false
  end
end
