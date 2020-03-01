set -a
[ -f .env ] && . .env
set +a

docker stack deploy --prune -c docker-compose.yml server
#docker container prune -f;
#docker image prune -f --filter "until=24h"
