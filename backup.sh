#!/bin/sh
#
# データベースとActiveStorageのバックアップを取るスクリプト
#
# 使い方:
#   $ COMPOSE_PROJECT_NAME=ytdlor-production ./backup.sh
#   $ SSH_HOST=n COMPOSE_PROJECT_NAME=ytdlor-production ./backup.sh
#
#   ./deploy_scripts/deploy_local.sh up --build -d
#   COMPOSE_PROJECT_NAME=ytdlor-production ./backup.sh
#
#   デモサイトのバックアップ
#   SSH_HOST=n COMPOSE_PROJECT_NAME=ytdlor_demo_site ./backup.sh
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

date=$(date '+%Y%m%d%H%M%S')
if [ -n "${SSH_HOST:-}" ]; then
  backup_path="./backup/${SSH_HOST}/${COMPOSE_PROJECT_NAME}/${date}"
else
  backup_path="./backup/local/${COMPOSE_PROJECT_NAME}/${date}"
fi

# データベースのバックアップ
db_dump_path="${backup_path}/db.dump"
mkdir -p "${backup_path}"
docker_compose exec -T db pg_dump -Fc -U postgres -d ytdlor_production > "${db_dump_path}"

# ActiveStorageのバックアップ
docker_compose cp web:/opt/app/storage "${backup_path}"/
