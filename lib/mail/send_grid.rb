class Mail::SendGrid

  # settingsにはsendgrid.rbで渡したapi_keyが格納されている
  # 下記プライベートメソッドのset_api_hostで取得した値も追加しておき、API呼び出し時に引数として渡す
  def initialize(settings)
    settings[:api_host] = set_api_host
    @settings = settings
  end

  def deliver!(mail)
    # ActionMailerのメイラー内で作成したメールオブジェクトの詳細情報をSendGrid用のメールオブジェクトに置き換えていく
    # personalizationでto, cc, bccを設定
    personalization = SendGrid::Personalization.new
    personalization.subject = mail.subject

    Array(mail.to).each do |email|
      personalization.add_to(::SendGrid::Email.new(email: email))
    end

    Array(mail.cc).each do |email|
      personalization.add_cc(::SendGrid::Email.new(email: email))
    end

    Array(mail.bcc).each do |email|
      personalization.add_bcc(::SendGrid::Email.new(email: email))
    end

    # from, subject, content, personalizationを設定しSendGrid用のメールオブジェクト完成
    sg_mail = ::SendGrid::Mail.new
    sg_mail.from = ::SendGrid::Email.new(email: mail.from.first)
    sg_mail.subject = mail.subject
    sg_mail.add_content(::SendGrid::Content.new(type: "text/plain", value: mail.body.raw_source))
    sg_mail.add_personalization(personalization)

    # API呼び出し
    sg = ::SendGrid::API.new(api_key: @settings[:api_key], host: @settings[:api_host])
    response = sg.client.mail._("send").post(request_body: sg_mail.to_json)
    puts response.status_code
    puts response.headers
  end

  private

  # API接続先のホストを取得する
  def set_api_host
    ENV["SENDGRID_API_HOST"]
  end
end
