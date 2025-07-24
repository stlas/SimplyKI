#!/bin/bash
# Created: 2025-07-21 01:00:00 CEST
# neustart-auto-updater.sh - Automatisches NEUSTART Update-System

# Farben
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Basis-Verzeichnisse
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CLAUDE_DIR="$PROJECT_ROOT/.claude"
RUNTIME_DIR="$CLAUDE_DIR/runtime"

# Konfiguration
UPDATE_INTERVAL=${NEUSTART_UPDATE_INTERVAL:-300}  # Standard: 5 Minuten
CURRENT_NEUSTART=""
UPDATE_PID_FILE="$RUNTIME_DIR/neustart-updater.pid"

# Log-Funktion
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [NEUSTART-UPDATER] $1" >> "$CLAUDE_DIR/auto-restore.log"
}

# NEUSTART-Datei finden oder erstellen
get_or_create_neustart() {
    # Suche aktuelle NEUSTART vom heutigen Tag
    local today=$(date +"%Y-%m-%d")
    CURRENT_NEUSTART=$(ls -t "$PROJECT_ROOT"/NEUSTART-${today}*.md 2>/dev/null | head -1)
    
    if [[ -z "$CURRENT_NEUSTART" ]]; then
        # Keine heutige NEUSTART - erstelle neue
        echo -e "${BLUE}📝 Erstelle neue NEUSTART-Datei...${NC}"
        "$SCRIPT_DIR/create-neustart.sh"
        CURRENT_NEUSTART=$(ls -t "$PROJECT_ROOT"/NEUSTART-${today}*.md 2>/dev/null | head -1)
        log "Neue NEUSTART erstellt: $CURRENT_NEUSTART"
    else
        log "Verwende bestehende NEUSTART: $CURRENT_NEUSTART"
    fi
}

