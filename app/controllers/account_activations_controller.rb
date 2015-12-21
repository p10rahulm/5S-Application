class AccountActivationsController < ApplicationController
  def edit
    @user = User.find_by(email: params[:email])
    if @user && !@user.activated? && @user.authenticated?(:activation, params[:id])
      @user.activate
      # @user.update_attribute(:activated, true)
      # @user.update_attribute(:activated_at, Time.zone.now)
      log_in @user
      flash[:success] = "Account activated! Welcome to the Sample App!"
      redirect_to @user
      # equivalent to redirect_to user_url(@user)

    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end

end
