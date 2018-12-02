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
    if group_list.empty?
      return redirect_to rooms_new_path, alert: "一人以上選択して下さい！"
    end
    group_list << current_user
    Room.create(users: group_list)
    redirect_to controller: 'user', action: 'show'
  end

  def create_image_massage
    @message = Message.new(permit_params)
    @message.user = current_user.id
    @message.save!
    redirect_to action: 'show', id: permit_params[:room]
  end

  private
    def permit_params
      params.require(:post).permit(:image, :room)
    end

end
