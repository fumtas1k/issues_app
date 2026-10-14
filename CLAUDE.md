# CLAUDE.md

このファイルは Claude Code がこのリポジトリで作業するときの前提知識をまとめたもの。

## プロジェクト概要

- アプリ名: 意習(issue)。新人薬剤師とメンターが業務上のイシューを投稿・コメントして共有するポートフォリオ用 Rails アプリ
- **パブリックリポジトリ**（github.com/fumtas1k/issues_app）。秘密情報・IP アドレス・鍵ファイル名などをコミットしないこと
- **本番稼働はしていない**。破壊的な変更（DB 再作成、gem のメジャーアップデートなど）は許容されやすいが、テストが通る状態は維持する
- インフラ構築（AWS CDK）は別リポジトリ: https://github.com/fumtas1k/issues_app_cdk

## 技術スタック（現状）

| 項目 | バージョン | 備考 |
|---|---|---|
| Ruby | 3.0.1 | `.ruby-version` / `Gemfile` / `Dockerfile` / `config/deploy.rb` / `scripts/userdata.sh` に記載 |
| Rails | 6.0.6.1 | `config.load_defaults 6.0` |
| DB | PostgreSQL 14 | |
| JS ビルド | webpacker 5 + webpack 4 + Node 16 | `app/javascript/packs/*` |
| CSS | sass-rails (Sprockets) + webpacker 側の scss | |
| フロント | jQuery 3.5.1 / Bootstrap 4.5.0 / Vue 2（タグ入力のみ） / Turbolinks / Trix | |
| 認証・認可 | devise / cancancan（`app/models/ability.rb`、admin のみ rails_admin） | |
| 管理画面 | rails_admin 3.1（`/admin`） | |
| その他 | ActionText, ActiveStorage(S3/minio), ActionCable(redis), ransack, kaminari, acts-as-taggable-on, whenever(cron), SendGrid | |
| Web サーバ | puma（開発）/ unicorn（本番、capistrano でデプロイ） | |
| テスト | RSpec + Capybara + selenium(headless chrome) + FactoryBot + DatabaseCleaner | `test/` ディレクトリは未使用の Rails 生成物 |

Bundler は `Gemfile.lock` 上 2.3.8、Dockerfile では 2.4.7 をインストールしている（不一致）。

## ディレクトリ構成のポイント

- `app/models/user.rb`: devise。**最初に登録した非ゲストユーザーが admin + mentor になる**（`make_the_first_user_admin`）。ゲストユーザー（code `_guest` / `_admin`）は `User.guest_user` / `User.guest_admin_user` で自動生成
- `app/models/issue.rb`: 公開範囲 `scope`（release / limited / draft）と `accessible?` による閲覧制御。`notify` コールバックで通知生成
- `app/models/concerns/`: `ActionTextValidate`（添付サイズ検証）、`GetEnumMethod`（enum の i18n）、`SqlHelper`（recent/past スコープ）
- `app/channels/chat_room_channel.rb` + `app/jobs/message_*_job.rb`: ActionCable のチャット機能（ドラフト版）
- `app/controllers/users_csv_controller.rb`: CSV によるユーザー一括インポート（activerecord-import）
- `app/controllers/users/`: devise のカスタムコントローラ。`sessions#guest_sign_in` でゲストログイン
- `lib/mail/send_grid.rb` + `config/initializers/sendgrid.rb`: ActionMailer の SendGrid 配信方法
- `lib/tasks/whenever_scheduler.rake` + `config/schedule.rb`: 未添付 blob と古い通知の定期削除
- `config/deploy.rb`, `config/deploy/*.rb`, `Capfile`, `config/unicorn/`: capistrano による EC2 デプロイ設定。接続先は `DEPLOY_HOST` / `DEPLOY_USER` / `DEPLOY_SSH_KEY_PATH` を ENV かローカルの `.env` で渡す
- `scripts/userdata.sh`: EC2 初期構築スクリプト
- `RDD/`: ER 図・画面遷移図・ワイヤーフレーム

## 開発環境

Docker Compose 前提。`config/database.yml` の development / test は `host: db` を参照する。

