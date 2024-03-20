class CreateChat < ActiveRecord::Migration[7.0]
  def change
    create_table :chats do |t|
      t.integer :sender_id
      t.integer :reciever_id
      t.string :message

      t.timestamps
    end
    add_index :chats, :sender_id
    add_index :chats, :reciever_id
    add_index :chats, [:sender_id, :reciever_id] , unique: true
  end
end
