class DashboardController < ApplicationController
  def weekly
    # Get the selected week from params, default to current week
    @selected_year = params[:year]&.to_i || Date.current.year
    @selected_week = params[:week]&.to_i || Date.current.cweek
    
    # Calculate the start and end of the selected week
    @current_week_start = Date.commercial(@selected_year, @selected_week, 1)
    @current_week_end = Date.commercial(@selected_year, @selected_week, 7)
    
    # Get all incomplete todo items for the selected week
    @todo_items = current_user.todo_items.incomplete
                           .where(week_start_date: @current_week_start)
                           .order(:created_at)
    
    # For debugging - also get all todo items for this week (including completed)
    @all_todo_items_this_week = current_user.todo_items
                                        .where(week_start_date: @current_week_start)
                                        .order(:created_at)
    
    # Check if todos have been generated for this week
    @todos_generated = @todo_items.exists?
    
    # For debugging - get counts of meetings and goals
    @meetings_count = current_user.recurring_meetings.count
    @goals_count = current_user.goals.count
  end

  def generate_todos
    @selected_year = params[:year]&.to_i || Date.current.year
    @selected_week = params[:week]&.to_i || Date.current.cweek
    
    # Calculate the start and end of the selected week
    @current_week_start = Date.commercial(@selected_year, @selected_week, 1)
    @current_week_end = Date.commercial(@selected_year, @selected_week, 7)
    
    # Generate todo items for the selected week
    todos_created = generate_weekly_todos
    
    if todos_created > 0
      redirect_to weekly_dashboard_path(year: @selected_year, week: @selected_week), 
                  notice: "#{todos_created} to-do items generated successfully for this week!"
    else
      redirect_to weekly_dashboard_path(year: @selected_year, week: @selected_week), 
                  alert: 'No to-do items were generated. Check if you have meetings or goals set up.'
    end
  end

  def clear_todos
    @selected_year = params[:year]&.to_i || Date.current.year
    @selected_week = params[:week]&.to_i || Date.current.cweek
    
    # Calculate the start of the selected week
    @current_week_start = Date.commercial(@selected_year, @selected_week, 1)
    
    # Delete all todo items for the selected week
    todos_deleted = current_user.todo_items.where(week_start_date: @current_week_start).destroy_all.count
    
    redirect_to weekly_dashboard_path(year: @selected_year, week: @selected_week), 
                notice: "#{todos_deleted} to-do items cleared for Week #{@selected_week} of #{@selected_year}."
  end

  private

  def generate_weekly_todos
    todos_created = 0
    
    # Generate meeting todos for the selected week
    current_user.recurring_meetings.each do |meeting|
      if meeting_occurs_in_week?(meeting, @current_week_start)
        # Check if we already have a todo item for this meeting this week
        existing_todo = current_user.todo_items.find_by(
          source_type: 'RecurringMeeting',
          source_id: meeting.id,
          week_start_date: @current_week_start
        )
        
        unless existing_todo
          current_user.todo_items.create!(
            description: "Meeting: #{meeting.name} with #{meeting.person}",
            source_type: 'RecurringMeeting',
            source_id: meeting.id,
            week_start_date: @current_week_start
          )
          todos_created += 1
        end
      end
    end

    # Generate goal todos for the selected week
    current_user.goals.each do |goal|
      # Check how many todo items we already have for this goal this week
      existing_count = current_user.todo_items.where(
        source_type: 'Goal',
        source_id: goal.id,
        week_start_date: @current_week_start
      ).count
      
      # Create additional todo items if needed
      (goal.target_count - existing_count).times do |index|
        current_user.todo_items.create!(
          description: "#{goal.description} (#{existing_count + index + 1} of #{goal.target_count})",
          source_type: 'Goal',
          source_id: goal.id,
          week_start_date: @current_week_start
        )
        todos_created += 1
      end
    end
    
    todos_created
  end

  def meeting_occurs_in_week?(meeting, week_start)
    # Check if the meeting occurs in the given week
    week_end = week_start + 6.days
    
    case meeting.frequency
    when 'weekly'
      true
    when 'bi_weekly'
      # Calculate which week of the month this is (1-5)
      week_in_month = ((week_start.day - 1) / 7) + 1
      case meeting.biweekly_pattern
      when 'first_third'
        [1, 3].include?(week_in_month)
      when 'second_fourth'
        [2, 4].include?(week_in_month)
      end
    when 'monthly'
      # Calculate which week of the month this is (1-5)
      week_in_month = ((week_start.day - 1) / 7) + 1
      week_in_month == meeting.week_of_month
    when 'quarterly'
      # Calculate which month of the quarter (1-3) and which week of the month (1-5)
      quarter_month = ((week_start.month - 1) % 3) + 1
      week_in_month = ((week_start.day - 1) / 7) + 1
      quarter_month == meeting.month_of_quarter && week_in_month == meeting.week_of_month
    end
  end
end
