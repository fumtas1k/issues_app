namespace :admin do
  desc "管理者(admin + mentor)ユーザーを作成する。ADMIN_CODE, ADMIN_NAME, ADMIN_EMAIL, ADMIN_PASSWORD は必須、ADMIN_ENTERED_AT は省略可(省略時は当日)"
  task create: :environment do
    required = %w[ADMIN_CODE ADMIN_NAME ADMIN_EMAIL ADMIN_PASSWORD]
    missing = required.select { |key| ENV[key].blank? }
    abort "次の環境変数を指定してください: #{missing.join(', ')}" if missing.any?

    code = ENV["ADMIN_CODE"].rjust(6, "0")
    email = ENV["ADMIN_EMAIL"]
    if User.exists?(code: code) || User.where("lower(email) = ?", email.downcase).exists?
      abort "同じ code または email のユーザーが既に存在するため、作成しませんでした。"
    end

    entered_at =
      begin
        ENV["ADMIN_ENTERED_AT"].present? ? Date.parse(ENV["ADMIN_ENTERED_AT"]) : Date.current
      rescue Date::Error
        abort "ADMIN_ENTERED_AT の日付形式が不正です(例: 2000-04-01)。"
      end

    user = User.new(
      code: code,
      name: ENV["ADMIN_NAME"],
      email: email,
      password: ENV["ADMIN_PASSWORD"],
      entered_at: entered_at,
      mentor: true,
      admin: true
    )
    if user.save
      puts "管理者ユーザーを作成しました(code: #{user.code})。"
    else
      abort "管理者ユーザーを作成できませんでした: #{user.errors.full_messages.join(', ')}"
    end
  end
end
