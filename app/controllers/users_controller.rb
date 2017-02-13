class UsersController < ApplicationController

  before_filter { params[:id] && @user = User.find(params[:id].to_i) }

  def index
    @users = User.asc
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(permitted_params)
    if @user.save
      redirect_to :users, :notice => "User created successfully"
    else
      render :action => "new"
    end
  end

  def update
    if @user.update_attributes(permitted_params)
      redirect_to :users, :notice => "User updated successfully"
    else
      render :action => "edit"
    end
  end

  def destroy
    if @user == current_user
      redirect_to :users, :alert => "You cannot delete yourself"
      return
    end

    @user.destroy
    redirect_to :users, :notice => "User deleted successfully"
  end

  private

  def permitted_params
    params.require(:user).permit(:name, :email_address, :username, :password, :password_confirmation)
  end

end
