class RecurringMeeting < ApplicationRecord
  belongs_to :user
  
  enum frequency: {
    weekly: 0,
    bi_weekly: 1,
    monthly: 2,
    quarterly: 3
  }
  
  enum biweekly_pattern: {
    first_third: 'first_third',
    second_fourth: 'second_fourth'
  }
  
  validates :name, presence: true, length: { maximum: 255 }
  validates :person, presence: true, length: { maximum: 255 }
  validates :frequency, presence: true, inclusion: { in: frequencies.keys }
  validates :name, uniqueness: { scope: :user_id }
  validates :week_of_month, inclusion: { in: 1..4 }, allow_nil: true
  validates :month_of_quarter, inclusion: { in: 1..3 }, allow_nil: true
  validates :biweekly_pattern, inclusion: { in: biweekly_patterns.keys }, allow_nil: true
  
  scope :ordered, -> { order(:name) }
  
  has_many :todo_items, as: :source, dependent: :destroy
  
  def frequency_display
    case frequency
    when 'weekly'
      'Weekly'
    when 'bi_weekly'
      "Bi-weekly (#{biweekly_pattern_display})"
    when 'monthly'
      "Monthly (Week #{week_of_month})"
    when 'quarterly'
      "Quarterly (Month #{month_of_quarter}, Week #{week_of_month})"
    end
  end
  
  def biweekly_pattern_display
    case biweekly_pattern
    when 'first_third'
      '1st & 3rd weeks'
    when 'second_fourth'
      '2nd & 4th weeks'
    end
  end
  
  def next_meeting_date
    case frequency
    when 'weekly'
      next_weekly_meeting
    when 'bi_weekly'
      next_biweekly_meeting
    when 'monthly'
      next_monthly_meeting
    when 'quarterly'
      next_quarterly_meeting
    end
  end
  
  def is_meeting_this_week?
    current_week = Date.current.cweek
    current_month = Date.current.month
    current_year = Date.current.year
    
    case frequency
    when 'weekly'
      true
    when 'bi_weekly'
      week_in_month = ((Date.current.day - 1) / 7) + 1
      case biweekly_pattern
      when 'first_third'
        [1, 3].include?(week_in_month)
      when 'second_fourth'
        [2, 4].include?(week_in_month)
      end
    when 'monthly'
      week_in_month = ((Date.current.day - 1) / 7) + 1
      week_in_month == week_of_month
    when 'quarterly'
      quarter_month = ((current_month - 1) % 3) + 1
      week_in_month = ((Date.current.day - 1) / 7) + 1
      quarter_month == month_of_quarter && week_in_month == week_of_month
    end
  end
  
  private
  
  def next_weekly_meeting
    Date.current + 1.week
  end
  
  def next_biweekly_meeting
    week_in_month = ((Date.current.day - 1) / 7) + 1
    
    case biweekly_pattern
    when 'first_third'
      if [1, 3].include?(week_in_month)
        Date.current + 2.weeks
      else
        # Find next occurrence
        next_week = Date.current + 1.week
        next_week_in_month = ((next_week.day - 1) / 7) + 1
        if [1, 3].include?(next_week_in_month)
          next_week
        else
          next_week + 1.week
        end
      end
    when 'second_fourth'
      if [2, 4].include?(week_in_month)
        Date.current + 2.weeks
      else
        # Find next occurrence
        next_week = Date.current + 1.week
        next_week_in_month = ((next_week.day - 1) / 7) + 1
        if [2, 4].include?(next_week_in_month)
          next_week
        else
          next_week + 1.week
        end
      end
    end
  end
  
  def next_monthly_meeting
    current_week = ((Date.current.day - 1) / 7) + 1
    
    if current_week == week_of_month
      Date.current + 1.month
    else
      # Find next occurrence this month or next month
      days_until_this_month = (week_of_month - current_week) * 7
      if days_until_this_month > 0
        Date.current + days_until_this_month.days
      else
        # Next month
        next_month = Date.current + 1.month
        next_month.beginning_of_month + (week_of_month - 1) * 7.days
      end
    end
  end
  
  def next_quarterly_meeting
    current_month = Date.current.month
    current_week = ((Date.current.day - 1) / 7) + 1
    quarter_month = ((current_month - 1) % 3) + 1
    
    if quarter_month == month_of_quarter && current_week == week_of_month
      Date.current + 3.months
    else
      # Find next occurrence
      if quarter_month < month_of_quarter
        # This quarter
        target_month = Date.current.beginning_of_month + (month_of_quarter - quarter_month).months
      else
        # Next quarter
        target_month = Date.current.beginning_of_month + (3 - quarter_month + month_of_quarter).months
      end
      
      target_month + (week_of_month - 1) * 7.days
    end
  end
end
