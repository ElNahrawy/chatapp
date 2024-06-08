class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.text :message_body, null:false
      t.bigint :chat_id, null: false
      t.bigint :message_number, null:false

      t.timestamps
    end
    add_index :messages, :message_number
  end
end
