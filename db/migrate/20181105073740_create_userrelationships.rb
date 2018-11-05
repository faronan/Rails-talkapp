class CreateUserrelationships < ActiveRecord::Migration[5.2]
  def change
    create_table :userrelationships do |t|
      t.integer :follower_id
      t.integer :followed_id

      t.timestamps
    end
    add_index :userrelationships, :follower_id
    add_index :userrelationships, :followed_id
    add_index :userrelationships, [:follower_id, :followed_id], unique: true
  end
end
