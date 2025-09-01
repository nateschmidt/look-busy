class NotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_note, only: [:update]

  def create
    @note = current_user.notes.build(note_params)
    
    # If content is blank, just mark the todo as completed without creating a note
    if @note.content.blank? && @note.notable_type == 'TodoItem'
      @note.notable.update(completed: true)
      redirect_to weekly_dashboard_path, notice: 'Item marked as completed!'
    elsif @note.save
      # Mark the associated todo item as completed
      if @note.notable_type == 'TodoItem'
        @note.notable.update(completed: true)
      end
      
      redirect_to weekly_dashboard_path, notice: 'Note added and item marked as completed!'
    else
      redirect_to weekly_dashboard_path, alert: 'Failed to add note.'
    end
  end

  def update
    if @note.update(note_params)
      redirect_to weekly_dashboard_path, notice: 'Note updated successfully!'
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
end
