# Stage 1: Builder to sync the mirror
FROM rust:latest AS builder

RUN cargo install panamax

RUN panamax init /mirror

# Limit to stable only (you can remove or adjust this line)
RUN sed -i 's/channels = \["stable", "beta", "nightly"\]/channels = \["stable"\]/' /mirror/mirror.toml

# Copy your real Cargo.toml from host → container
COPY dummy/Cargo.toml /dummy/Cargo.toml

# Create minimal lib.rs so Cargo considers this a valid crate
RUN mkdir -p /dummy/src && touch /dummy/src/lib.rs

# Generate Cargo.lock with the exact versions you want
RUN cd /dummy && cargo update

# Sync everything Panamax knows how to mirror using that lockfile
RUN panamax sync --cargo-lock /dummy/Cargo.lock /mirror

# Stage 2: runtime
FROM panamaxrs/panamax:latest

COPY --from=builder /mirror /mirror

EXPOSE 8080
CMD ["serve", "/mirror"]