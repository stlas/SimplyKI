#!/bin/bash
# SimplyKI Installation Script
# Installiert das komplette SimplyKI Ecosystem

set -e

# Farben für Ausgabe
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Banner
echo -e "${BLUE}"
echo "  ____  _                 _       _  ___ "
echo " / ___|(_)_ __ ___  _ __ | |_   _| |/ (_)"
echo " \___ \| | '_ \` _ \| '_ \| | | | | ' /| |"
echo "  ___) | | | | | | | |_) | | |_| | . \| |"
echo " |____/|_|_| |_| |_| .__/|_|\__, |_|\_\_|"
echo "                   |_|      |___/         "
echo -e "${NC}"
echo -e "${GREEN}SimplyKI Ecosystem Installer v1.0${NC}"
echo "========================================"
echo

# Funktion für Fortschrittsanzeige
progress() {
    echo -e "${BLUE}[$(date +%H:%M:%S)]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Prüfe Voraussetzungen
progress "Prüfe System-Voraussetzungen..."

# OS Check
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    OS="windows"
else
    error "Nicht unterstütztes Betriebssystem: $OSTYPE"
fi
success "Betriebssystem: $OS"

# Prüfe benötigte Tools
check_tool() {
    if ! command -v $1 &> /dev/null; then
        error "$1 ist nicht installiert. Bitte installiere $1 und versuche es erneut."
    else
        success "$1 gefunden: $(command -v $1)"
    fi
}

check_tool git
check_tool node
check_tool npm
check_tool docker || warning "Docker nicht gefunden - manuelle Installation erforderlich"

# Erstelle Verzeichnisstruktur
INSTALL_DIR="${SIMPLYKI_HOME:-$HOME/SimplyKI}"
progress "Erstelle SimplyKI Verzeichnis in $INSTALL_DIR..."

mkdir -p "$INSTALL_DIR"/{components,data,config,logs}
cd "$INSTALL_DIR"

# Clone Repositories
progress "Clone SimplyKI Komponenten..."

clone_component() {
    local name=$1
    local repo=$2
    
    if [ -d "components/$name" ]; then
        warning "$name bereits vorhanden, überspringe..."
    else
        progress "Clone $name..."
        git clone "$repo" "components/$name" || error "Fehler beim Clonen von $name"
        success "$name geclont"
    fi
}

# Core Components
clone_component "ai-collab" "https://github.com/stlas/ai-collab.git"
clone_component "SmartKI" "https://github.com/stlas/SmartKI.git"
clone_component "SmartKI-web" "https://github.com/stlas/SmartKI-web.git"
clone_component "SmartKI-PM" "https://github.com/stlas/SmartKI-PM.git"
clone_component "SmartKI-Obsidian" "https://github.com/stlas/SmartKI-Obsidian.git"
clone_component "SmartKI-Pangolin" "https://github.com/stlas/SmartKI-Pangolin.git"
clone_component "RemoteKI" "https://github.com/stlas/RemoteKI.git"

# Konfiguration erstellen
progress "Erstelle Basis-Konfiguration..."

cat > "$INSTALL_DIR/config/simplyki.conf" << EOF
# SimplyKI Configuration
SIMPLYKI_HOME=$INSTALL_DIR
SIMPLYKI_VERSION=1.0.0
SIMPLYKI_ENV=development

# Component Ports
CORE_PORT=3200
WEB_PORT=3000
PM_PORT=3100
OBSIDIAN_PORT=3001
PANGOLIN_PORT=8080

# Database
DB_TYPE=postgresql
DB_HOST=localhost
DB_PORT=5432
DB_NAME=simplyki
DB_USER=simplyki
DB_PASS=changeme

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
EOF

# Erstelle .env Template
cat > "$INSTALL_DIR/config/.env.template" << EOF
# SimplyKI Environment Variables
# Kopiere diese Datei nach .env und fülle die Werte aus

# API Keys
ANTHROPIC_API_KEY=your-anthropic-key-here
OPENAI_API_KEY=your-openai-key-here

# Security
JWT_SECRET=your-jwt-secret-here
SESSION_SECRET=your-session-secret-here

# External Services
GITHUB_TOKEN=your-github-token-here
DISCORD_WEBHOOK=your-discord-webhook-here
EOF

# Erstelle Start-Script
cat > "$INSTALL_DIR/start-simplyki.sh" << 'SCRIPT'
#!/bin/bash
# SimplyKI Startup Script

SIMPLYKI_HOME="${SIMPLYKI_HOME:-$(dirname "$0")}"
source "$SIMPLYKI_HOME/config/simplyki.conf"

echo "Starting SimplyKI Ecosystem..."

# Start ai-collab
if [ -f "$SIMPLYKI_HOME/components/ai-collab/start-ai-collab.sh" ]; then
    echo "Starting ai-collab..."
    cd "$SIMPLYKI_HOME/components/ai-collab"
    ./start-ai-collab.sh &
fi

# Start other services with docker-compose if available
if command -v docker-compose &> /dev/null; then
    echo "Starting Docker services..."
    cd "$SIMPLYKI_HOME"
    docker-compose up -d
else
    echo "Docker not available, start services manually"
fi

echo "SimplyKI is starting up!"
echo "Web Interface will be available at: http://localhost:$WEB_PORT"
echo "API Gateway at: http://localhost:$CORE_PORT"
SCRIPT

chmod +x "$INSTALL_DIR/start-simplyki.sh"

# Erstelle docker-compose.yml
cat > "$INSTALL_DIR/docker-compose.yml" << EOF
version: '3.8'

services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: \${DB_NAME:-simplyki}
      POSTGRES_USER: \${DB_USER:-simplyki}
      POSTGRES_PASSWORD: \${DB_PASS:-changeme}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "\${DB_PORT:-5432}:5432"

  redis:
    image: redis:7-alpine
    ports:
      - "\${REDIS_PORT:-6379}:6379"

  smartki-core:
    build: ./components/SmartKI
    ports:
      - "\${CORE_PORT:-3200}:3000"
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgresql://\${DB_USER}:\${DB_PASS}@postgres:\${DB_PORT}/\${DB_NAME}
      - REDIS_URL=redis://redis:6379
    depends_on:
      - postgres
      - redis

  smartki-web:
    build: ./components/SmartKI-web
    ports:
      - "\${WEB_PORT:-3000}:3000"
    environment:
      - REACT_APP_API_URL=http://localhost:\${CORE_PORT}
    depends_on:
      - smartki-core

volumes:
  postgres_data:
EOF

# Installation abschließen
echo
success "SimplyKI Installation abgeschlossen!"
echo
echo -e "${GREEN}Nächste Schritte:${NC}"
echo "1. Konfiguriere deine API-Keys:"
echo "   cp $INSTALL_DIR/config/.env.template $INSTALL_DIR/config/.env"
echo "   nano $INSTALL_DIR/config/.env"
echo
echo "2. Starte SimplyKI:"
echo "   cd $INSTALL_DIR"
echo "   ./start-simplyki.sh"
echo
echo "3. Öffne das Web Interface:"
echo "   http://localhost:3000"
echo
echo -e "${BLUE}Dokumentation:${NC} https://github.com/stlas/SimplyKI"
echo -e "${BLUE}Support:${NC} https://github.com/stlas/SimplyKI/issues"
echo
echo -e "${GREEN}Viel Spaß mit SimplyKI!${NC} 🚀"