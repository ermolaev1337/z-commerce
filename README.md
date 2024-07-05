### Cloning

All the submodules will be cloned automatically

```shell
git clone --recurse-submodules https://github.com/ermolaev1337/z-commerce.git
```

### Important
Comment the following lines in the ```strart.sh``` file to prevent removal of the docker containers.

```shell
docker rmi $(docker images -f dangling=true -q)
docker stop $(docker ps -qa)
docker rm $(docker ps -qa)
```

### Heimdall Go incompatibility
For M2 CPU change the line ```RUN go install github.com/msoap/shell2http@latest``` by line ```RUN go get github.com/msoap/shell2http@latest```.

### Building & Running

```shell
sh start.sh
```

### Launching

Wait for the [Storefront](http://localhost/) to be running

Credentials for [Admin Panel](http://localhost:9000/app) are: login ```admin@medusa-test.com```, password ```supersecret``` 


