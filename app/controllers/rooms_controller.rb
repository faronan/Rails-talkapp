class RoomsController < ApplicationController
  def show
    @messages = Message.all
  end

  def new
    id = current_user.id
    @users = User.where.not(id: id)
  end

  def create_group
    group_list = params[:group_list].reject{ |title, status| status == "0"}.keys.map{|id| User.find(id)}
    group_list << current_user
    Room.create(users: group_list)
    redirect_to controller: 'user', action: 'show'
  end
end
