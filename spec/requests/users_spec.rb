require 'rails_helper'
RSpec.describe "Users", type: :request do
  let!(:mentor) { create(:mentor) } # 最初の登録ユーザーがメンターになってしまうために用意
  let!(:group) { ensure_group(mentor) }
  let!(:other_mentor) { create(:user, :seq, mentor: true) }
  let!(:other_group) { ensure_group(other_mentor) }
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user, :seq) }

  describe "未ログインの場合" do
    {
      "index" => -> { users_path },
      "show" => -> { user_path(user) },
      "stocked" => -> { stocked_user_path(user) },
      "mentor" => -> { mentor_user_path(mentor) },
      "edit_avatar" => -> { edit_avatar_user_path(user) }
    }.each do |action, path|
      it "#{action}はログイン画面にリダイレクトされる" do
        get instance_exec(&path)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET /users" do
    it "メンターは表示できる" do
      sign_in mentor
      get users_path
      expect(response).to have_http_status(:ok)
    end

    it "メンターでない場合は表示できない" do
      sign_in user
      get users_path
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET /users/:id" do
    it "本人は表示できる" do
      sign_in user
      get user_path(user)
      expect(response).to have_http_status(:ok)
    end

    it "他人のページは表示できない" do
      sign_in user
      get user_path(other_user)
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET /users/:id/stocked" do
    it "本人は表示できる" do
      sign_in user
      get stocked_user_path(user)
      expect(response).to have_http_status(:ok)
    end

    it "他人のページは表示できない" do
      sign_in user
      get stocked_user_path(other_user)
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET /users/:id/mentor" do
    it "メンター本人は表示できる" do
      sign_in mentor
      get mentor_user_path(mentor)
      expect(response).to have_http_status(:ok)
    end

    it "他のメンターのページは表示できない" do
      sign_in mentor
      get mentor_user_path(other_mentor)
      expect(response).to redirect_to(root_path)
    end

    it "メンターでない場合は自分のページでも表示できない" do
      sign_in user
      get mentor_user_path(user)
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET /users/:id/edit_avatar" do
    it "本人は表示できる" do
      sign_in user
      get edit_avatar_user_path(user)
      expect(response).to have_http_status(:ok)
    end

    it "他人のページは表示できない" do
      sign_in user
      get edit_avatar_user_path(other_user)
      expect(response).to redirect_to(root_path)
    end
  end
end
