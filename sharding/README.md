# Simple Sharding in PostgreSQL

## Running Instructions

1. Build docker image for pgshard
```bash
cd shards

docker build -t pgshard .
```

2. Create a network for the containers
```bash
docker network create --driver bridge mybridge
```

3. Run pgshard containers
```bash
docker run --name shard1 -e POSTGRES_PASSWORD=postgres --net mybridge -p 5432:5432 -d pgshard
docker run --name shard2 -e POSTGRES_PASSWORD=postgres --net mybridge -p 5433:5432 -d pgshard
docker run --name shard3 -e POSTGRES_PASSWORD=postgres --net mybridge -p 5434:5432 -d pgshard
```

4. Run pgadmin for observing the shards
```bash
docker run -e PGADMIN_DEFAULT_EMAIL="neos960518@gmail.com" -e PGADMIN_DEFAULT_PASSWORD="password" --net mybridge -p 5555:80 --name pgadmin -d dpage/pgadmin4
```

Now, open the browser and go to `localhost:5555` and login with the credentials provided above.
And, add the connections to each shard.

5. Run the WAS
```bash
cd ..

npm install
node index.js
```
