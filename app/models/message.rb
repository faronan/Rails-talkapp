class Message < ApplicationRecord
  after_create_commit { MessageBroadcastJob.perform_later self }

  def get_time
    updated_at.month.to_s + "/" + updated_at.day.to_s + "  " + updated_at.hour.to_s + ":" + updated_at.min.to_s
  end
end