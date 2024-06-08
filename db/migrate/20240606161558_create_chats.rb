class CreateChats < ActiveRecord::Migration[7.1]
  def change
    create_table :chats do |t|
      t.bigint :application_id, null: false
      t.integer :chat_number, null: false
      t.bigint :message_count, null:false

      t.timestamps
    end
    add_index :chats, :chat_number
  end
end
