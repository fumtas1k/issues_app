require 'rails_helper'

RSpec.describe ChatRoomUser, type: :model do
  describe "バリデーションテスト" do
    let!(:user) { create(:user) }
    let!(:chat_room) { create(:chat_room) }
    let(:chat_room_user) { build(:chat_room_user, user: user, chat_room: chat_room) }

    context "user, chat_roomの組み合わせが重複していない場合" do
      it "バリデーションが通る" do
        expect(chat_room_user).to be_valid
      end
    end

    context "user, chat_roomの組み合わせが重複して作成した場合" do
      it "バリデーションに引っかかる" do
        user.chat_room_users.create(chat_room_id: chat_room.id)
        expect(chat_room_user).not_to be_valid
      end
    end
  end
end
