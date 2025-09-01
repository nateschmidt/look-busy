class NotesController < ApplicationController
  before_action :authenticate_user!

  def create
    @note = current_user.notes.build(note_params)
    
    if @note.save
      # Mark the associated todo item as completed
      if @note.notable_type == 'TodoItem'
        @note.notable.update(completed: true)
      end
      
      redirect_to weekly_dashboard_path, notice: 'Note added and item marked as completed!'
    else
      redirect_to weekly_dashboard_path, alert: 'Failed to add note.'
    end
  end

  private

  def note_params
    params.require(:note).permit(:content, :notable_type, :notable_id)
  end
end
