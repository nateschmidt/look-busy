class NotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_note, only: [:update]

  def create
    @note = current_user.notes.build(note_params)
    
    # If content is blank, just mark the todo as completed without creating a note
    if @note.content.blank? && @note.notable_type == 'TodoItem'
      @note.notable.update(completed: true)
      # Track goal completion if this is a goal-related todo item
      if @note.notable.source_type == 'Goal'
        track_goal_completion(@note.notable.source, @note.notable.week_start_date)
      end
      redirect_to weekly_dashboard_path, notice: 'Item marked as completed!'
    elsif @note.save
      # Mark the associated todo item as completed
      if @note.notable_type == 'TodoItem'
        @note.notable.update(completed: true)
        # Track goal completion if this is a goal-related todo item
        if @note.notable.source_type == 'Goal'
          track_goal_completion(@note.notable.source, @note.notable.week_start_date)
        end
      end
      
      redirect_to weekly_dashboard_path, notice: 'Note added and item marked as completed!'
    else
      redirect_to weekly_dashboard_path, alert: 'Failed to add note.'
    end
  end

  def update
    @note = current_user.notes.find(params[:id])
    
    if @note.update(note_params)
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
