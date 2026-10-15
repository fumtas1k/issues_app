RailsAdmin.config do |config|
  # config.asset_source = :webpacker # コメントアウトするとbootstrapが効かなくなる

  ## Popular gems integration

  # == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method(&:current_user)

  # == CancanCan ==
  config.authorize_with :cancancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/railsadminteam/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true

  # 認証情報・アクセス元 IP は管理画面の一覧・詳細・エクスポートに出さない
  config.model "User" do
    list do
      exclude_fields :encrypted_password, :reset_password_token, :current_sign_in_ip, :last_sign_in_ip
    end
    show do
      exclude_fields :encrypted_password, :reset_password_token, :current_sign_in_ip, :last_sign_in_ip
    end
    export do
      exclude_fields :encrypted_password, :reset_password_token, :current_sign_in_ip, :last_sign_in_ip
    end
  end

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end
end

# ゲスト管理者には HTML 以外の形式(json / xml / csv など)での取得を許可しない
# (index / show は :read のみで json 等を返せるため、エクスポートを経由せず全件取得できてしまう)
Rails.application.config.to_prepare do
  RailsAdmin::MainController.class_eval do
    before_action :reject_non_html_for_guest

    private

    def reject_non_html_for_guest
      return unless current_user&.guest?
      raise CanCan::AccessDenied unless request.format.html?
    end
  end
end
