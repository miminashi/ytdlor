#!/bin/sh

#
# ローカルのDocker環境にデプロイする
#
# つかいかた:
#   デプロイする場合, 引数なしで実行する
#     ./deploy_scripts/deploy_local.sh
#   その他の操作をする場合, 引数を指定して実行する
#     ./deploy_scripts/deploy_local.sh run db psql --version
#   初回
#     ./deploy_scripts/deploy_local.sh build
#     ./deploy_scripts/deploy_local.sh run web rails db:create
#     ./deploy_scripts/deploy_local.sh run web rails db:migrate
#     ./deploy_scripts/deploy_local.sh
#   2回目以降
#     ./deploy_scripts/deploy_local.sh
#

set -eu

docker_compose() {
  #export DOCKER_HOST="ssh://ytdlor.local"
  export COMPOSE_PROJECT_NAME="ytdlor-production"
  export SECRET_KEY_BASE="13a1d85b904da9a62716e15705cf814eb9dddfa82df51075da9b0e3cfbb51a9ff9a70b23d0e6e33157896a038a2327fd826e6e509d1d208c912f852339d563e7"
  export YTDLOR_WEB_PORT="8001"
  docker compose -f docker-compose.yml -f docker-compose-production.yml "${@}"
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
