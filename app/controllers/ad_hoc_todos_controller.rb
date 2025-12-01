class AdHocTodosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_ad_hoc_todo, only: [:destroy]

  def create
    @ad_hoc_todo = current_user.ad_hoc_todos.build(ad_hoc_todo_params)
    
    # Check if description ends with " m" to mark as meeting
    is_meeting = @ad_hoc_todo.description.end_with?(" m")
    
    # Get week/year from params or use current week
    year = params[:year]&.to_i || Date.current.year
    week = params[:week]&.to_i || Date.current.cweek
    week_start_date = Date.commercial(year, week, 1)
    
    if @ad_hoc_todo.save
      # Create a todo item for this ad hoc todo
      # If it's marked as a meeting, remove the " m" suffix from the description
      description = is_meeting ? @ad_hoc_todo.description.chomp(" m") : @ad_hoc_todo.description
      
      current_user.todo_items.create!(
        description: description,
        source: @ad_hoc_todo,
        week_start_date: week_start_date
      )
      
      redirect_to weekly_dashboard_path(year: year, week: week)
    else
      redirect_to weekly_dashboard_path(year: year, week: week), alert: 'Failed to create to-do item.'
    end
  end

  def destroy
    @ad_hoc_todo.destroy
    # Try to preserve week/year from referrer or params
    year = params[:year]&.to_i || extract_year_from_referrer || Date.current.year
    week = params[:week]&.to_i || extract_week_from_referrer || Date.current.cweek
    redirect_to weekly_dashboard_path(year: year, week: week)
  end

  private

  def set_ad_hoc_todo
    @ad_hoc_todo = current_user.ad_hoc_todos.find(params[:id])
  end

  def ad_hoc_todo_params
    params.require(:ad_hoc_todo).permit(:description)
  end
  
  def extract_year_from_referrer
    return nil unless request.referer
    match = request.referer.match(/[?&]year=(\d+)/)
    match ? match[1].to_i : nil
  end
  
  def extract_week_from_referrer
    return nil unless request.referer
    match = request.referer.match(/[?&]week=(\d+)/)
    match ? match[1].to_i : nil
  end
end
