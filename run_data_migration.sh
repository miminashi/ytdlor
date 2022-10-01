#!/bin/sh

#
# Run data migration
#
# usage:
#   DOCKER_HOST="unix:///var/run/docker.sock" COMPOSE_PROJECT_NAME="ytdlor" ./run_data_migration.sh
#

set -e

echo "DOCKER_HOST: ${DOCKER_HOST:?}" >&2
echo "COMPOSE_PROJECT_NAME: ${COMPOSE_PROJECT_NAME:?}" >&2

docker compose -f docker-compose.yml -f docker-compose-data-migration.yml down --remove-orphans
docker compose -f docker-compose.yml -f docker-compose-data-migration.yml build
docker compose -f docker-compose.yml -f docker-compose-data-migration.yml run --rm data_migration
docker compose -f docker-compose.yml -f docker-compose-data-migration.yml down
