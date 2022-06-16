require 'rails_helper'
RSpec.describe :chat_room, type: :system do
  describe "user_index機能" do
    let!(:user) { create(:user) }
    let!(:chat_room_user) { create(:user, :seq) }
    before do
      sign_in user
      visit user_index_user_chat_rooms_path(:user)
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
      it "チャットルームに移動する" do
        expect {
          click_on chat_room_user.name
          sleep 0.1
          expect(current_path).to eq user_chat_room_path(user, user.chat_rooms.first)
        }.to change(ChatRoomUser, :count).by(0)
      end
    end
  end

  describe "show機能(action_cable)" do
    let!(:user) { create(:user) }
    let!(:partner) { create(:user, :seq) }
    let!(:other) { create(:user, :seq) }
    let!(:chat_room) { create(:chat_room) }
    let!(:other_chat_room) { create(:chat_room) }
    let!(:chat_room_user) { create(:chat_room_user, user: user, chat_room: chat_room) }
    let!(:chat_room_partner) { create(:chat_room_user, user: partner, chat_room: chat_room) }
    let!(:chat_room_other) { create(:chat_room_user, user: other, chat_room: other_chat_room) }
    let!(:chat_room_other_user) { create(:chat_room_user, user: user, chat_room: other_chat_room) }
    let(:message) { attributes_for(:message) }

    context "関係ないチャットルームにアクセスした場合" do
      it "root_pathにリダイレクトされる" do
        sign_in other
        visit user_chat_rooms_path(other)
        expect {
          visit user_chat_room_path(other, chat_room)
        }.to change {current_path}.from(user_chat_rooms_path(other)).to(root_path)
      end
    end

    context "メッセージを送信した場合" do
      before do
        sign_in user
        visit user_chat_room_path(user, chat_room)
      end
      it "メッセージが未読で表示される" do
        expect {
          fill_in "message_content", with: message[:content]
          find("#message_content").send_keys :return
          sleep 0.5
          expect(page).to have_content message[:content]
          expect(page).to have_content Message.human_attribute_name(:unread)
        }.to change(Message, :count).by(1)
      end
    end

    context "送信されたメッセージを相手が表示した場合" do
      before do
        sign_in user
        visit user_chat_room_path(user, chat_room)
        fill_in "message_content", with: message[:content]
        find("#message_content").send_keys :return
        sign_out user
      end

      it "相手のチャットルームにメッセージが表示され、自分のチャットルームのメッセージは既読になる" do
        sign_in partner
        visit user_chat_room_path(partner, chat_room)
        expect(page).to have_content message[:content]
        sign_out partner
        sign_in user
        visit user_chat_room_path(user, chat_room)
        expect(page).to have_content Message.human_attribute_name(:read)
      end

      it "別のユーザーのチャットルームにはメッセージは表示されない" do
        sign_in other
        visit user_chat_room_path(other, other_chat_room)
        expect(page).not_to have_content message[:content]
      end
    end
  end

  describe "index機能" do
    let!(:user) { create(:user) }
    let!(:partner) { create(:user, :seq) }
    let!(:other) { create(:user, :seq) }
    let!(:chat_room) { create(:chat_room) }
    let!(:chat_room_user) { create(:chat_room_user, user: user, chat_room: chat_room) }
    let!(:chat_room_partner) { create(:chat_room_user, user: partner, chat_room: chat_room) }
    before do
      sign_in user
    end

    context "partnerとのchat_roomが作成されていてメッセージが1件でもある場合" do
      let!(:message) { create(:message, user: partner, chat_room: chat_room) }
      it "patnerが表示される" do
        visit user_chat_rooms_path(:user)
        expect(page).to have_content(partner.code)
        expect(page).not_to have_content(other.code)
      end
    end

    context "partnerとのchat_roomが作成されていてメッセージが0件の場合" do
      it "patnerは表示されない" do
        visit user_chat_rooms_path(:user)
        expect(page).not_to have_content(partner.code)
        expect(page).not_to have_content(other.code)
      end
    end

    context "chat_roomがすでに作成されている状態でchat_room_userをクリックした場合" do
      let!(:message) { create(:message, user: partner, chat_room: chat_room) }
      it "チャットルームに移動する" do
        visit user_chat_rooms_path(:user)
        expect {
          click_on partner.name
          sleep 0.1
          expect(current_path).to eq user_chat_room_path(user, user.chat_rooms.first)
        }.to change(ChatRoomUser, :count).by(0)
      end
    end

    context "2人からメッセージを受信している場合" do
      let!(:chat_room2) { create(:chat_room) }
      let!(:chat_room2_user) { create(:chat_room_user, user: user, chat_room: chat_room2) }
      let!(:chat_room2_other) { create(:chat_room_user, user: other, chat_room: chat_room2) }
      let!(:message) { create(:message, user: partner, chat_room: chat_room, created_at: "2022-01-01 00:00") }
      let!(:message2) { create(:message, user: other, chat_room: chat_room2, created_at: "2022-01-02 00:00") }
      it "メッセージの作成日の降順にソートされる" do
        visit user_chat_rooms_path(:user)
        chat_users = all(".chat_users-list a")
        expect(chat_users[0]).to have_content other.code
        expect(chat_users[1]).to have_content partner.code
      end
    end
  end
end
