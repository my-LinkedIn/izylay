# syntax=docker/dockerfile:1

# Stage 1: compile the application and bundle assets.
FROM rust:1.99-bookworm AS builder

WORKDIR /app

# Topcoat CLI, pinned to the version in Cargo.toml (cached layer).
RUN cargo install topcoat-cli --version 0.11.0 --locked

COPY . .

RUN cargo build --release --bin izylay
RUN topcoat asset bundle --release --bin izylay

# Stage 2: lean runtime image.
FROM debian:bookworm-slim AS runtime

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --system --uid 10001 --create-home app

WORKDIR /app

COPY --from=builder /app/target/release/izylay /app/izylay
COPY --from=builder /app/target/release/assets /app/assets
# Migrations are read from ./toasty relative to the working directory.
COPY --from=builder /app/toasty /app/toasty
COPY --chmod=755 docker-entrypoint.sh /app/docker-entrypoint.sh

RUN mkdir -p /app/data && chown -R 10001:10001 /app/data

USER 10001:10001

ENV HOST=0.0.0.0 \
    PORT=3000 \
    DATABASE_URL=sqlite:/app/data/data.db

EXPOSE 3000

ENTRYPOINT ["/app/docker-entrypoint.sh"]
