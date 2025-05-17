CREATE TABLE users (
    id BIGINT PRIMARY KEY,
    email VARCHAR NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW ()
);

CREATE TABLE payments (
    id BIGINT PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users (id),
    amount DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW ()
);

CREATE TABLE wiki_articles (
    id SERIAL PRIMARY KEY,
    title TEXT,
    url TEXT,
    body TEXT
);
