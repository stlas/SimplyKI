# 🚀 SimplyKI Quick Start Guide

Willkommen bei SimplyKI! In 5 Minuten einsatzbereit.

## 📋 Voraussetzungen

- Linux/macOS (Windows via WSL)
- Git
- Bash 4.0+
- (Optional) Rust für BrainMemory

## 🎯 1-Minute Setup

```bash
# Clone Repository
git clone https://github.com/stlas/SimplyKI.git
cd SimplyKI

# Mache SimplyKI ausführbar
chmod +x bin/simplyKI

# Test Installation
./bin/simplyKI status
```

## 🧠 Module Overview

### Verfügbare Module
- **hcs** - Hybrid Context System (Kontext-Management)
- **pkg** - Package Manager (Modul-Verwaltung)  
- **backup** - Backup System (Differential Backups)
- **optimizemax** - Cost Optimizer (API-Kosten sparen)
- **neustart** - Session Recovery (Auto-Wiederherstellung)
- **brainmemory** - Brain-like Memory (100x Performance) 🆕

## 💻 Basis-Befehle

```bash
# System Status
./bin/simplyKI status

# HCS verwenden
./bin/simplyKI hcs status
./bin/simplyKI hcs store "key" "value"
./bin/simplyKI hcs retrieve "key"

# Package Manager
./bin/simplyKI pkg list
./bin/simplyKI pkg install <module>

# Backup erstellen
./bin/simplyKI backup create
./bin/simplyKI backup list
```

## 🦀 BrainMemory Setup (Optional)

```bash
# Rust installieren
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env

# BrainMemory bauen
cd modules/brainmemory
cargo build --release

# Testen
./target/release/brainmemory
```

## 🔧 Konfiguration

### API Keys
```bash
# Erstelle Config
cp config/settings.example.json config/settings.json

# Editiere settings.json
{
  "api_keys": {
    "anthropic": "your-key-here"
  }
}
```

### Environment
```bash
# .env Datei
export SIMPLYKIROOT=/path/to/SimplyKI
export ANTHROPIC_API_KEY=your-key
```

## 📁 Projekt-Struktur

```
SimplyKI/
├── bin/          # Ausführbare Scripts
├── core/         # Kern-System
├── modules/      # Alle Module
│   ├── hcs/
│   ├── pkg/
│   └── ...
├── config/       # Konfiguration
└── docs/         # Dokumentation
```

## 🎓 Nächste Schritte

1. **Erkunde Module**: `ls modules/` 
2. **Lese Docs**: `cat modules/*/README.md`
3. **Probiere HCS**: `./bin/simplyKI hcs --help`
4. **Installiere Rust**: Für BrainMemory Performance

## 🆘 Hilfe

- **Issues**: [GitHub Issues](https://github.com/stlas/SimplyKI/issues)
- **Docs**: `/docs` Verzeichnis
- **Community**: Coming soon!

## 🎉 Fertig!

Du bist bereit mit SimplyKI zu arbeiten! 

**Pro-Tipp**: Füge `alias ski='/path/to/SimplyKI/bin/simplyKI'` zu deiner `.bashrc` hinzu für schnelleren Zugriff.

---

Happy Coding! 🚀