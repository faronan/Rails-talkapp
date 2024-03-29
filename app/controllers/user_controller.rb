class UserController < ApplicationController
    def show
       return unless user_signed_in?
       @rooms = current_user.rooms
    end
    def get
       return unless user_signed_in?
       @users = User.search(params[:search]).reject{ |user| user == current_user}
    end
    def get_confirm
        @user = User.find(params[:id])
    end
    def create_follow
        user = User.find(params[:id])
        if params[:follow] == 'follow'
          current_user.follow user
        else
          current_user.unfollow user
        end
        redirect_to controller: 'user', action: 'show'
    end
end
