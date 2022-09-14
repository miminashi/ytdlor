# YTDLOR

![YTDLOR screenshot](ytdlor.png)

**YouTube-DL On Rail**

[youtube-dl](https://github.com/ytdl-org/youtube-dl)のフロントエンド

## デモサイト

https://demo.ytdlor.or6.jp/

**デモサイト利用上の注意**

- デモサイトを試す際は、ライセンス的に問題のない動画のURLを入力してください
  - 動画のダウンロードを利用規約で禁止している動画サイトのURLを入力しないでください
    - 利用規約でダウンロードを禁止している動画サイトの例としては、YouTubeが挙げられます
    - 利用規約でダウンロードを禁止していない動画サイトの例としては、Vimeoが挙げられます
  - オープンライセンスの動画の一覧がWikipediaにあります
    - [List of major Creative Commons licensed works - Wikipedia](https://en.wikipedia.org/wiki/List_of_major_Creative_Commons_licensed_works#Video_and_film)
  - まとめると、「利用規約でダウンロードが禁止されていない動画サイトにアップロードされているCC0（Public Domain）の動画」がデモを試すためのURLとして望ましいです
    - [VimeoにアップロードされているCC0の動画](https://vimeo.com/creativecommons/cc0)
- ダウンロードが完了してから15分が経過すると、動画は自動的に削除されます


## システム要件

- Ruby 3.1
- Redis

## セットアップ


## デバッグ

**必要なソフトウェアのインストール**

```sh
brew install youtube-dl
brew install redis
```

**gemsのインストール**

```sh
cd ytdlor
bundle
```

**Redisの起動**

```sh
brew services start redis
```

**ワーカーの起動**

```sh
./workers.sh
```

**Railsプロセスの起動**

```sh
rails s
```

起動したら http://localhost:3000/ でアクセスできる

**テストの実行**

```sh
rails test:system
```

テストのログを見るには、

```sh
tail -f log/test.log
```

**docker composeの動作確認**

```sh
RAILS_MASTER_KEY="$(cat config/credentials/production.key)" docker compose up
```

**solargraphのセットアップ**

```sh
yard
gem install solargraph-rails-init
solargraph-rails-init
```
