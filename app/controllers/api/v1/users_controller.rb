class Api::V1::UsersController < ApplicationController
  respond_to :json
  
  def show
    begin
      @user = User.find(params[:id])
      respond_with @user
    rescue ActiveRecord::RecordNotFound
      head 404
    end
  end

  def create
    user = User.create(user_params)

    if user.save
      render json: user, status: :created
    else
      render json: { errors: user.errors }, status: :unprocessable_entity
    end
  end

  def update
    user = User.find(params[:id])
    if user.update(user_params)
      render json: user, status: :ok
    else
      render json: {errors: user.errors}, status: :unprocessable_entity
    end
  end

  def destroy
    begin
      if User.destroy(params[:id])
        head :no_content
      end
    rescue ActiveRecord::RecordNotFound
      head 404
    end
  end

  private

  def user_params
    params.require(:user).permit(:email,:password,:password_confirmation)    
  end
end