# NEUSTART-Datei aktualisieren
update_neustart() {
    if [[ ! -f "$CURRENT_NEUSTART" ]]; then
        get_or_create_neustart
    fi
    
    local update_marker="<!-- LAST-AUTO-UPDATE: $(date +'%Y-%m-%d %H:%M:%S %Z') -->"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S %Z")
    
    # Erstelle Update-Sektion
    local update_content="

## 🔄 Auto-Update: $timestamp

### Aktueller Status
- Session läuft seit: $(uptime -p | sed 's/up //')
- Aktive Prozesse: $(pgrep -f "claude|ai-collab" | wc -l)
- Memory-Nutzung: $(free -h | grep Mem | awk '{print $3 "/" $2}')

### Git-Status Update
\`\`\`
$(cd "$PROJECT_ROOT" && git status --short | head -10)
\`\`\`

### Offene Dateien
$(lsof -p $$ 2>/dev/null | grep -E "\.sh$|\.md$|\.js$" | awk '{print "- " $9}' | sort -u | head -10)

### Letzte Befehle
$(history 2>/dev/null | tail -5 | sed 's/^[[:space:]]*[0-9]*[[:space:]]*//; s/^/- /' || echo "- History nicht verfügbar")

$update_marker"

    # Prüfe ob bereits ein Auto-Update Marker existiert
    if grep -q "<!-- LAST-AUTO-UPDATE:" "$CURRENT_NEUSTART"; then
        # Ersetze den letzten Update-Block
        # Erstelle temporäre Datei
        local temp_file="/tmp/neustart_update_$$"
        
        # Kopiere bis zum ersten Auto-Update
        sed '/## 🔄 Auto-Update:/,$d' "$CURRENT_NEUSTART" > "$temp_file"
        
        # Füge neuen Update-Block hinzu
        echo "$update_content" >> "$temp_file"
        
        # Ersetze Original
        mv "$temp_file" "$CURRENT_NEUSTART"
        log "NEUSTART aktualisiert (replaced)"
    else
        # Füge Update-Block am Ende hinzu
        echo "$update_content" >> "$CURRENT_NEUSTART"
        log "NEUSTART aktualisiert (appended)"
    fi
}

# Update-Loop
start_update_loop() {
    echo $$ > "$UPDATE_PID_FILE"
    log "Update-Loop gestartet (PID: $$, Interval: ${UPDATE_INTERVAL}s)"
    
    while true; do
        sleep "$UPDATE_INTERVAL"
        
        # Prüfe ob Claude noch läuft
        if ! pgrep -f "claude" > /dev/null; then
            log "Claude nicht mehr aktiv - beende Update-Loop"
            break
        fi
        
        update_neustart
    done
    
    rm -f "$UPDATE_PID_FILE"
    log "Update-Loop beendet"
}

# Stoppe bestehenden Updater
stop_updater() {
    if [[ -f "$UPDATE_PID_FILE" ]]; then
        local pid=$(cat "$UPDATE_PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid"
            echo -e "${GREEN}✓ NEUSTART-Updater gestoppt (PID: $pid)${NC}"
            log "Updater gestoppt"
        fi
        rm -f "$UPDATE_PID_FILE"
    fi
}

# Status anzeigen
show_status() {
    echo -e "${BLUE}📊 NEUSTART Auto-Updater Status${NC}"
    echo "================================"
    
    if [[ -f "$UPDATE_PID_FILE" ]]; then
        local pid=$(cat "$UPDATE_PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            echo -e "Status: ${GREEN}✓ Aktiv${NC}"
            echo "PID: $pid"
            echo "Update-Intervall: ${UPDATE_INTERVAL}s"
            echo "Aktuelle NEUSTART: ${CURRENT_NEUSTART:-'Noch nicht gesetzt'}"
        else
            echo -e "Status: ${RED}✗ PID-Datei vorhanden, aber Prozess läuft nicht${NC}"
        fi
    else
        echo -e "Status: ${YELLOW}○ Nicht aktiv${NC}"
    fi
}

# Hauptfunktion
main() {
    mkdir -p "$RUNTIME_DIR"
    
    case "${1:-start}" in
        start)
            # Prüfe ob bereits läuft
            if [[ -f "$UPDATE_PID_FILE" ]]; then
                local pid=$(cat "$UPDATE_PID_FILE")
                if kill -0 "$pid" 2>/dev/null; then
                    echo -e "${YELLOW}⚠ NEUSTART-Updater läuft bereits (PID: $pid)${NC}"
                    exit 0
                fi
            fi
            
            # Starte im Hintergrund
            get_or_create_neustart
            echo -e "${GREEN}✓ Starte NEUSTART Auto-Updater${NC}"
            echo "  Update-Intervall: ${UPDATE_INTERVAL}s"
            echo "  NEUSTART-Datei: $(basename "$CURRENT_NEUSTART")"
            
            nohup bash -c "$0 loop" > /dev/null 2>&1 &
            echo -e "${GREEN}✓ Updater gestartet (PID: $!)${NC}"
            ;;
            
        loop)
            start_update_loop
            ;;
            
        stop)
            stop_updater
            ;;
            
        status)
            show_status
            ;;
            
        update)
            # Einmaliges Update
            get_or_create_neustart
            update_neustart
            echo -e "${GREEN}✓ NEUSTART manuell aktualisiert${NC}"
            ;;
            
        help|*)
            echo "NEUSTART Auto-Updater - Automatische Session-Dokumentation"
            echo ""
            echo "Verwendung: $0 {start|stop|status|update|help}"
            echo ""
            echo "Befehle:"
            echo "  start   - Startet automatische Updates"
            echo "  stop    - Stoppt den Update-Prozess"
            echo "  status  - Zeigt aktuellen Status"
            echo "  update  - Einmaliges manuelles Update"
            echo "  help    - Zeigt diese Hilfe"
            echo ""
            echo "Umgebungsvariablen:"
            echo "  NEUSTART_UPDATE_INTERVAL - Update-Intervall in Sekunden (Standard: 300)"
            ;;
    esac
}

# Script ausführen
main "$@"