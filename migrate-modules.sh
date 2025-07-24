#!/bin/bash
# Migriere alle Module zur neuen Struktur
# Erstellt: 2025-07-24 14:10:00 CEST

echo "🚀 Migriere Module zur neuen SimplyKI Struktur..."

# Backup Manager
echo "📦 Migriere Backup..."
cp /home/aicollab/core/src/backup-manager.sh modules/backup/src/ 2>/dev/null
cp /home/aicollab/core/src/lightweight-monitor.sh modules/backup/src/ 2>/dev/null

# PKG Manager
echo "📦 Migriere PKG..."
cp /home/aicollab/core/src/pkg-manager.sh modules/pkg/src/ 2>/dev/null
cp /home/aicollab/core/src/pkg-*.sh modules/pkg/src/ 2>/dev/null

# OptimizeMax
echo "📦 Migriere OptimizeMax..."
cp -r /home/aicollab/OptimizeMax/* modules/optimizemax/docs/ 2>/dev/null
echo "# OptimizeMax Module" > modules/optimizemax/README.md

# Cost Optimizer (Teil von OptimizeMax)
cp /home/aicollab/core/src/cost-optimizer.sh modules/optimizemax/src/ 2>/dev/null

# Session Manager (Core bleibt vorerst)
echo "📦 Core-Module bleiben in core/..."

# Erstelle Module-Index
cat > modules/README.md << 'EOF'
# SimplyKI Modules

## Struktur
Jedes Modul folgt dieser Struktur:
```
module-name/
├── README.md      # Modul-Dokumentation
├── src/           # Source Code
├── docs/          # Erweiterte Dokumentation
├── tests/         # Tests
└── setup.sh       # Installation Script
```

## Verfügbare Module

### hcs - Hybrid Context System
Intelligentes Kontext-Management mit Vector Store Support.

### pkg - Package Manager
Modul-Management für SimplyKI.

### backup - Backup System
Differential Backup mit Monitoring.

### optimizemax - Cost Optimizer
Intelligente Kostenoptimierung für AI APIs.

### neustart - Session Recovery
Automatische Session-Wiederherstellung.

### brainmemory - Brain-like Memory (Planned)
Rust-basiertes gehirnähnliches Speichersystem.
EOF

echo "✅ Migration abgeschlossen!"
echo ""
echo "Nächste Schritte:"
echo "1. ./bin/simplyKI status"
echo "2. git add modules/"
echo "3. git commit -m 'feat: Migrate to new modules structure'"