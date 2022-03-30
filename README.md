# README
【アプリケーション名】意集(issue)
公開URL: 未完成

## 意集(issue)とは

社会人1年目（薬剤師）の問題解決能力向上を手助けする目的で作られたアプリです。
日頃の業務の中で遭遇するイシューをアウトプットし、同期での情報共有することで問題意識と解決能力を養います。
ユーザーは、薬剤師のメンターと新人薬剤師を想定しています。
イシューを投稿し、コメントすることができます。
また、解決・未解決の分類があり、メンターは未解決のものをフォローしたり、解決の方法に問題ないかチェックできます。

## 開発環境（言語）

- ruby 3.0.1
- rails 6.0.3
- jQuery 3.5.1
- Bootstrap 4.5.0
- popper.js 1.16.0

## 就業Term技術

- devise(gem)
-  Ajaxを使ったコメント機能
- お気に入り機能

## カリキュラム以外の技術

- actiontext(gem)
- ransack(gem)

## 主な機能

- ユーザー機能
  * ユーザー作成/編集
  * ユーザーログイン / ログアウト
  * 管理者

- イシュー投稿機能
  * 作成/編集/削除
  * リッチテキストでの投稿
  * 公開範囲設定
  * タグ付

- 検索・ソート機能
  * ユーザーの検索、ソート
  * イシューの検索、ソート

- コメント投稿機能
  * 作成/編集/削除
  * リッチテキストでの投稿

- いいね、ストック機能
  * 作成/削除


## 実行手順
以下は全てターミナルでの操作になります。

```
$ git clone git@github.com:fumtas1k/issues_app.git
$ cd issues_app
$ bundle install
$ yarn install
$ rails db:create && rails db:migrate
$ rails s
```

本アプリには、ImageMagickが必要です。
インストールされていない場合は、以下を実行して下さい。

**Macの場合**

```
$ brew install imagemagick
```

**Windowsの場合(WSL2)**

```
$ sudo apt install imagemagick
```

## カタログ設計
https://docs.google.com/spreadsheets/d/1TkFKai1BwqkoukUsm8eNM-FI5RmXw8tFM69eKMoSiRY/edit#gid=782464957

## テーブル定義書
https://docs.google.com/spreadsheets/d/1TkFKai1BwqkoukUsm8eNM-FI5RmXw8tFM69eKMoSiRY/edit#gid=2020033787

## ワイヤーフレーム

![ワイヤーフレーム](RDD/wireframe.png)

## ER図

![ER図](RDD/ER.png)

## 画面遷移図

![画面遷移図](RDD/ui_flow.png)
