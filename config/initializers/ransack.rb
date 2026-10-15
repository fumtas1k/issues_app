# gem・Rails 側のモデルは直接編集できないため、ここで ransack の許可リストを定義する。
# ActionText::RichText はエンジンの app/models にあり自動読み込みされるため、
# 開発環境のコードリロードで定義が消えないよう to_prepare 内で再定義する。
Rails.application.config.to_prepare do
  # 検索フォームで使う条件だけを許可する(タグ名での絞り込み)
  ActsAsTaggableOn::Tag.class_eval do
    def self.ransackable_attributes(auth_object = nil)
      %w[name]
    end

    def self.ransackable_associations(auth_object = nil)
      []
    end
  end

  # 検索フォームで使う条件だけを許可する(イシュー詳細・コメント本文の検索)
  ActionText::RichText.class_eval do
    def self.ransackable_attributes(auth_object = nil)
      %w[body]
    end

    def self.ransackable_associations(auth_object = nil)
      []
    end
  end
end
