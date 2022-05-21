require 'rails_helper'

RSpec.describe ChatRoomChannel, type: :channel do
  let!(:user) { create(:user) }
  let!(:partner) { create(:user, :seq) }
  let!(:other) { create(:user, :seq) }
  let!(:chat_room) { create(:chat_room) }
  let!(:other_chat_room) { create(:chat_room) }
  let!(:chat_room_user) { create(:chat_room_user, user: user, chat_room: chat_room) }
  let!(:chat_room_partner) { create(:chat_room_user, user: partner, chat_room: chat_room) }
  let!(:chat_room_other) { create(:chat_room_user, user: other, chat_room: other_chat_room) }
  let!(:chat_room_other_user) { create(:chat_room_user, user: user, chat_room: other_chat_room) }

  describe "メッセージ送信" do
    let(:message) { attributes_for(:message, user: user) }
    context "送信成功" do
      before do
        # stub_connection current_user: user
        subscribe(user_id: user.id, chat_room_id: chat_room.id)
        expect(subscription).to be_confirmed
      end

      it "メッセージが保存される" do
        expect do
          perform :speak, message: message[:content], user_id: user.id, chat_room_id: chat_room.id
        end.to change(Message, :count).by(1)
      end

      it "メッセージが接続している自分のチャネルに配信される" do
        expect do
          perform :speak, message: message[:content], user_id: user.id, chat_room_id: chat_room.id
          sleep 0.5
        end.to have_broadcasted_to([user, chat_room]).with{|data|
          expect(data["message"].to_s).to include(message[:content])
        }
      end
    end

    context "送信失敗(chat_roomとuserが不明の場合)" do
      it "メッセージを送信するとエラーが返る" do
        expect do
          perform :speak, message: message[:content], user_id: user.id, chat_room_id: chat_room.id
        end.to raise_error RuntimeError
      end
    end
  end
end
