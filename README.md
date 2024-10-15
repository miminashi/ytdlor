# YTDLOR

![YTDLOR screenshot](ytdlor.png)

**YouTube-DL On Rail**

[youtube-dl](https://github.com/ytdl-org/youtube-dl)のフロントエンド

## これはなに？

動画サイトのURLを入力すると、動画をダウンロードするツール（Webアプリケーション）です。
自宅などのLANに設置したサーバ（LinuxをインストールしたNASキット等）で動かして、同じLAN内のPCやスマートフォンのブラウザからアクセスして使用することを想定しています。
回線やダウンロード元の動画サイト動画に不当な負荷をかけないように、ダウンロードはURLを入力した順に順番に行われます。
ダウンロードした動画にタグ付けして、タグやタイトルで後から動画を探せます。（予定）

内部告発の動画など、諸事情でプラットフォームの運用者によって削除される可能性がある動画を見つけたときは、動画画をローカルに保存しておきたくなります。
しかし、「明日起きてからパソコンからやろう」といった感じで後回しにしてしまうと、起きたときにはもう削除されている…ということがしばしばあります。
これは自分にとって少々我慢ならないことだったので、寝る直前くらいの頭でも、スマートフォンからyoutube-dlに指示を出せるようなツールがほしいと考えていました。

Rails7がリリースされ、デフォルトで含まれるようになったHotwireが魅力的に思えたので、以下の技術の習作を兼ねて、このアプリケーションを実装してみることにしました。

- Rails7
- Hotwire
- Active Job
- Active Storage

パブリックにアクセスできるサービスとして公開しなかったのは、以下のような理由からです。

- 他人の用に供するのは公衆送信権の侵害にあたる可能性があること
- 自分しか利用しないデータにアクセスするために回線に負荷をかけたくないこと
- 動画ストレージの費用と転送量を負担しきれないこと

セットアップ前に使い勝手を試すことができるように、デモサイトを用意しています。
次セクションをご覧ください。

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

**起動**

```sh
./docker_compose up --build
```

ブラウザから http://localhost:3000/ にアクセスする


**テストの実行**

- すべてのテストを実行する

```sh
./docker_compose --profile test run --rm --build test rails test
```

- test:system のみ実行する

```sh
./docker_compose --profile test run --rm --build test rails test:system
```

- テストのログを見る

```sh
tail -f log/test.log
```


**gemのアップデート**

- すべての gem のバージョンをアップデートする

```sh
./docker_compose run --rm web bundle update && ./docker_compose build
```

- capybara gem のバージョンをアップデートする

```sh
./docker_compose run --rm web bundle update capybara
./docker_compose build
```

**solargraphのセットアップ**

```sh
yard
gem install solargraph-rails-init
solargraph-rails-init
```


## デプロイ

- 例として, LAN内に設置されたDebianサーバ ytdlor.local にデプロイする

**サーバの準備**

- Docker Engine をインストールする
  - https://docs.docker.com/engine/install/debian/
- `ssh ytdlor.local` という形式でsshできるように, デプロイに使用する作業用マシンの ssh_config に設定を追加しておく

```ssh_config
Host ytdlor.local
  HostName ytdlor2.local
  User debian
```

- `ssh ytdlor.local` でsshログインできることを確認しておく
- お好みでnginxを立ち上げる
  - `nginx.conf` を参考にしてください

**デプロイスクリプトの用意**

- デプロイ用のsecretを生成する

```sh
./docker_compose run --rm web rails secret
```

- 以下の内容で `deploy_scripts/deploy_ytdlor_local.sh` を作成する
  - 生成したsecretを `SECRET_KEY_BASE=` に設定する

```sh
#!/bin/sh

set -eu

docker_compose() {
  export DOCKER_HOST="ssh://ytdlor.local"
  export COMPOSE_PROJECT_NAME="ytdlor"
  export SECRET_KEY_BASE="<ここに生成したsecretを設定する>"
  export YTDLOR_WEB_PORT="8001"
  docker compose -f docker-compose.yml -f docker-compose-production.yml -f restart-always.yml "${@}"
}

args="${@:-""}"
if [ -n "${args}" ]; then
  docker_compose "${@}"
else
  docker_compose build
  docker_compose down
  docker_compose run --rm web rails db:migrate
  docker_compose up -d --remove-orphans
fi
```

- 実行権限を付与する

```sh
chmod +x deploy_scripts/deploy_ytdlor_local.sh
```

**デプロイの実行**

```sh
./deploy_scripts/deploy_ytdlor_local.sh
```
