class DashboardController < ApplicationController
  before_action :authenticate_user!

  def home
  end

  def weekly
    @selected_year = params[:year]&.to_i || Date.current.year
    @selected_week = params[:week]&.to_i || Date.current.cweek
    
    # Calculate the start and end of the selected week
    @current_week_start = Date.commercial(@selected_year, @selected_week, 1)
    @current_week_end = Date.commercial(@selected_year, @selected_week, 7)
    
    # Get all todo items for the selected week
    @todo_items = current_user.todo_items
                              .where(week_start_date: @current_week_start)
                              .includes(:notes)
                              .order(:created_at)
    
    # Check if todos have been generated for this week
    @todos_generated = @todo_items.any?
  end

  def generate_weekly_todos
    year = params[:year].to_i
    week = params[:week].to_i
    week_start_date = Date.commercial(year, week, 1)
    
    todos_created = generate_weekly_todos_for_date(week_start_date)
    
    redirect_to weekly_dashboard_path(year: year, week: week)
  end

  def clear_todos
    year = params[:year].to_i
    week = params[:week].to_i
    week_start_date = Date.commercial(year, week, 1)
    
    current_user.todo_items.where(week_start_date: week_start_date).destroy_all
    
    redirect_to weekly_dashboard_path(year: year, week: week)
  end

  def weekly_report
    @selected_year = params[:year]&.to_i || Date.current.year
    @selected_week = params[:week]&.to_i || Date.current.cweek
    
    # Calculate the start and end of the selected week
    @current_week_start = Date.commercial(@selected_year, @selected_week, 1)
    @current_week_end = Date.commercial(@selected_year, @selected_week, 7)
    
    # Get all todo items for the selected week
    @all_todo_items = current_user.todo_items
                                 .where(week_start_date: @current_week_start)
                                 .includes(:notes) # Removed :source from includes
                                 .order(:created_at)
    
    @completed_items = @all_todo_items.completed
    @incomplete_items = [] # Empty array - we don't want incomplete items in the report
    
    @meeting_items = @all_todo_items.completed.where(source_type: 'RecurringMeeting')
    @goal_items = @all_todo_items.completed.where(source_type: 'Goal')
    @ad_hoc_items = @all_todo_items.completed.where(source_type: 'AdHocTodo')
    
    render layout: false
  end

  private

  def generate_weekly_todos_for_date(week_start_date)
    todos_created = 0
    
    # Generate todos from recurring meetings
    current_user.recurring_meetings.each do |meeting|
      if meeting.should_occur_in_week?(week_start_date)
        current_user.todo_items.create!(
          description: meeting.name,
          source: meeting,
          week_start_date: week_start_date
        )
        todos_created += 1
      end
    end
    
    # Generate todos from active goals
    current_user.goals.active.each do |goal| # Only active goals
      goal.target_count.times do
        current_user.todo_items.create!(
          description: goal.description,
          source: goal,
          week_start_date: week_start_date
        )
        todos_created += 1
      end
    end
    
    todos_created
  end
end
