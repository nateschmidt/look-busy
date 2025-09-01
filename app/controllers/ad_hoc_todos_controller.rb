class AdHocTodosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_ad_hoc_todo, only: [:destroy]

  def create
    @ad_hoc_todo = current_user.ad_hoc_todos.build(ad_hoc_todo_params)
    
    if @ad_hoc_todo.save
      # Create a todo item for this ad hoc todo
      current_user.todo_items.create!(
        description: @ad_hoc_todo.description,
        source_type: 'AdHocTodo',
        source_id: @ad_hoc_todo.id,
        week_start_date: Date.current.beginning_of_week
      )
      
      redirect_to weekly_dashboard_path, notice: 'To-do item added successfully!'
    else
      redirect_to weekly_dashboard_path, alert: 'Failed to add to-do item.'
    end
  end

  def destroy
    @ad_hoc_todo.destroy
    redirect_to weekly_dashboard_path, notice: 'To-do item removed successfully!'
  end

  private

  def set_ad_hoc_todo
    @ad_hoc_todo = current_user.ad_hoc_todos.find(params[:id])
  end

  def ad_hoc_todo_params
    params.require(:ad_hoc_todo).permit(:description)
  end
end
