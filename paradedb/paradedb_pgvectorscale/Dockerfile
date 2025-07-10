# ParadeDB를 기본 이미지로 사용
FROM paradedb/paradedb:latest-pg17

# 루트 사용자로 전환
USER root

# 필요한 종속성 설치
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    make \
    gcc \
    jq \
    ca-certificates \
    libssl-dev \
    pkg-config \
    postgresql-server-dev-17 \
    libopenblas-dev \
    libclang-dev \
    clang \
    llvm-dev


# Rust 설치
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# pgvectorscale 설치
WORKDIR /tmp
RUN git clone https://github.com/timescale/pgvectorscale
RUN cd pgvectorscale/pgvectorscale && \
    cargo install --locked cargo-pgrx --version $(cargo metadata --format-version 1 | jq -r '.packages[] | select(.name == "pgrx") | .version') && \
    cargo pgrx init --pg17 pg_config && \
    cargo pgrx install --release


# # PostgreSQL 확장 설정 파일 생성
# RUN mkdir -p /docker-entrypoint-initdb.d
# COPY <<EOF /docker-entrypoint-initdb.d/init-extensions.sql
# CREATE EXTENSION IF NOT EXISTS vectorscale;
# EOF


# postgresql.conf에 필요한 설정 추가하는 스크립트
COPY <<EOF /docker-entrypoint-initdb.d/00-configure-postgres.sh
#!/bin/bash
set -e

echo "shared_preload_libraries = 'pg_search,vectorscale,\$\{shared_preload_libraries\}'" >> \$PGDATA/postgresql.conf
EOF

RUN chmod +x /docker-entrypoint-initdb.d/00-configure-postgres.sh

EXPOSE 5432

# 원래 사용자로 돌아가기
USER postgres
