# SimplyKI Docker Image
# Multi-stage build für optimale Größe

# Stage 1: Rust Builder
FROM rust:1.88-slim AS rust-builder

# Build dependencies
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Build BrainMemory
WORKDIR /build
COPY modules/brainmemory/Cargo.toml modules/brainmemory/Cargo.lock ./
COPY modules/brainmemory/src ./src
RUN cargo build --release

# Stage 2: Final Image
FROM ubuntu:22.04

# Metadata
LABEL maintainer="SimplyKI Team"
LABEL version="1.0.0"
LABEL description="SimplyKI - Universal AI Development Framework"

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    bash \
    curl \
    jq \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create user
RUN useradd -m -s /bin/bash simplyKI

# Copy SimplyKI
WORKDIR /opt/simplyKI
COPY --chown=simplyKI:simplyKI . .

# Copy Rust binary from builder
COPY --from=rust-builder --chown=simplyKI:simplyKI \
    /build/target/release/brainmemory \
    /opt/simplyKI/modules/brainmemory/target/release/

# Make scripts executable
RUN chmod +x bin/simplyKI && \
    find modules -name "*.sh" -exec chmod +x {} \;

# Add to PATH
ENV PATH="/opt/simplyKI/bin:${PATH}"
ENV SIMPLYKIROOT="/opt/simplyKI"

# Switch to non-root user
USER simplyKI
WORKDIR /home/simplyKI

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD simplyKI status || exit 1

# Default command
CMD ["simplyKI", "status"]