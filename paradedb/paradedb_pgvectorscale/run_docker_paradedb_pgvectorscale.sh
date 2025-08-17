# 이미지 빌드
docker build -t scalable-paradedb .

# 컨테이너 실행
docker run --name scalable-paradedb -e POSTGRES_PASSWORD=password scalable-paradedb
