class NotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_note, only: [:update]

  def create
    # Check if there's already a note for this todo item
    existing_note = current_user.notes.find_by(
      notable_type: note_params[:notable_type], 
      notable_id: note_params[:notable_id]
    )
    
    # Get week/year from params or referrer
    year, week = extract_week_year_from_request
    
    if existing_note
      # Update the existing note instead of creating a new one
      if existing_note.update(content: note_params[:content])
        # Check if we should also mark the item as complete
        if params[:note_action] == "add_notes_and_complete" && existing_note.notable_type == 'TodoItem'
          todo_item = current_user.todo_items.find(existing_note.notable_id)
          todo_item.update(completed: true)
          
          # Track goal completion if applicable
          if todo_item.source_type == 'Goal'
            track_goal_completion(todo_item.source, todo_item.week_start_date)
          end
        end
        
        redirect_to weekly_dashboard_path(year: year, week: week), notice: 'Note updated successfully!'
      else
        redirect_to weekly_dashboard_path(year: year, week: week), alert: 'Failed to update note.'
      end
    else
      # Create a new note
      @note = current_user.notes.build(note_params)
      
      if @note.save
        # Check if we should also mark the item as complete
        if params[:note_action] == "add_notes_and_complete" && @note.notable_type == 'TodoItem'
          todo_item = current_user.todo_items.find(@note.notable_id)
          todo_item.update(completed: true)
          
          # Track goal completion if applicable
          if todo_item.source_type == 'Goal'
            track_goal_completion(todo_item.source, todo_item.week_start_date)
          end
        end
        
        redirect_to weekly_dashboard_path(year: year, week: week), notice: 'Note added successfully!'
      else
        redirect_to weekly_dashboard_path(year: year, week: week), alert: 'Failed to add note.'
      end
    end
  end

  def update
    @note = current_user.notes.find(params[:id])
    
    # Get week/year from params or referrer
    year, week = extract_week_year_from_request
    
    if @note.update(note_params)
      # Check if we should also mark the item as complete
      if params[:note_action] == "add_notes_and_complete" && @note.notable_type == 'TodoItem'
        todo_item = current_user.todo_items.find(@note.notable_id)
        todo_item.update(completed: true)
        
        # Track goal completion if applicable
        if todo_item.source_type == 'Goal'
          track_goal_completion(todo_item.source, todo_item.week_start_date)
        end
      end
      
      redirect_to weekly_dashboard_path(year: year, week: week)
    else
      redirect_to weekly_dashboard_path(year: year, week: week), alert: 'Failed to update note.'
    end
  end

  private

  def set_note
    @note = current_user.notes.find(params[:id])
  end

  def note_params
    params.require(:note).permit(:content, :notable_type, :notable_id)
  end
  
  def track_goal_completion(goal, week_start_date)
    completion = goal.completion_for_week(week_start_date)
    
    # Count completed todo items for this goal in this week, including the current one
    completed_count = current_user.todo_items
                                 .where(source: goal, week_start_date: week_start_date, completed: true)
                                 .count
    
    # Update the completion record with the correct count
    completion.update(completed_count: completed_count)
  end
  
  def extract_week_year_from_request
    # Try to get from params first
    year = params[:year]&.to_i || params[:note]&.dig(:year)&.to_i
    week = params[:week]&.to_i || params[:note]&.dig(:week)&.to_i
    
    # If not in params, try to extract from referrer
    if year.nil? || week.nil?
      if request.referer
        year ||= request.referer.match(/[?&]year=(\d+)/)&.[](1)&.to_i
        week ||= request.referer.match(/[?&]week=(\d+)/)&.[](1)&.to_i
      end
    end
    
    # If still not found, try to get from the todo item's week_start_date
    if (year.nil? || week.nil?) && params[:note] && params[:note][:notable_type] == 'TodoItem' && params[:note][:notable_id]
      begin
        todo_item = current_user.todo_items.find(params[:note][:notable_id])
        week_start = todo_item.week_start_date
        year ||= week_start.year
        week ||= week_start.cweek
      rescue ActiveRecord::RecordNotFound
        # Fall through to defaults
      end
    end
    
    # Default to current week if still not found
    year ||= Date.current.year
    week ||= Date.current.cweek
    
    [year, week]
  end
end
