class CreateRelationships < ActiveRecord::Migration[5.2]
  def change
    create_table :relationships do |t|
      t.integer :user_id
      t.integer :room_id

      t.timestamps
    end
  add_index :relationships, :user_id
  add_index :relationships, :room_id
  add_index :relationships, [:user_id, :room_id], unique: true
  end
end
