# MARK: RBuilder
FROM rust:1.78.0 AS rust_builder
WORKDIR /app
COPY . .
RUN cargo build --manifest-path addons/dummy-rust/Cargo.toml --release

# MARK: Builder
FROM ghcr.io/rivet-gg/godot-docker/godot:4.2 AS builder
WORKDIR /app
COPY . .
COPY --from=rust_builder /app/addons/dummy-rust/target/ /app/addons/dummy-rust/target
RUN mkdir -p build/linux \
    && godot -v --export-release "Linux/X11" ./build/linux/game.x86_64 --headless

# MARK: Runner
FROM ubuntu:22.04
RUN apt update -y \
    && apt install -y expect-dev \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -ms /bin/bash server

COPY --from=builder --chmod=755 --chown=server:server /app/build/linux/ /app

# Change to user server
USER server

# Unbuffer output so the logs get flushed
CMD ["sh", "-c", "unbuffer /app/game.x86_64 --verbose --headless -- --server | cat"]