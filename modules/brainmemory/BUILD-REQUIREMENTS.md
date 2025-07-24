# BrainMemory Build Requirements

## 🛠️ Zum Kompilieren benötigt

### Linux (Ubuntu/Debian)
```bash
sudo apt-get update
sudo apt-get install -y build-essential pkg-config libssl-dev
```

### Linux (Fedora/RHEL)
```bash
sudo dnf install gcc gcc-c++ make openssl-devel
```

### macOS
```bash
# Xcode Command Line Tools
xcode-select --install
```

### Windows
- Visual Studio 2019+ mit C++ Build Tools
- Oder: MinGW-w64

## 🦀 Rust Installation

```bash
# Wenn noch nicht installiert
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
```

## 🏗️ Build-Befehle

```bash
# Development Build (mit Debug-Symbolen)
cargo build

# Release Build (optimiert)
cargo build --release

# Tests ausführen
cargo test

# Benchmarks (wenn verfügbar)
cargo bench
```

## 📊 Build-Zeiten

- Erster Build: ~2-3 Minuten (Dependencies)
- Incremental Build: ~5-10 Sekunden
- Release Build: ~1-2 Minuten

## 🐳 Docker Alternative

Wenn keine Build-Tools installiert werden können:

```dockerfile
FROM rust:1.88-slim
WORKDIR /app
COPY . .
RUN cargo build --release
CMD ["./target/release/brainmemory"]
```

## ⚡ Pre-Built Binaries

Für Systeme ohne Compiler werden wir Pre-Built Binaries bereitstellen:
- Linux x86_64
- Linux ARM64
- macOS Universal
- Windows x64

Check GitHub Releases: https://github.com/stlas/SimplyKI/releases