class AddMessagesCountToChatRooms < ActiveRecord::Migration[6.0]
  def change
    add_column :chat_rooms, :messages_count, :integer, null: false, default: 0
  end
end
