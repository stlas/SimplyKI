#!/bin/bash
# SimplyKI Core Setup Script

VERSION="1.0.0"
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║                    SIMPLYKI SETUP                           ║${NC}"
echo -e "${PURPLE}║            Meta-Framework for AI Development Tools           ║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIMPLYKI_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Core-Konfiguration erstellen
init_core_config() {
    echo -e "${BLUE}=== CORE-KONFIGURATION INITIALISIEREN ===${NC}"
    
    local config_dir="$SIMPLYKI_ROOT/config"
    mkdir -p "$config_dir"
    
    # Haupt-Konfigurationsdatei
    if [ ! -f "$config_dir/simplyKI.json" ]; then
        cat > "$config_dir/simplyKI.json" << 'EOF'
{
  "platform": {
    "name": "SimplyKI",
    "version": "1.0.0",
    "description": "Meta-Framework for AI Development Tools"
  },
  "web": {
    "port": 3000,
    "host": "localhost",
    "api_prefix": "/api/v1",
    "frontend_framework": "vue"
  },
  "auth": {
    "enabled": true,
    "method": "jwt",
    "session_timeout": 3600,
    "require_auth": ["admin", "tools"]
  },
  "tools": {
    "auto_discovery": true,
    "tools_directory": "./tools",
    "plugin_directory": "./core/plugins",
    "enabled_tools": ["ai-collab"]
  },
  "monitoring": {
    "enabled": true,
    "log_level": "info",
    "cost_tracking": true,
    "analytics": true
  },
  "database": {
    "type": "sqlite",
    "path": "./data/simplyKI.db",
    "auto_migrate": true
  }
}
EOF
        echo -e "${GREEN}✅ Core-Konfiguration erstellt: $config_dir/simplyKI.json${NC}"
    fi
    
    # Environment-Template
    if [ ! -f "$config_dir/.env.template" ]; then
        cat > "$config_dir/.env.template" << 'EOF'
# SimplyKI Environment Configuration
# Kopiere diese Datei zu .env und passe die Werte an

# Web-Frontend
SIMPLYKI_PORT=3000
SIMPLYKI_HOST=localhost
SIMPLYKI_ENV=development

# Authentication
JWT_SECRET=your-secure-jwt-secret-here
SESSION_SECRET=your-secure-session-secret

# Database
DATABASE_URL=sqlite:./data/simplyKI.db

# Tool-Integration
TOOLS_AUTO_DISCOVERY=true
PLUGIN_HOTRELOAD=true

# Monitoring & Analytics
ENABLE_ANALYTICS=true
LOG_LEVEL=info
COST_TRACKING=true

# AI-Tool API Keys (falls zentral verwaltet)
ANTHROPIC_API_KEY=your-anthropic-key
OPENAI_API_KEY=your-openai-key

# Plugin-System
PLUGIN_SECURITY_LEVEL=strict
ALLOW_CUSTOM_PLUGINS=true
EOF
        echo -e "${GREEN}✅ Environment-Template erstellt: $config_dir/.env.template${NC}"
    fi
}

