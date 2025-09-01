class TodoItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_todo_item, only: [:update, :notes]

  def create
    @todo_item = current_user.todo_items.build(todo_item_params)
    
    if @todo_item.save
      redirect_back(fallback_location: dashboard_weekly_path)
    else
      redirect_back(fallback_location: dashboard_weekly_path, alert: 'Failed to create to-do item.')
    end
  end

  def update
    if @todo_item.update(todo_item_params)
      # Track goal completion if this is a goal-related todo item
      if @todo_item.source_type == 'Goal' && @todo_item.completed?
        track_goal_completion(@todo_item.source, @todo_item.week_start_date)
      end
      
      redirect_back(fallback_location: dashboard_weekly_path)
    else
      redirect_back(fallback_location: dashboard_weekly_path, alert: 'Failed to update to-do item.')
    end
  end

  def notes
    render json: { notes: @todo_item.notes }
  end

  private

  def set_todo_item
    @todo_item = current_user.todo_items.find(params[:id])
  end

  def todo_item_params
    params.require(:todo_item).permit(:description, :completed, :week_start_date)
  end
  
  def track_goal_completion(goal, week_start_date)
    completion = goal.completion_for_week(week_start_date)
    
    # Count completed todo items for this goal in this week
    completed_count = current_user.todo_items
                                 .where(source: goal, week_start_date: week_start_date, completed: true)
                                 .count
    
    completion.update(completed_count: completed_count)
  end
end
