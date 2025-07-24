# HCS - Hybrid Context System

## Übersicht
Das Hybrid Context System (HCS) ermöglicht intelligentes Kontext-Management für AI-Entwicklung.

## Features
- Automatische Kontext-Wiederherstellung
- Vector-basierte Ähnlichkeitssuche
- Smart Memory Management
- Cross-Session Context Sharing

## Installation
```bash
cd modules/hcs
./setup.sh
```

## Verwendung
```bash
# Status prüfen
./src/hybrid-context-manager.sh status

# Auto-Detection
./src/hcs-auto-detect.sh
```

## Dateien
- `hybrid-context-manager.sh` - Hauptmanager
- `hcs-auto-detect.sh` - Auto-Detection
- `hcs-vector-store.sh` - Vector Storage
