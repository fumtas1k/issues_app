require 'rails_helper'
require_relative '../support/rake_helper'

RSpec.describe :admin, type: :task do
  describe "create" do
    let(:task) { Rake.application["admin:create"] }
    let(:env) do
      {
        "ADMIN_CODE" => "100001",
        "ADMIN_NAME" => "管理者",
        "ADMIN_EMAIL" => "admin@example.com",
        "ADMIN_PASSWORD" => "dummy_password",
        "ADMIN_ENTERED_AT" => "2000-04-01"
      }
    end

    around do |example|
      keys = env.keys
      backup = keys.index_with { |key| ENV[key] }
      keys.each { |key| ENV.delete(key) }
      example.run
      backup.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
    end

    def run_task_quietly
      expect { task.invoke }.to output.to_stdout
    end

    def aborts_with(message)
      expect {
        expect { task.invoke }.to raise_error(SystemExit)
      }.to output(message).to_stderr
    end

    context "必須の環境変数が揃っている場合" do
      before { env.each { |key, value| ENV[key] = value } }

      it "admin かつ mentor のユーザーが作成される" do
        expect { run_task_quietly }.to change(User, :count).by(1)
        user = User.find_by(code: "100001")
        expect(user).to have_attributes(name: "管理者", email: "admin@example.com", admin: true, mentor: true)
        expect(user.entered_at).to eq Date.new(2000, 4, 1)
        expect(user.valid_password?("dummy_password")).to be true
      end

      it "パスワードを標準出力に出さない" do
        expect { task.invoke }.not_to output(/dummy_password/).to_stdout
      end

      it "ADMIN_ENTERED_AT を省略すると当日になる" do
        ENV.delete("ADMIN_ENTERED_AT")
        run_task_quietly
        expect(User.find_by(code: "100001").entered_at).to eq Date.current
      end

      it "同じ code のユーザーがいる場合は作成せず中断する" do
        create(:user, code: "100001", email: "other@example.com")
        expect { aborts_with(/既に存在/) }.not_to change(User, :count)
      end

      it "同じ email のユーザーがいる場合は作成せず中断する" do
        create(:user, email: "admin@example.com")
        expect { aborts_with(/既に存在/) }.not_to change(User, :count)
      end
    end

    context "必須の環境変数が足りない場合" do
      before { env.each { |key, value| ENV[key] = value } }

      it "不足している変数名を示して中断する" do
        ENV.delete("ADMIN_PASSWORD")
        expect { aborts_with(/ADMIN_PASSWORD/) }.not_to change(User, :count)
      end
    end
  end
end
