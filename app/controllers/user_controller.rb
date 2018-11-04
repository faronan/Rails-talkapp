class UserController < ApplicationController
    def show
       return unless user_signed_in?
       @rooms = current_user.rooms
    end
end