# Plugin-System initialisieren
init_plugin_system() {
    echo -e "${BLUE}=== PLUGIN-SYSTEM INITIALISIEREN ===${NC}"
    
    local plugin_dir="$SIMPLYKI_ROOT/core/plugins"
    mkdir -p "$plugin_dir"
    
    # Plugin-Registry
    cat > "$plugin_dir/registry.js" << 'EOF'
// SimplyKI Plugin Registry
// Zentrale Verwaltung aller verfügbaren Plugins

class PluginRegistry {
  constructor() {
    this.plugins = new Map();
    this.loadedPlugins = new Set();
  }
  
  // Plugin registrieren
  register(pluginDefinition) {
    const { name, version, config } = pluginDefinition;
    
    if (!name) {
      throw new Error('Plugin name is required');
    }
    
    this.plugins.set(name, {
      ...pluginDefinition,
      registeredAt: new Date(),
      status: 'registered'
    });
    
    console.log(`✅ Plugin registered: ${name} v${version}`);
    return true;
  }
  
  // Plugin laden
  async load(pluginName) {
    const plugin = this.plugins.get(pluginName);
    if (!plugin) {
      throw new Error(`Plugin not found: ${pluginName}`);
    }
    
    try {
      // Plugin-Initialisierung
      if (plugin.onInit) {
        await plugin.onInit();
      }
      
      plugin.status = 'loaded';
      this.loadedPlugins.add(pluginName);
      
      console.log(`🚀 Plugin loaded: ${pluginName}`);
      return plugin;
    } catch (error) {
      plugin.status = 'error';
      console.error(`❌ Plugin load failed: ${pluginName}`, error);
      throw error;
    }
  }
  
  // Alle verfügbaren Plugins auflisten
  list() {
    return Array.from(this.plugins.entries()).map(([name, plugin]) => ({
      name,
      version: plugin.version,
      description: plugin.description,
      status: plugin.status,
      registeredAt: plugin.registeredAt
    }));
  }
  
  // Plugin-Auto-Discovery
  async discoverPlugins(toolsDirectory = './tools') {
    const fs = require('fs').promises;
    const path = require('path');
    
    try {
      const toolDirs = await fs.readdir(toolsDirectory);
      
      for (const toolDir of toolDirs) {
        const pluginPath = path.join(toolsDirectory, toolDir, 'simplyKI-plugin.js');
        
        try {
          await fs.access(pluginPath);
          const plugin = require(path.resolve(pluginPath));
          
          if (plugin.default || plugin.name) {
            this.register(plugin.default || plugin);
          }
        } catch (err) {
          // Plugin-Datei nicht gefunden oder ungültig - überspringen
          continue;
        }
      }
      
      console.log(`🔍 Auto-discovery completed. Found ${this.plugins.size} plugins.`);
    } catch (error) {
      console.error('Plugin auto-discovery failed:', error);
    }
  }
}

module.exports = PluginRegistry;
EOF
    echo -e "${GREEN}✅ Plugin-Registry erstellt: $plugin_dir/registry.js${NC}"
    
    # Plugin-Loader
    cat > "$plugin_dir/loader.js" << 'EOF'
// SimplyKI Plugin Loader
// Lädt und verwaltet Plugin-Lifecycle

const PluginRegistry = require('./registry');

class PluginLoader {
  constructor(config = {}) {
    this.registry = new PluginRegistry();
    this.config = config;
    this.activePlugins = new Map();
  }
  
  // Alle Plugins initialisieren
  async initialize() {
    console.log('🔧 Initializing SimplyKI Plugin System...');
    
    // Auto-Discovery falls aktiviert
    if (this.config.autoDiscovery) {
      await this.registry.discoverPlugins(this.config.toolsDirectory);
    }
    
    // Enabled Tools laden
    if (this.config.enabledTools) {
      for (const toolName of this.config.enabledTools) {
        try {
          await this.loadPlugin(toolName);
        } catch (error) {
          console.warn(`⚠️ Failed to load enabled tool: ${toolName}`, error.message);
        }
      }
    }
    
    console.log(`✅ Plugin System initialized. ${this.activePlugins.size} plugins active.`);
  }
  
  // Einzelnes Plugin laden
  async loadPlugin(pluginName) {
    try {
      const plugin = await this.registry.load(pluginName);
      this.activePlugins.set(pluginName, plugin);
      
      // Plugin aktivieren
      if (plugin.onActivate) {
        await plugin.onActivate();
      }
      
      return plugin;
    } catch (error) {
      console.error(`Failed to load plugin: ${pluginName}`, error);
      throw error;
    }
  }
  
  // Plugin deaktivieren
  async unloadPlugin(pluginName) {
    const plugin = this.activePlugins.get(pluginName);
    if (!plugin) return;
    
    try {
      if (plugin.onDeactivate) {
        await plugin.onDeactivate();
      }
      
      this.activePlugins.delete(pluginName);
      console.log(`🔌 Plugin unloaded: ${pluginName}`);
    } catch (error) {
      console.error(`Failed to unload plugin: ${pluginName}`, error);
    }
  }
  
  // Plugin-Status abrufen
  getStatus() {
    return {
      total: this.registry.plugins.size,
      active: this.activePlugins.size,
      plugins: this.registry.list(),
      activePlugins: Array.from(this.activePlugins.keys())
    };
  }
}

module.exports = PluginLoader;
EOF
    echo -e "${GREEN}✅ Plugin-Loader erstellt: $plugin_dir/loader.js${NC}"
}

