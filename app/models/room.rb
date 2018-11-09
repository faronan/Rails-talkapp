class Room < ApplicationRecord
  has_many :relationships
  has_many :users, through: :relationships

  def get_room_name(current_user)
    users.reject{ |user| user == current_user}.map{ |user| user.name}.join("、")
  end
end
