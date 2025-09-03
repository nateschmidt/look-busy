class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    
    if params[:user][:password].present?
      # Password change without current password requirement
      if @user.update(password: params[:user][:password], password_confirmation: params[:user][:password_confirmation])
        bypass_sign_in(@user)
        redirect_to profile_path, notice: 'Password updated successfully.'
      else
        render :edit
      end
    else
      # Email change (if needed in the future)
      if @user.update(user_params.except(:current_password, :password, :password_confirmation))
        redirect_to profile_path, notice: 'Profile updated successfully.'
      else
        render :edit
      end
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :current_password, :password, :password_confirmation)
  end
end
