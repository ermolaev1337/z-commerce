docker network inspect heimdall-network >/dev/null 2>&1 || docker network create --driver bridge heimdall-network

# Remove this project's own containers before rebuilding. Earlier revisions ran
# "docker stop/rm $(docker ps -qa)" here, which wiped every container on the machine,
# including ones belonging to other projects. Set CLEAN_ALL=1 to get that behaviour back.
if [ "$CLEAN_ALL" = "1" ]; then
  docker rmi $(docker images -f dangling=true -q)
  docker stop $(docker ps -qa)
  docker rm $(docker ps -qa)
else
  for service in medusa storefront socket controller wallet heimdall delivery; do
    docker compose -f "./z-commerce-$service/docker-compose.yml" down --remove-orphans 2>/dev/null
  done
fi


docker compose -f ./z-commerce-medusa/docker-compose.yml build
docker compose -f ./z-commerce-medusa/docker-compose.yml up -d
until [ "`docker inspect -f {{.State.Health.Status}} db`"=="healthy" ]; do
    sleep 0.1;
done;
echo Medusa DB is healthy and running
until [ "`docker inspect -f {{.State.Health.Status}} medusa`"=="healthy" ]; do
    sleep 0.1;
done;
echo Medusa Backend is healthy and running


docker compose -f ./z-commerce-storefront/docker-compose.yml build
docker compose -f ./z-commerce-storefront/docker-compose.yml up -d
until [ "`docker inspect -f {{.State.Health.Status}} storefront`"=="healthy" ]; do
    sleep 0.1;
done;
echo Medusa Frontend is healthy and running

docker compose -f ./z-commerce-socket/docker-compose.yml build
docker compose -f ./z-commerce-socket/docker-compose.yml up -d
until [ "`docker inspect -f {{.State.Health.Status}} socket-delivery`"=="healthy" ]; do
    sleep 0.1;
done;
echo Medusa Socket Delivery is healthy and running
until [ "`docker inspect -f {{.State.Health.Status}} socket-storefront `"=="healthy" ]; do
    sleep 0.1;
done;
echo Medusa Socket Storefront is healthy and running

docker compose -f ./z-commerce-controller/docker-compose.yml build
docker compose -f ./z-commerce-controller/docker-compose.yml up -d
until [ "`docker inspect -f {{.State.Health.Status}} controller`"=="healthy" ]; do
    sleep 0.1;
done;
echo Controller Backend is healthy and running

docker compose -f ./z-commerce-wallet/docker-compose.yml build
docker compose -f ./z-commerce-wallet/docker-compose.yml up -d
until [ "`docker inspect -f {{.State.Health.Status}} wallet-backend`"=="healthy" ]; do
    sleep 0.1;
done;
echo Wallet Backend is healthy and running. Wallet Frontend has started

docker compose -f ./z-commerce-heimdall/docker-compose.yml build
docker compose -f ./z-commerce-heimdall/docker-compose.yml up -d
#until [ "`docker inspect -f {{.State.Health.Status}} bootstrap`"=="socket" ]; do
#    sleep 0.1;
#done;
echo Heimdall\'s Bootstrap Backend has finished

docker compose -f ./z-commerce-delivery/docker-compose.yml build
docker compose -f ./z-commerce-delivery/docker-compose.yml up -d
echo Delivery Frontend has started