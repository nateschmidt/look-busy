class AdHocTodosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_ad_hoc_todo, only: [:destroy]

  def create
    @ad_hoc_todo = current_user.ad_hoc_todos.build(ad_hoc_todo_params)
    
    if @ad_hoc_todo.save
      # Create a todo item for this ad hoc todo
      current_user.todo_items.create!(
        description: @ad_hoc_todo.description,
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
