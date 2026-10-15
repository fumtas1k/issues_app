require 'rails_helper'
RSpec.describe "UsersCsv", type: :request do
  let!(:mentor) { create(:mentor) } # 最初の登録ユーザーがメンターになってしまうために用意
  let!(:user) { create(:user) }

  # 行数を指定してCSVの内容を作る（ヘッダはUser.csv_columns.keys）
  def csv_content(rows)
    CSV.generate do |csv|
      csv << User.csv_columns.keys
      rows.times do |i|
        csv << ["", format("%06d", 500_000 + i), "新人#{i}", "import#{i}@example.com", "password", "2024-04-01"]
      end
    end
  end

  # 内容からアップロード用のファイルを作る
  def upload_file(content, content_type = "text/csv")
    file = Tempfile.new(["users", ".csv"])
    file.write(content)
    file.flush
    (@tempfiles ||= []) << file
    Rack::Test::UploadedFile.new(file.path, content_type)
  end

  after { @tempfiles&.each(&:close!) }

  describe "GET /users_csv" do
    it "未ログインの場合はログイン画面にリダイレクトされる" do
      get users_csv_index_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "メンターでない場合は表示できない" do
      sign_in user
      get users_csv_index_path
      expect(response).to redirect_to(root_path)
    end

    it "メンターの場合は表示できる" do
      sign_in mentor
      get users_csv_index_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /users_csv" do
    let(:error) { ->(key, **opts) { ERB::Util.html_escape(I18n.t("views.users_csv.errors.#{key}", **opts)) } }

    context "未ログインの場合" do
      it "ログイン画面にリダイレクトされ、ユーザーは作成されない" do
        expect {
          post users_csv_index_path, params: { import: { file: upload_file(csv_content(1)) } }
        }.not_to change(User, :count)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "メンターでない場合" do
      it "ユーザーは作成されない" do
        sign_in user
        expect {
          post users_csv_index_path, params: { import: { file: upload_file(csv_content(1)) } }
        }.not_to change(User, :count)
        expect(response).to redirect_to(root_path)
      end
    end

    context "メンターの場合" do
      before { sign_in mentor }

      it "正しいCSVならユーザーが作成される" do
        expect {
          post users_csv_index_path, params: { import: { file: upload_file(csv_content(3)) } }
        }.to change(User, :count).by(3)
        expect(response).to redirect_to(users_path)
      end

      it "行数が上限ちょうどなら作成される" do
        expect {
          post users_csv_index_path,
               params: { import: { file: upload_file(csv_content(UsersCsvController::MAX_ROWS)) } }
        }.to change(User, :count).by(UsersCsvController::MAX_ROWS)
      end

      it "ファイルがない場合はエラーになる" do
        expect {
          post users_csv_index_path
        }.not_to change(User, :count)
        expect(response.body).to include(error.call(:no_file))
      end

      it "アップロードファイルでない値の場合はエラーになる" do
        expect {
          post users_csv_index_path, params: { import: { file: "dummy" } }
        }.not_to change(User, :count)
        expect(response.body).to include(error.call(:no_file))
      end

      it "ファイルサイズが上限を超えた場合はエラーになる" do
        content = csv_content(1) + ("a" * (UsersCsvController::MAX_FILE_BYTE_SIZE + 1))
        max = ActiveSupport::NumberHelper.number_to_human_size(UsersCsvController::MAX_FILE_BYTE_SIZE)
        expect {
          post users_csv_index_path, params: { import: { file: upload_file(content) } }
        }.not_to change(User, :count)
        expect(response.body).to include(error.call(:file_too_large, max: max))
      end

      it "行数が上限を超えた場合は、ユーザーを組み立てる前にエラーになる" do
        file = upload_file(csv_content(UsersCsvController::MAX_ROWS + 1))
        expect(User).not_to receive(:new)
        expect {
          post users_csv_index_path, params: { import: { file: file } }
        }.not_to change(User, :count)
        expect(response.body).to include(error.call(:too_many_rows, max: UsersCsvController::MAX_ROWS))
      end

      it "content_typeがCSVでない場合はエラーになる" do
        expect {
          post users_csv_index_path,
               params: { import: { file: upload_file(csv_content(1), "text/plain") } }
        }.not_to change(User, :count)
        expect(response.body).to include(error.call(:not_csv))
      end
    end
  end
end
