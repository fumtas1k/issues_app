module SignOutHelper
  # ヘッダーのログアウトをクリックし、ログアウトが完了するまで待つ
  def click_sign_out
    click_on I18n.t("devise.sessions.new.sign_out")
    expect(page).to have_content I18n.t("devise.sessions.signed_out")
  end
end