# Authentication-System
init_auth_system() {
    echo -e "${BLUE}=== AUTHENTICATION-SYSTEM INITIALISIEREN ===${NC}"
    
    local auth_dir="$SIMPLYKI_ROOT/core/auth"
    mkdir -p "$auth_dir"
    
    # Basis-Auth-Konfiguration
    cat > "$auth_dir/config.js" << 'EOF'
// SimplyKI Authentication Configuration

module.exports = {
  jwt: {
    algorithm: 'HS256',
    expiresIn: '1h',
    issuer: 'SimplyKI',
    audience: 'simplyKI-users'
  },
  
  users: {
    defaultRole: 'user',
    adminRole: 'admin',
    requiredPermissions: {
      'tools': ['read', 'execute'],
      'admin': ['read', 'write', 'execute', 'admin'],
      'api': ['read', 'write']
    }
  },
  
  security: {
    bcryptRounds: 12,
    sessionTimeout: 3600,
    maxLoginAttempts: 5,
    lockoutDuration: 900 // 15 Minuten
  }
};
EOF
    echo -e "${GREEN}✅ Auth-Konfiguration erstellt: $auth_dir/config.js${NC}"
}

# Datenbank initialisieren
init_database() {
    echo -e "${BLUE}=== DATENBANK INITIALISIEREN ===${NC}"
    
    local data_dir="$SIMPLYKI_ROOT/data"
    mkdir -p "$data_dir"
    
    # SQLite-Schema
    cat > "$data_dir/schema.sql" << 'EOF'
-- SimplyKI Database Schema

-- Benutzer
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    role VARCHAR(20) DEFAULT 'user',
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Sessions
CREATE TABLE IF NOT EXISTS sessions (
    id VARCHAR(128) PRIMARY KEY,
    user_id INTEGER NOT NULL,
    expires_at DATETIME NOT NULL,
    data TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Tools & Plugins
CREATE TABLE IF NOT EXISTS tools (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(50) UNIQUE NOT NULL,
    version VARCHAR(20) NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'inactive',
    config TEXT, -- JSON
    installed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Tool-Usage-Tracking
CREATE TABLE IF NOT EXISTS tool_usage (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    tool_name VARCHAR(50) NOT NULL,
    action VARCHAR(50) NOT NULL,
    cost DECIMAL(10,4) DEFAULT 0,
    duration INTEGER, -- Sekunden
    metadata TEXT, -- JSON
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- System-Logs
CREATE TABLE IF NOT EXISTS logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    level VARCHAR(10) NOT NULL,
    message TEXT NOT NULL,
    component VARCHAR(50),
    user_id INTEGER,
    metadata TEXT, -- JSON
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Standard-Admin-User einfügen
INSERT OR IGNORE INTO users (username, email, password_hash, full_name, role) 
VALUES ('admin', 'admin@simplyKI.local', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/lewfBmdQ.TUZFjw5K', 'SimplyKI Administrator', 'admin');

-- Claude-AI-User einfügen
INSERT OR IGNORE INTO users (username, email, password_hash, full_name, role) 
VALUES ('claude', 'claude@simplyKI.local', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/lewfBmdQ.TUZFjw5K', 'Claude AI Assistant', 'user');
EOF
    echo -e "${GREEN}✅ Datenbank-Schema erstellt: $data_dir/schema.sql${NC}"
    
    # SQLite-Datenbank initialisieren (falls sqlite3 verfügbar)
    if command -v sqlite3 &> /dev/null; then
        sqlite3 "$data_dir/simplyKI.db" < "$data_dir/schema.sql"
        echo -e "${GREEN}✅ SQLite-Datenbank initialisiert: $data_dir/simplyKI.db${NC}"
    else
        echo -e "${YELLOW}⚠️ sqlite3 nicht verfügbar - Schema bereit für manuelle Initialisierung${NC}"
    fi
}

# Web-Grundstruktur vorbereiten
init_web_structure() {
    echo -e "${BLUE}=== WEB-STRUKTUR INITIALISIEREN ===${NC}"
    
    local web_dir="$SIMPLYKI_ROOT/web"
    
    # Package.json für Web-Frontend
    cat > "$web_dir/package.json" << 'EOF'
{
  "name": "simplyKI-web",
  "version": "1.0.0",
  "description": "SimplyKI Web Frontend - Meta-Framework for AI Development Tools",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "serve": "node server.js"
  },
  "dependencies": {
    "vue": "^3.3.0",
    "vue-router": "^4.2.0",
    "pinia": "^2.1.0",
    "axios": "^1.5.0",
    "express": "^4.18.0",
    "cors": "^2.8.5",
    "helmet": "^7.0.0"
  },
  "devDependencies": {
    "@vitejs/plugin-vue": "^4.3.0",
    "vite": "^4.4.0",
    "tailwindcss": "^3.3.0",
    "autoprefixer": "^10.4.0",
    "postcss": "^8.4.0"
  },
  "keywords": ["AI", "development", "tools", "meta-framework", "SimplyKI"],
  "author": "sTLAs <stlas@example.com>",
  "license": "MIT"
}
EOF
    echo -e "${GREEN}✅ Web-Package.json erstellt: $web_dir/package.json${NC}"
    
    # Basis-Server für Development
    cat > "$web_dir/server.js" << 'EOF'
// SimplyKI Development Server
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.SIMPLYKI_PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'dist')));

// API Routes
app.get('/api/v1/status', (req, res) => {
  res.json({
    status: 'ok',
    platform: 'SimplyKI',
    version: '1.0.0',
    uptime: process.uptime()
  });
});

app.get('/api/v1/tools', (req, res) => {
  res.json({
    tools: [
      {
        name: 'ai-collab',
        version: '2.1.0',
        status: 'active',
        description: 'AI Development Collaboration Assistant'
      }
    ]
  });
});

// SPA Fallback
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'dist', 'index.html'));
});

