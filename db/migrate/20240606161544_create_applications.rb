class CreateApplications < ActiveRecord::Migration[7.1]
  def change
    create_table :applications do |t|
      t.string :token, null: false
      t.integer :chat_count
      t.string :name, null:false

      t.timestamps
    end
    add_index :applications, :token
  end
end
