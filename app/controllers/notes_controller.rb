class NotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_note, only: [:update]

  def create
    # Check if there's already a note for this todo item
    existing_note = current_user.notes.find_by(
      notable_type: note_params[:notable_type], 
      notable_id: note_params[:notable_id]
    )
    
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
        
        redirect_to weekly_dashboard_path, notice: 'Note updated successfully!'
      else
        redirect_to weekly_dashboard_path, alert: 'Failed to update note.'
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
        
        redirect_to weekly_dashboard_path, notice: 'Note added successfully!'
      else
        redirect_to weekly_dashboard_path, alert: 'Failed to add note.'
      end
    end
  end

  def update
    @note = current_user.notes.find(params[:id])
    
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
      
      redirect_to weekly_dashboard_path
    else
      redirect_to weekly_dashboard_path, alert: 'Failed to update note.'
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
end
