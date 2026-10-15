module WaitHelper
  # クエリ付きのURLに遷移するまで待つマッチャ
  # 検索・ソート・ページ送りは遷移前の画面にも同じ文言があるため、URLのクエリで遷移完了を判定する
  # params以外のクエリが付いていてもよい
  def have_query_params(path, params)
    pairs = Rack::Utils.build_nested_query(params).split("&")
    lookaheads = pairs.map { |pair| "(?=(?:.*&)?#{Regexp.escape(pair)}(?:&|\\z))" }.join
    have_current_path(Regexp.new("\\A#{Regexp.escape(path)}\\?#{lookaheads}"), ignore_query: false)
  end

  # selectorに一致する要素のテキストが、expected_textsの順に並ぶまで待つ
  # ソート直後は並べ替え前の要素を掴む可能性があるため、取得から比較までを待機付きで繰り返す
  def expect_texts_in_order(selector, expected_texts)
    page.document.synchronize do
      texts = all(selector, minimum: 0, wait: false).map(&:text)
      matched = texts.size >= expected_texts.size &&
        expected_texts.each_with_index.all? { |expected, i| texts[i].include?(expected.to_s) }
      raise Capybara::ExpectationNotMet, "expected #{selector} to be in order #{expected_texts}, but got #{texts}" unless matched
    end
  end

  # selectorに一致する最後の要素のテキストが、expected_textを含むまで待つ
  def expect_last_text(selector, expected_text)
    page.document.synchronize do
      text = all(selector, minimum: 0, wait: false).last&.text
      raise Capybara::ExpectationNotMet, "expected last #{selector} to include #{expected_text}, but got #{text.inspect}" unless text&.include?(expected_text.to_s)
    end
  end

  # クリックして、rails-ujsのAjax通信（remote: true）が完了するまで待つ
  # 画面に変化が出ない場合（何も起きないことの確認）に使う
  def click_and_wait_for_ajax(element)
    page.execute_script(<<~JS)
      window.__ajaxCompleted = false;
      document.addEventListener("ajax:complete", function() { window.__ajaxCompleted = true; }, { once: true });
    JS
    element.click
    page.document.synchronize do
      raise Capybara::ExpectationNotMet, "ajax request did not complete" unless page.evaluate_script("window.__ajaxCompleted")
    end
  end
end
