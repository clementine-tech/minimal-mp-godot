FROM ghcr.io/rivet-gg/images/godot:4.2 AS builder
WORKDIR /app
COPY . .
RUN mkdir -p build/linux \
    && godot -v --export-release "Linux/X11" --headless ./build/linux/game.x86_64

FROM ubuntu:22.04
RUN apt update -y \
    && apt install -y expect-dev \
    && rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/build/linux/ /app

RUN useradd server
USER server

# Unbuffer output so the logs get flushed
CMD ["sh", "-c", "unbuffer /app/game.x86_64 --verbose --headless -- --server | cat"]