app.listen(PORT, () => {
  console.log(`🌐 SimplyKI Web Server running on http://localhost:${PORT}`);
  console.log(`📊 API available at http://localhost:${PORT}/api/v1`);
});
EOF
    echo -e "${GREEN}✅ Development-Server erstellt: $web_dir/server.js${NC}"
    
    # Basis-HTML-Template
    cat > "$web_dir/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>SimplyKI - Meta-Framework for AI Development Tools</title>
  <meta name="description" content="Unified platform for cost-optimized AI-powered software development" />
  <link rel="icon" type="image/svg+xml" href="/assets/logo.svg" />
</head>
<body>
  <div id="app">
    <div class="loading">
      <h1>🚀 SimplyKI</h1>
      <p>Loading Meta-Framework for AI Development Tools...</p>
    </div>
  </div>
  <script type="module" src="/src/main.js"></script>
  
  <style>
    body {
      margin: 0;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
    }
    
    .loading {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      height: 100vh;
      text-align: center;
    }
    
    .loading h1 {
      font-size: 3rem;
      margin-bottom: 1rem;
      animation: pulse 2s infinite;
    }
    
    @keyframes pulse {
      0%, 100% { opacity: 1; }
      50% { opacity: 0.7; }
    }
  </style>
</body>
</html>
EOF
    echo -e "${GREEN}✅ HTML-Template erstellt: $web_dir/index.html${NC}"
}

# Git-Konfiguration
init_git_config() {
    echo -e "${BLUE}=== GIT-KONFIGURATION ===${NC}"
    
    # .gitignore
    cat > "$SIMPLYKI_ROOT/.gitignore" << 'EOF'
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Environment
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Database
data/*.db
data/*.sqlite
*.db-journal

# Build outputs
dist/
build/
.vite/
.cache/

# Logs
logs/
*.log

# Temporary files
tmp/
temp/
.tmp/

# IDEs
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Tool-specific
tools/*/local/
tools/*/temp/
tools/*/.env

# Plugin cache
core/plugins/cache/
EOF
    echo -e "${GREEN}✅ .gitignore erstellt${NC}"
    
    # README für Unterverzeichnisse
    local dirs=("core" "web" "tools" "docs" "config")
    for dir in "${dirs[@]}"; do
        if [ ! -f "$SIMPLYKI_ROOT/$dir/README.md" ]; then
            case $dir in
                "core")
                    echo "# 🏛️ SimplyKI Core Infrastructure

