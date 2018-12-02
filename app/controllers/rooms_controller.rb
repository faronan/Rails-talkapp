require 'net/http'
require 'uri'

class RoomsController < ApplicationController
  SPECIAL_USER_ID = 99
  START_MESSAGE = "これが私です"
  def show
    room_id = params[:id]
    @room = Room.find(room_id)
    @messages = Message.where(room: room_id)
  end

  def special_show
    rooms = User.find(current_user.id).rooms
    @room = rooms.find{|room| room.users.any?{|user| user.id == SPECIAL_USER_ID}}
    unless @room.present?
      group_list = User.where("(id = ?) OR (id = ?)", current_user.id, SPECIAL_USER_ID)
      @room = Room.create(users: group_list)
    end
    @messages = Message.where(room: @room.id)
  end

  def special_message
    room_id = params.require(:post)[:room]
    unless params.require(:post)[:image].nil?
      create_image_message
      messages = Message.where(room: room_id).order("created_at")
      new_start_message = messages.find_by(content: START_MESSAGE)
      if new_start_message.present?
        start_id = new_start_message.id
        #最後のstart_messageの後のimageの個数
        after_start_image_count = messages.where(id: start_id..Float::INFINITY).where.not(image: nil).count
        if after_start_image_count == 1
          create_reply("あなたの画像を登録しました", room_id)
        else
          name = messages[-2].content
          create_reply("#{after_start_image_count - 1}人目の#{name}の画像を登録しました", room_id)
        end
      end
    end
    redirect_to action: 'special_show', id:room_id
  end

  def special_judge
    rooms = User.find(current_user.id).rooms
    room_id = rooms.find{|room| room.users.any?{|user| user.id == SPECIAL_USER_ID}}.id
    messages = Message.where(room: room_id).order("created_at")
    new_start_message = messages.find_by(content: START_MESSAGE)
    if new_start_message.present?
      start_id = new_start_message.id
      #最後のstart_messageの後のimage全部
      after_start_images = messages.where(id: start_id..Float::INFINITY).where.not(image: nil)

      uri = URI.parse("http://172.18.0.3:3001/get")
      request = Net::HTTP::Get.new(uri)
      request.content_type = "application/json"

      images = after_start_images.map do |image|
        image.image.url
        #File.open("public" + image.image.url, "rb") do |file|
        #  file.read
        #end
      end
      data = images.map.with_index do |image, index|
        ["#{index}", image]
      end
      request.set_form(data, "multipart/form-data")
      #request.body = {'image': images}
      
      response = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(request)
      end
      result = JSON.parse(response.body)
      if result["error"].present?
        if result["index"] == 0
          create_reply("あなたの顔が正常に認識されません", room_id)
        end
        #返り値のindexから画像の中でNGの画像のIDを求める
        missing_image_id = after_start_images[result["index"] + 1].id
        #その画像よりIDが小さいMessageの中で最も新しいMessageから人名を拾う
        name = messages.where(id: 0...missing_image_id).order("created_at")[-1].content
        create_reply("#{name}の顔が正常に認識されません", room_id)
      else

      end
      image_id = after_start_images[result["index"] + 1].id
      name = messages.where(id: 0...image_id).order("created_at")[-1].content
      create_reply("あなたは#{name}と一番似ています、特に#{result["parts"]}のあたりが！", room_id)
    else
      create_reply("情報が足りません", room_id)
    end

    redirect_to action: 'special_show', id:room_id
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
    create_image_message
    redirect_to action: 'show', id: permit_params[:room]
  end

  private
    def permit_params
      params.require(:post).permit(:image, :room)
    end

    def create_image_message
      message = Message.new(permit_params)
      message.user = current_user.id
      message.save!
    end

    def create_reply(content, room)
      Message.create!(content: content, room: room, user: SPECIAL_USER_ID)
    end

end
