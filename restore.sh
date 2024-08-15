#!/bin/sh
#
# データベースとActiveStorageのバックアップからリストアするスクリプト
#
# 使い方:
#   $ COMPOSE_PROJECT_NAME=ytdlor-production ./restore.sh ./backup/ytdlor-production/20210901123456
#   $ SSH_HOST=n COMPOSE_PROJECT_NAME=ytdlor-production ./restore.sh ./backup/ytdlor-production/20210901123456
#
# 注意:
#   - db:create が済んでいて, かつ空の状態である必要がある
#

set -eu

#: "${SSH_HOST}"
: "${COMPOSE_PROJECT_NAME}"

docker_compose() {
  if [ -n "${SSH_HOST:-}" ]; then
    DOCKER_HOST="ssh://${SSH_HOST}"
    export DOCKER_HOST
  fi
  docker compose -p "${COMPOSE_PROJECT_NAME}" -f docker-compose.yml -f docker-compose-production.yml "$@"
}

#date=$(date '+%Y%m%d%H%M%S')
#backup_path="./backup/${COMPOSE_PROJECT_NAME}/${date}"
backup_path="${1}"
db_dump_path="${backup_path}/db.dump"
storage_path="${backup_path}/storage"

# バックアップファイルの存在確認
if [ ! -f "${db_dump_path}" ]; then
  echo "データベースのバックアップファイルが存在しません: ${db_dump_path}"
  exit 1
fi
if [ ! -d "${storage_path}" ]; then
  echo "ActiveStorageのバックアップディレクトリが存在しません: ${storage_path}"
  exit 1
fi

# データベースのリストア
echo "データベースのリストアを実行します..."
docker_compose exec -T db pg_restore -U postgres -d ytdlor_production < "${db_dump_path}"

# ActiveStorageのリストア
echo "ActiveStorageのリストアを実行します..."
docker_compose cp "${storage_path}" web:/opt/app/
