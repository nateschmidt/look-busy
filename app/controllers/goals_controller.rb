class GoalsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_goal, only: [:show, :edit, :update, :destroy, :toggle_active]

  def index
    @goals = current_user.goals.ordered.includes(:goal_completions)
  end

  def show
    @goal_completions = @goal.goal_completions.ordered
    @recent_completions = @goal.recent_progress(12)
    
    # Prepare data for charts
    @chart_data = @recent_completions.map do |completion|
      {
        week: "Week #{completion.week_number}",
        completed: completion.completed_count,
        target: @goal.target_count,
        date: completion.week_start_date.strftime("%b %d")
      }
    end
    
    # Calculate statistics
    @stats = {
      total_completions: @goal.total_completions,
      average_per_week: @goal.average_completions_per_week,
      target_met_percentage: @goal.target_met_percentage,
      current_streak: @goal.current_streak,
      longest_streak: @goal.longest_streak,
      weeks_tracked: @goal.weeks_with_completions,
      target_met_weeks: @goal.target_met_weeks
    }
  end

  def new
    @goal = current_user.goals.build
  end

  def edit
  end

  def create
    @goal = current_user.goals.build(goal_params)

    if @goal.save
      redirect_to @goal
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @goal.update(goal_params)
      redirect_to @goal
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @goal.destroy
    redirect_to goals_url
  end

  def toggle_active
    Rails.logger.info "Toggling goal #{@goal.id} from #{@goal.active} to #{!@goal.active}"
    
    if @goal.update(active: !@goal.active)
      redirect_to goals_url
    else
      redirect_to goals_url, alert: "Failed to update goal status."
    end
  end

  private

  def set_goal
    @goal = current_user.goals.find(params[:id])
  end

  def goal_params
    params.require(:goal).permit(:description, :target_count, :active)
  end
end
