class PasswordsController < ApplicationController
  before_filter :authenticate_user!

    def edit
      @user = current_user
      render "devise/passwords/edit"
    end

    def update
      @user = current_user

      if @user.update_with_password(params[:user])
        sign_in(@user, :bypass => true)
        redirect_to root_path, :notice => "Password updated!"
      else
        flash[:error] = "Invalid input."
        render "devise/passwords/edit"
      end
    end
  
end