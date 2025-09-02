class AdHocTodosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_ad_hoc_todo, only: [:destroy]

  def create
    @ad_hoc_todo = current_user.ad_hoc_todos.build(ad_hoc_todo_params)
    
    # Check if description ends with " m" to mark as meeting
    is_meeting = @ad_hoc_todo.description.end_with?(" m")
    
    if @ad_hoc_todo.save
      # Create a todo item for this ad hoc todo
      # If it's marked as a meeting, remove the " m" suffix from the description
      description = is_meeting ? @ad_hoc_todo.description.chomp(" m") : @ad_hoc_todo.description
      
      current_user.todo_items.create!(
        description: description,
        source: @ad_hoc_todo,
        week_start_date: Date.current.beginning_of_week(:monday)
      )
      
      redirect_to weekly_dashboard_path
    else
      redirect_to weekly_dashboard_path, alert: 'Failed to create to-do item.'
    end
  end

  def destroy
    @ad_hoc_todo.destroy
    redirect_to weekly_dashboard_path
  end

  private

  def set_ad_hoc_todo
    @ad_hoc_todo = current_user.ad_hoc_todos.find(params[:id])
  end

  def ad_hoc_todo_params
    params.require(:ad_hoc_todo).permit(:description)
  end
end
