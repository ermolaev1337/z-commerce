docker rmi $(docker images -f dangling=true -q)
docker network inspect heimdall-network >/dev/null 2>&1 || docker network create --driver bridge heimdall-network
docker stop $(docker ps -qa)
docker rm $(docker ps -qa)


docker-compose -f ./z-commerce-medusa/docker-compose.yml build
docker-compose -f ./z-commerce-medusa/docker-compose.yml up -d
until [ "`docker inspect -f {{.State.Health.Status}} db`"=="healthy" ]; do
    sleep 0.1;
done;
echo Medusa DB is healthy and running
until [ "`docker inspect -f {{.State.Health.Status}} medusa`"=="healthy" ]; do
    sleep 0.1;
done;
echo Medusa Backend is healthy and running


docker-compose -f ./z-commerce-storefront/docker-compose.yml build
docker-compose -f ./z-commerce-storefront/docker-compose.yml up -d
until [ "`docker inspect -f {{.State.Health.Status}} storefront`"=="healthy" ]; do
    sleep 0.1;
done;
echo Medusa Frontend is healthy and running

docker-compose -f ./z-commerce-socket/docker-compose.yml build
docker-compose -f ./z-commerce-socket/docker-compose.yml up -d
until [ "`docker inspect -f {{.State.Health.Status}} socket`"=="healthy" ]; do
    sleep 0.1;
done;
echo Medusa Socket is healthy and running

docker-compose -f ./z-commerce-controller/docker-compose.yml build
docker-compose -f ./z-commerce-controller/docker-compose.yml up -d
until [ "`docker inspect -f {{.State.Health.Status}} controller`"=="healthy" ]; do
    sleep 0.1;
done;
echo Controller Backend is healthy and running

docker-compose -f ./z-commerce-wallet/docker-compose.yml build
docker-compose -f ./z-commerce-wallet/docker-compose.yml up -d
until [ "`docker inspect -f {{.State.Health.Status}} wallet-backend`"=="healthy" ]; do
    sleep 0.1;
done;
echo Wallet Backend is healthy and running. Wallet Frontend has started

docker-compose -f ./z-commerce-heimdall/docker-compose.yml build
docker-compose -f ./z-commerce-heimdall/docker-compose.yml up -d
#until [ "`docker inspect -f {{.State.Health.Status}} bootstrap`"=="socket" ]; do
#    sleep 0.1;
#done;
#echo Heimdall\'s Bootstrap Backend has finished



