require 'rails_helper'

RSpec.describe ChatRoomChannel, type: :channel do
  let!(:user) { create(:user) }
  let!(:partner) { create(:user, :seq) }
  let!(:other) { create(:user, :seq) }
  let!(:chat_room) { create(:chat_room) }
  let!(:other_chat_room) { create(:chat_room) }
  let!(:foreign_chat_room) { create(:chat_room) }
  let!(:chat_room_user) { create(:chat_room_user, user: user, chat_room: chat_room) }
  let!(:chat_room_partner) { create(:chat_room_user, user: partner, chat_room: chat_room) }
  let!(:chat_room_other) { create(:chat_room_user, user: other, chat_room: other_chat_room) }
  let!(:chat_room_other_user) { create(:chat_room_user, user: user, chat_room: other_chat_room) }
  # userが参加していない、otherとpartnerだけのルーム
  let!(:foreign_room_other) { create(:chat_room_user, user: other, chat_room: foreign_chat_room) }
  let!(:foreign_room_partner) { create(:chat_room_user, user: partner, chat_room: foreign_chat_room) }

  before { stub_connection current_user: user }

  describe "購読" do
    it "参加しているルームなら購読できる" do
      subscribe(chat_room_id: chat_room.id)
      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_for([user, chat_room])
    end

    it "参加していないルームは拒否される" do
      subscribe(chat_room_id: foreign_chat_room.id)
      expect(subscription).to be_rejected
    end

    it "存在しないidは拒否される" do
      subscribe(chat_room_id: 0)
      expect(subscription).to be_rejected
    end

    it "user_idを送っても接続ユーザーのストリームになる" do
      subscribe(user_id: partner.id, chat_room_id: chat_room.id)
      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_for([user, chat_room])
      expect(subscription).not_to have_stream_for([partner, chat_room])
    end
  end

  describe "メッセージ送信" do
    let(:message) { attributes_for(:message, user: user) }

    context "購読済みの場合" do
      before do
        subscribe(chat_room_id: chat_room.id)
        expect(subscription).to be_confirmed
      end

      it "メッセージが接続ユーザーと購読ルームで保存される" do
        expect do
          perform :speak, message: message[:content]
        end.to change(Message, :count).by(1)
        saved = Message.last
        expect(saved.user).to eq user
        expect(saved.chat_room).to eq chat_room
        expect(saved.content).to eq message[:content]
      end

      it "dataに他人のuser_idや別ルームのidが入っていても無視される" do
        expect do
          perform :speak, message: message[:content], user_id: other.id, chat_room_id: other_chat_room.id
        end.to change(Message, :count).by(1)
        saved = Message.last
        expect(saved.user).to eq user
        expect(saved.chat_room).to eq chat_room
      end

      it "空のメッセージは保存されない" do
        expect do
          perform :speak, message: ""
          perform :speak, message: "   "
        end.not_to change(Message, :count)
      end

      it "メッセージが接続している自分のチャネルに配信される" do
        expect do
          perform :speak, message: message[:content]
          sleep 0.5
        end.to have_broadcasted_to([user, chat_room]).with { |data|
          expect(data["message"].to_s).to include(message[:content])
        }
      end
    end

    context "購読していない・拒否された場合" do
      it "speakを直接呼んでも例外が出ず、保存されない" do
        subscribe(chat_room_id: foreign_chat_room.id)
        expect(subscription).to be_rejected
        expect do
          subscription.speak("message" => message[:content], "user_id" => user.id, "chat_room_id" => foreign_chat_room.id)
        end.not_to raise_error
        expect(Message.count).to eq 0
      end
    end
  end

  describe "既読" do
    before do
      allow(MessageReadUpdateJob).to receive(:perform_later)
      subscribe(chat_room_id: chat_room.id)
      expect(subscription).to be_confirmed
    end

    it "購読ルームの相手のメッセージならジョブが呼ばれる" do
      message = create(:message, user: partner, chat_room: chat_room)
      perform :read, message_id: message.id
      expect(MessageReadUpdateJob).to have_received(:perform_later).with(partner, chat_room)
    end

    it "他ルームのメッセージでは呼ばれない" do
      message = create(:message, user: other, chat_room: other_chat_room)
      expect { perform :read, message_id: message.id }.not_to raise_error
      expect(MessageReadUpdateJob).not_to have_received(:perform_later)
    end

    it "自分のメッセージでは呼ばれない" do
      message = create(:message, user: user, chat_room: chat_room)
      expect { perform :read, message_id: message.id }.not_to raise_error
      expect(MessageReadUpdateJob).not_to have_received(:perform_later)
    end

    it "存在しないidでは呼ばれない" do
      expect { perform :read, message_id: 0 }.not_to raise_error
      expect(MessageReadUpdateJob).not_to have_received(:perform_later)
    end

    it "message_idが空では呼ばれない" do
      expect { perform :read, message_id: "" }.not_to raise_error
      expect { perform :read, {} }.not_to raise_error
      expect(MessageReadUpdateJob).not_to have_received(:perform_later)
    end
  end

  describe "既読(購読が拒否された場合)" do
    it "readを直接呼んでも例外が出ず、ジョブも呼ばれない" do
      allow(MessageReadUpdateJob).to receive(:perform_later)
      message = create(:message, user: partner, chat_room: foreign_chat_room)
      subscribe(chat_room_id: foreign_chat_room.id)
      expect(subscription).to be_rejected
      expect { subscription.read("message_id" => message.id) }.not_to raise_error
      expect(MessageReadUpdateJob).not_to have_received(:perform_later)
    end
  end
end