```sh
# 事前に /etc/hosts に `127.0.0.1 minio` を追加しておく（README 参照）
docker-compose up -d             # db, web(:3000), webpacker(:3035), minio(:9000/:9001), mc, redis
docker-compose exec web bash     # コンテナ内で作業
docker-compose run web rails db:seed
```

`.env` に `SENDGRID_API_KEY`, `SENDGRID_API_HOST`, `EMAIL` を設定する（`.env*` は gitignore 済み）。
開発環境のメールは letter_opener_web（`/letter_opener`）で確認する。

## テスト

```sh
bundle exec rspec                       # 全件
bundle exec rspec spec/models           # モデルのみ
bundle exec rspec spec/system/issue_spec.rb:42
```

- CI: `.github/workflows/test.yaml`（pull_request で RSpec。Postgres サービスコンテナを使い `DATABASE_URL` で接続）
- system spec は headless chrome を使う。Docker 内では動かない既知の問題あり（issue #139）
- ローカルで Docker を使わずに動かす場合は `DATABASE_URL=postgresql://issues_app:issues_app@localhost:5432/issues_app_test` のように指定する

## アップグレード方針（2026-10 時点）

Ruby 3.0 / Rails 6.0 / Node 16 / webpacker はすべて EOL。最終目標は **Ruby 4.0 系 + Rails 8.1 系**。
進捗はトラッキング issue #182 で管理する（優先度ラベル `P0` / `P1` / `P2`、種別ラベル `security` / `upgrade`）。
Rails 6.0 系には 2024 年以降の CVE の修正版がないため、gem 単体の更新では脆弱性を解消できない。Rails 本体を上げる必要がある。

1 段ずつ上げ、各段階で RSpec を通して deprecation 警告を解消してから次へ進む。`load_defaults` は `new_framework_defaults_*.rb` を使って段階的に上げる。

| 段階 | Rails | Ruby | 主な作業 |
|---|---|---|---|
| 1 | 6.1 | 3.0.7 | CI の actions 更新 |
| 2 | （6.1 のまま） | – | webpacker → jsbundling-rails(esbuild) + cssbundling-rails、Node 24 LTS |
| 3 | 7.0 | 3.1 | turbolinks → turbo-rails、rails-ujs の置き換え |
| 4 | 7.1 | 3.2 | trix 2 系 / actiontext、puma への一本化 |
| 5 | 7.2 | 3.3 | |
| 6 | 8.0 | 3.4 | |
| 7 | 8.1 | 4.0 | |

- rails_admin は gem と npm パッケージのバージョンを必ず一致させる（現状 gem 3.1.1 / npm 3.0.0 で不一致）
- ransack 4 系では `ransackable_attributes` / `ransackable_associations` の定義が必須
- devise 5 系、PostgreSQL 17 以降への更新も含める

## セキュリティ上の注意

- 認可はコントローラで `current_user` を起点に取得する（`current_user.notifications.find(...)` など）。`params[:user_id]` で取得したユーザーをそのまま操作対象にしない
- ActionCable のチャンネルでは、クライアントから送られた `user_id` を信用せず `current_user` を使う
- Issue に紐づくリソース（comments, favorites, stocks）を操作するときも `Issue#accessible?` で公開範囲を確認する
- strong parameters で `admin` / `mentor` などの権限フラグを permit しない
- ransack を使うモデルには検索可能な属性・関連の許可リストを定義する
- 開発用の固定パスワード（docker-compose、seeds、ゲストユーザー）は本番相当の環境へ持ち込まない
- デプロイ先の IP アドレスや鍵ファイル名はリポジトリに書かず ENV で渡す

## 作業ルール

- ブランチは `feature/*` を切り、master へは PR 経由でマージする（CI の RSpec 通過が必須）
- コミットメッセージは既存の慣習に合わせ `[add]` `[change]` `[fix]` `[remove]` `[doc]` `[update]` などのプレフィックス + 日本語で書く
- Ruby / Rails のバージョンを変えるときは、上表に挙げた記載箇所（`.ruby-version`, `Gemfile`, `Dockerfile`, `config/deploy.rb`, `scripts/userdata.sh`, `README.md` のバッジと開発環境欄）をまとめて更新する
- 秘密情報は `.env` か `rails credentials` に置く。`config/master.key` は絶対にコミットしない
- コード・コメント・ドキュメントは日本語で書かれている。既存のスタイルに合わせる
