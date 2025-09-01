class GoalCompletion < ApplicationRecord
  belongs_to :goal
  
  validates :week_start_date, presence: true
  validates :completed_count, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :week_number, presence: true, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 53 }
  validates :year, presence: true, numericality: { greater_than_or_equal_to: 2020 }
  validates :goal_id, uniqueness: { scope: [:week_number, :year] }
  
  scope :ordered, -> { order(:year, :week_number) }
  scope :recent, -> { ordered.limit(12) } # Last 12 weeks
  
  def self.find_or_create_for_goal_and_week(goal, week_start_date)
    week_number = week_start_date.cweek
    year = week_start_date.year
    
    find_or_create_by(goal: goal, week_number: week_number, year: year) do |completion|
      completion.week_start_date = week_start_date
      completion.completed_count = 0
    end
  end
  
  def target_met?
    completed_count >= goal.target_count
  end
  
  def target_percentage
    return 0 if goal.target_count.zero?
    ((completed_count.to_f / goal.target_count) * 100).round(1)
  end
  
  def over_performance?
    completed_count > goal.target_count
  end
  
  def under_performance?
    completed_count < goal.target_count
  end
end
