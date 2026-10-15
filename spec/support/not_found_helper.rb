module NotFoundHelper
  # ブロック内のリクエストが「見つからない」結果になることを確認する
  # show_exceptionsの設定により、RecordNotFoundが例外として上がる場合と404が返る場合のどちらも許容する
  # 302のリダイレクトなど、それ以外の結果は失敗にする
  def expect_not_found
    yield
    expect(response).to have_http_status(:not_found)
  rescue ActiveRecord::RecordNotFound
    nil
  end
end
