class RoomsController < ApplicationController
  def show
    @room = Room.find(params[:id])
    @messages = Message.where(room: params[:id])
  end

  def new
    id = current_user.id
    @users = User.where.not(id: id).reject{ |user| !current_user.following? user}
  end

  def create_group
    group_list = params[:group_list].reject{ |title, status| status == "0"}.keys.map{|id| User.find(id)}
    group_list << current_user
    Room.create(users: group_list)
    redirect_to controller: 'user', action: 'show'
  end
end
