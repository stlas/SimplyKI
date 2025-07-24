#!/bin/bash
# SimplyKI Setup Wizard
# Erstellt: 2025-07-24 15:15:00 CEST

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}"
cat << "EOF"
   _____ _                 _       _  _______
  / ____(_)               | |     | |/ /_   _|
 | (___  _ _ __ ___  _ __ | |_   _| ' /  | |
  \___ \| | '_ ` _ \| '_ \| | | | |  <   | |
  ____) | | | | | | | |_) | | |_| | . \ _| |_
 |_____/|_|_| |_| |_| .__/|_|\__, |_|\_\_____|
                    | |       __/ |
                    |_|      |___/
EOF
echo -e "${NC}"
echo "Welcome to SimplyKI Setup Wizard!"
echo "================================="
echo ""

# Check OS
OS="Unknown"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="Linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macOS"
fi

echo -e "${GREEN}✓${NC} Detected OS: $OS"

# Check prerequisites
echo ""
echo "Checking prerequisites..."

check_command() {
    if command -v $1 &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1 found"
        return 0
    else
        echo -e "${RED}✗${NC} $1 not found"
        return 1
    fi
}

check_command bash
check_command git
check_command curl
check_command jq

# Optional checks
echo ""
echo "Checking optional components..."
check_command cargo || echo "  → Rust not installed (needed for BrainMemory)"
check_command docker || echo "  → Docker not installed (optional)"

# Configuration
echo ""
echo "Configuration"
echo "============="

# API Keys
read -p "Do you have an Anthropic API key? (y/N): " has_anthropic
if [[ "$has_anthropic" =~ ^[Yy]$ ]]; then
    read -sp "Enter your Anthropic API key: " anthropic_key
    echo ""
fi

# Create config directory
mkdir -p config
cat > config/settings.json << EOF
{
  "api_keys": {
    "anthropic": "${anthropic_key:-your-key-here}"
  },
  "defaults": {
    "model": "auto",
    "max_cost_per_session": 10.00
  }
}
EOF

echo -e "${GREEN}✓${NC} Configuration saved"

# Build components
echo ""
echo "Building components..."
make build || true

# Install
echo ""
read -p "Install SimplyKI to ~/.local/bin? (Y/n): " do_install
if [[ ! "$do_install" =~ ^[Nn]$ ]]; then
    make install
    echo ""
    echo "Add this to your ~/.bashrc or ~/.zshrc:"
    echo -e "${YELLOW}export PATH=\$HOME/.local/bin:\$PATH${NC}"
fi

# Test installation
echo ""
echo "Testing installation..."
./bin/simplyKI status

# Rust installation offer
if ! command -v cargo &> /dev/null; then
    echo ""
    echo -e "${YELLOW}⚠️  Rust is not installed${NC}"
    echo "BrainMemory requires Rust for 100x performance boost."
    read -p "Install Rust now? (Y/n): " install_rust
    if [[ ! "$install_rust" =~ ^[Nn]$ ]]; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        source $HOME/.cargo/env
        echo "Building BrainMemory..."
        cd modules/brainmemory && cargo build --release
        cd ../..
    fi
fi

# Docker setup
if command -v docker &> /dev/null; then
    echo ""
    read -p "Build Docker image? (y/N): " build_docker
    if [[ "$build_docker" =~ ^[Yy]$ ]]; then
        make docker
    fi
fi

# Success
echo ""
echo -e "${GREEN}════════════════════════════════${NC}"
echo -e "${GREEN}✓ SimplyKI setup complete!${NC}"
echo -e "${GREEN}════════════════════════════════${NC}"
echo ""
echo "Quick start:"
echo "  simplyKI status     - Check system status"
echo "  simplyKI hcs        - Use Hybrid Context System"
echo "  simplyKI brain      - Use BrainMemory"
echo ""
echo "Documentation: docs/"
echo "GitHub: https://github.com/stlas/SimplyKI"
echo ""
echo "Happy coding! 🚀"