Gemeinsame Basis-Infrastruktur für alle SimplyKI-Tools:

- **auth/** - Authentifizierung und Benutzerverwaltung
- **config/** - Zentrale Konfigurationsverwaltung  
- **plugins/** - Plugin-System für Tool-Integration
- **utils/** - Gemeinsame Utilities und Hilfsfunktionen

## Setup

\`\`\`bash
./setup.sh  # Core-System initialisieren
\`\`\`" > "$SIMPLYKI_ROOT/$dir/README.md"
                    ;;
                "web")
                    echo "# 🌐 SimplyKI Web Frontend

Browser-basierte Benutzeroberfläche für das SimplyKI Meta-Framework.

## Development

\`\`\`bash
npm install
npm run dev  # Development-Server starten
\`\`\`

## Struktur

- **dashboard/** - Zentrale Übersicht aller Tools
- **api/** - REST-API für Tool-Kommunikation
- **assets/** - Statische Ressourcen (CSS, JS, Images)" > "$SIMPLYKI_ROOT/$dir/README.md"
                    ;;
                "tools")
                    echo "# 🔧 SimplyKI Tools

Sammlung der verfügbaren KI-Development-Tools.

## Verfügbare Tools

- **ai-collab/** - AI Development Collaboration Assistant (Submodul)

## Neues Tool hinzufügen

\`\`\`bash
git submodule add https://github.com/user/tool.git tools/tool-name
\`\`\`" > "$SIMPLYKI_ROOT/$dir/README.md"
                    ;;
                "docs")
                    echo "# 📚 SimplyKI Dokumentation

Umfassende Dokumentation für das SimplyKI Meta-Framework.

## Struktur

- **api/** - Technische API-Dokumentation
- **user-guide/** - Benutzerhandbuch
- **developer/** - Entwickler-Dokumentation und Plugin-Guides" > "$SIMPLYKI_ROOT/$dir/README.md"
                    ;;
                "config")
                    echo "# ⚙️ SimplyKI Konfiguration

Zentrale Konfigurationsdateien für das SimplyKI-System.

## Dateien

- **simplyKI.json** - Haupt-Konfiguration
- **.env.template** - Environment-Variablen Template
- **.env** - Lokale Environment-Variablen (nicht versioniert)" > "$SIMPLYKI_ROOT/$dir/README.md"
                    ;;
            esac
            echo -e "${GREEN}✅ README erstellt: $dir/README.md${NC}"
        fi
    done
}

# Hauptausführung
main() {
    echo -e "${CYAN}🚀 Starte SimplyKI Core Setup...${NC}"
    echo ""
    
    init_core_config
    echo ""
    init_plugin_system
    echo ""
    init_auth_system
    echo ""
    init_database
    echo ""
    init_web_structure
    echo ""
    init_git_config
    echo ""
    
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                    SETUP ABGESCHLOSSEN                      ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${GREEN}✅ SimplyKI Core erfolgreich initialisiert!${NC}"
    echo ""
    echo -e "${CYAN}🔧 Nächste Schritte:${NC}"
    echo -e "${YELLOW}1. Environment-Variablen konfigurieren:${NC}"
    echo "   cp config/.env.template config/.env"
    echo "   nano config/.env"
    echo ""
    echo -e "${YELLOW}2. ai-collab als erstes Tool hinzufügen:${NC}"
    echo "   git submodule add https://github.com/stlas/ai-collab.git tools/ai-collab"
    echo ""
    echo -e "${YELLOW}3. Web-Frontend starten:${NC}"
    echo "   cd web && npm install && npm run dev"
    echo ""
    echo -e "${YELLOW}4. SimplyKI Web-Interface öffnen:${NC}"
    echo "   http://localhost:3000"
    echo ""
    echo -e "${CYAN}📖 Dokumentation: docs/user-guide/getting-started.md${NC}"
}

# Script ausführen
main "$@"