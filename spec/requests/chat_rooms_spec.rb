require 'rails_helper'

RSpec.describe "ChatRooms", type: :request do
  let!(:user) { create(:user) }
  let!(:partner) { create(:user, :seq) }

  before { sign_in user }

  describe "POST /users/:user_id/chat_rooms" do
    # user_idは相手のユーザーID
    def post_create(partner_id)
      post user_chat_rooms_path(user_id: partner_id)
    end

    context "自分自身を指定した場合" do
      it "ルームは作られず、ユーザー一覧にリダイレクトされる" do
        expect { post_create(user.id) }.not_to change { [ChatRoom.count, ChatRoomUser.count] }
        expect(response).to redirect_to user_index_user_chat_rooms_path(user)
        expect(flash[:alert]).to eq I18n.t("views.chat_rooms.flash.partner_not_found")
      end
    end

    context "存在しないuser_idを指定した場合" do
      it "ルームは作られず、ユーザー一覧にリダイレクトされる" do
        expect { post_create(0) }.not_to change { [ChatRoom.count, ChatRoomUser.count] }
        expect(response).to redirect_to user_index_user_chat_rooms_path(user)
        expect(flash[:alert]).to eq I18n.t("views.chat_rooms.flash.partner_not_found")
      end
    end

    context "他のユーザーを指定した場合" do
      it "ルームと2件のChatRoomUserが作られ、showにリダイレクトされる" do
        expect { post_create(partner.id) }.to change(ChatRoom, :count).by(1).and change(ChatRoomUser, :count).by(2)
        chat_room = ChatRoom.last
        expect(chat_room.users).to contain_exactly(user, partner)
        expect(response).to redirect_to user_chat_room_path(user, chat_room)
      end
    end

    context "すでにルームがある場合" do
      let!(:chat_room) { create(:chat_room) }
      before do
        create(:chat_room_user, user: user, chat_room: chat_room)
        create(:chat_room_user, user: partner, chat_room: chat_room)
      end

      it "ルームは増えず、既存のルームにリダイレクトされる" do
        expect { post_create(partner.id) }.not_to change { [ChatRoom.count, ChatRoomUser.count] }
        expect(response).to redirect_to user_chat_room_path(user, chat_room)
      end
    end
  end
end
