class RecurringMeetingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_recurring_meeting, only: [:show, :edit, :update, :destroy]

  def index
    @recurring_meetings = current_user.recurring_meetings.ordered
  end

  def show
  end

  def new
    @recurring_meeting = current_user.recurring_meetings.build
  end

  def edit
  end

  def create
    @recurring_meeting = current_user.recurring_meetings.build(recurring_meeting_params)

    if @recurring_meeting.save
      redirect_to @recurring_meeting
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @recurring_meeting.update(recurring_meeting_params)
      redirect_to @recurring_meeting
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @recurring_meeting.destroy
    redirect_to recurring_meetings_url
  end

  private

  def set_recurring_meeting
    @recurring_meeting = current_user.recurring_meetings.find(params[:id])
  end

  def recurring_meeting_params
    params.require(:recurring_meeting).permit(:name, :person, :frequency, :week_of_month, :month_of_quarter, :biweekly_pattern)
  end
end
