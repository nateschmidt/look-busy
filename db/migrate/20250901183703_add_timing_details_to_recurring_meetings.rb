class AddTimingDetailsToRecurringMeetings < ActiveRecord::Migration[7.1]
  def change
    add_column :recurring_meetings, :week_of_month, :integer, default: 1
    add_column :recurring_meetings, :month_of_quarter, :integer, default: 1
    add_column :recurring_meetings, :biweekly_pattern, :string, default: 'first_third'
  end
end
