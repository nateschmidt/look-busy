class TodoItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_todo_item, only: [:update, :notes]

  def create
    @todo_item = current_user.todo_items.build(todo_item_params)
    
    if @todo_item.save
      redirect_to weekly_dashboard_path, notice: 'To-do item created successfully!'
    else
      redirect_to weekly_dashboard_path, alert: 'Failed to create to-do item.'
    end
  end

  def update
    if @todo_item.update(todo_item_params)
      redirect_to weekly_dashboard_path, notice: 'To-do item updated successfully!'
    else
      redirect_to weekly_dashboard_path, alert: 'Failed to update to-do item.'
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
    params.require(:todo_item).permit(:description, :source_type, :source_id, :completed)
  end
end
