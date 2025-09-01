class Goal < ApplicationRecord
  belongs_to :user
  has_many :todo_items, as: :source, dependent: :destroy
  has_many :goal_completions, dependent: :destroy
  
  validates :description, presence: true
  validates :target_count, presence: true, numericality: { greater_than: 0 }
  
  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:created_at) }
  
  def total_completions
    goal_completions.sum(:completed_count)
  end
  
  def average_completions_per_week
    return 0 if goal_completions.empty?
    (total_completions.to_f / goal_completions.count).round(1)
  end
  
  def weeks_with_completions
    goal_completions.count
  end
  
  def target_met_weeks
    goal_completions.count(&:target_met?)
  end
  
  def target_met_percentage
    return 0 if weeks_with_completions.zero?
    ((target_met_weeks.to_f / weeks_with_completions) * 100).round(1)
  end
  
  def best_week
    goal_completions.order(:completed_count).last
  end
  
  def worst_week
    goal_completions.order(:completed_count).first
  end
  
  def current_streak
    streak = 0
    goal_completions.ordered.reverse.each do |completion|
      if completion.target_met?
        streak += 1
      else
        break
      end
    end
    streak
  end
  
  def longest_streak
    max_streak = 0
    current_streak = 0
    
    goal_completions.ordered.each do |completion|
      if completion.target_met?
        current_streak += 1
        max_streak = [max_streak, current_streak].max
      else
        current_streak = 0
      end
    end
    
    max_streak
  end
  
  def recent_progress(weeks = 12)
    goal_completions.recent.limit(weeks)
  end
  
  def completion_for_week(week_start_date)
    GoalCompletion.find_or_create_for_goal_and_week(self, week_start_date)
  end
end
