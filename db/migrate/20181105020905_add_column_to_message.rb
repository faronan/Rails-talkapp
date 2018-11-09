class AddColumnToMessage < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :user, :integer
    add_column :messages, :room, :integer
  end
end
