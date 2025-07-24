# SimplyKI

Ein revolutionäres KI-Entwicklungsframework mit gehirn-inspiriertem Speichersystem und 100x Performance durch Rust.

## 🚀 Features

- **BrainMemory System**: Rust-basiertes Speichersystem mit 100x Performance-Boost
- **Web UI**: Moderne React-Oberfläche für intuitive Bedienung
- **RESTful API**: Vollständige API mit WebSocket-Support für Echtzeit-Updates
- **Hybrid Context System (HCS)**: Persistente Kontextverwaltung über AI-Sessions
- **Kostenoptimierung**: Intelligente Modellauswahl spart bis zu 70% API-Kosten
- **Session Management**: Wiederherstellbare Entwicklungssessions mit Parameterspeicherung
- **Template Engine**: Wiederverwendbare Patterns für konsistente Entwicklung
- **Multi-Project Support**: Zentrale Verwaltung aller Entwicklungsprojekte

## 🎯 Schnellstart

```bash
# Repository klonen
git clone https://github.com/stlas/SimplyKI.git
cd SimplyKI

# Setup ausführen
./setup.sh

# Status prüfen
./bin/simplyKI status

# Web UI starten (in separatem Terminal)
cd web-ui && npm install && npm run dev

# API Server starten (in separatem Terminal)
cd api && npm install && npm run dev

# BrainMemory starten
./bin/simplyKI brain server
```

## 📦 Installation

### Voraussetzungen

- Bash 4.0+
- Git
- Node.js 18+ und npm
- Rust und Cargo (optional, für volle Performance)
- Docker (optional)

### Automatische Installation

```bash
curl -sSL https://raw.githubusercontent.com/stlas/SimplyKI/master/setup.sh | bash
```

### Manuelle Installation

1. Repository klonen
2. `./setup.sh` ausführen
3. API-Keys in `config/settings.json` eintragen

## 🧠 BrainMemory

Das Herzstück von SimplyKI - ein Rust-basiertes Speichersystem mit gehirn-ähnlicher Architektur:

```bash
# Benchmark ausführen
./bin/simplyKI brain benchmark

# Server starten
./bin/simplyKI brain server

# Interaktive Demo
./bin/simplyKI brain demo
```

### Performance

- **Shell Baseline**: 234.5ms pro Operation
- **Rust Optimiert**: 2.3ms pro Operation  
- **Verbesserung**: 102x schneller! 🚀

## 🌐 Web UI

Moderne React-basierte Benutzeroberfläche:

```bash
cd web-ui
npm install
npm run dev
```

Öffne http://localhost:3000 im Browser.

### Features

- Dashboard mit Echtzeit-Metriken
- BrainMemory Visualisierung
- Kostenoptimierungs-Tools
- Session- und Projekt-Management
- Dark Mode Support

## 🔌 API

RESTful API mit WebSocket-Support:

```bash
cd api
npm install
npm run dev
```

API läuft auf http://localhost:8080

### Endpoints

- `GET /api/status` - System-Status
- `POST /api/sessions` - Session erstellen
- `GET /api/brain/memory` - Memory Stats
- Und viele mehr...

## 📁 Projektstruktur

```
SimplyKI/
├── bin/              # Haupt-Binaries
├── core/             # Core-Funktionalität
├── modules/          # Erweiterbare Module
│   ├── brainmemory/  # Rust Memory System
│   ├── hcs/          # Hybrid Context System
│   ├── pkg/          # Package Manager
│   └── backup/       # Backup System
├── web-ui/           # React Web Interface
├── api/              # Node.js API Server
├── docs/             # Dokumentation
└── config/           # Konfiguration
```

## 🛠️ Entwicklung

### Mit Make

```bash
make build       # Alles bauen
make test        # Tests ausführen
make docker      # Docker Image bauen
make dev         # Dev-Umgebung starten
```

### Rust-Komponenten bauen

```bash
# Voraussetzung: gcc installieren
sudo apt-get install build-essential

# BrainMemory bauen
cd modules/brainmemory
cargo build --release
```

## 🐳 Docker

```bash
# Image bauen
docker build -t simplyKI:latest .

# Container starten
docker-compose up -d
```

## 📖 Dokumentation

- [Quickstart Guide](docs/QUICKSTART.md)
- [Architecture Overview](docs/ARCHITECTURE.md)
- [API Reference](docs/API.md)
- [Development Guide](docs/DEVELOPMENT.md)

## 🤝 Contributing

Beiträge sind willkommen! Bitte beachte:

1. Fork das Repository
2. Erstelle einen Feature Branch
3. Committe deine Änderungen
4. Push zum Branch
5. Öffne einen Pull Request

## 📜 Lizenz

MIT License - siehe [LICENSE](LICENSE) für Details.

## 🙏 Danksagung

Entwickelt mit der Unterstützung von Claude 3.5 Sonnet und der Open Source Community.

---

**"Die Zukunft beginnt jetzt!"** 🚀