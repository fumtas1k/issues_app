require 'rails_helper'
RSpec.describe :chat_room, type: :system do
  describe "index機能" do
    let!(:user) { create(:user) }
    let!(:chat_room_user) { create(:user, :seq) }
    before do
      sign_in user
      visit user_chat_rooms_path(:user)
    end

    context "chat_roomが未作成時にchat_room_userをクリックした場合" do
      it "chat_roomとchat_room_usersが作成される" do
        expect {
          click_on chat_room_user.name
          sleep 0.1
          expect(current_path).to eq user_chat_room_path(user, user.chat_rooms.first)
          expect(ChatRoom.count).to eq 1
        }.to change(ChatRoomUser, :count).by(2)
      end
    end

    context "chat_roomがすでに作成されている状態でchat_room_userをクリックした場合" do
      let!(:chat_room) { create(:chat_room) }
      let!(:chat_room_user1) { create(:chat_room_user, user: user, chat_room: chat_room) }
      let!(:chat_room_user2) { create(:chat_room_user, user: chat_room_user, chat_room: chat_room) }
      it "chat_roomとchat_room_usersが作成される" do
        expect {
          click_on chat_room_user.name
          sleep 0.1
          expect(current_path).to eq user_chat_room_path(user, user.chat_rooms.first)
        }.to change(ChatRoomUser, :count).by(0)
      end
    end
  end
end
