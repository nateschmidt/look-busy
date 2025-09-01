class UpdateExistingGoalsToActive < ActiveRecord::Migration[7.1]
  def up
    # Update all existing goals to be active
    Goal.update_all(active: true)
  end

  def down
    # Revert all goals to inactive (if needed)
    Goal.update_all(active: false)
  end
end
