#!/bin/bash
# Created: 2025-07-21 01:15:00 CEST
# hcs-context-optimizer.sh - Intelligente Kontext-Größenverwaltung für HCS

# Farben
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Basis-Verzeichnisse
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CLAUDE_DIR="$PROJECT_ROOT/.claude"
CONTEXT_DIR="$CLAUDE_DIR/context"
COMPRESSED_DIR="$CONTEXT_DIR/compressed"
SUMMARIES_DIR="$CONTEXT_DIR/summaries"

# Konfiguration
MAX_FILE_SIZE=256000  # 256KB - Claude's Limit
MAX_CONTEXT_TOTAL=2000000  # 2MB - Gesamt-Kontext-Budget
COMPRESSION_THRESHOLD=100000  # 100KB - Ab dieser Größe komprimieren
MONITOR_INTERVAL=${CONTEXT_MONITOR_INTERVAL:-600}  # Standard: 10 Minuten

# Log-Funktion
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [CONTEXT-OPTIMIZER] $1" >> "$CLAUDE_DIR/context-optimizer.log"
}

# Initialisierung
init_optimizer() {
    mkdir -p "$COMPRESSED_DIR" "$SUMMARIES_DIR"
    log "Context Optimizer initialisiert"
}

# Dateigröße prüfen
check_file_size() {
    local file="$1"
    local size=$(stat -c%s "$file" 2>/dev/null || echo 0)
    echo "$size"
}

# Kontext-Status analysieren
analyze_context() {
    echo -e "${BLUE}📊 Analysiere Kontext-Größen...${NC}"
    
    local total_size=0
    local large_files=()
    local compressed_count=0
    
    # Prüfe CLAUDE.md
    if [[ -f "$PROJECT_ROOT/CLAUDE.md" ]]; then
        local size=$(check_file_size "$PROJECT_ROOT/CLAUDE.md")
        total_size=$((total_size + size))
        if [[ $size -gt $COMPRESSION_THRESHOLD ]]; then
            large_files+=("CLAUDE.md:$size")
        fi
    fi
    
    # Prüfe NEUSTART-Dateien
    for file in "$PROJECT_ROOT"/NEUSTART-*.md; do
        if [[ -f "$file" ]]; then
            local size=$(check_file_size "$file")
            total_size=$((total_size + size))
            if [[ $size -gt $COMPRESSION_THRESHOLD ]]; then
                large_files+=("$(basename "$file"):$size")
            fi
        fi
    done
    
    # Prüfe Memory-Dateien
    for file in "$CLAUDE_DIR/memory/current"/*.md; do
        if [[ -f "$file" ]]; then
            local size=$(check_file_size "$file")
            total_size=$((total_size + size))
            if [[ $size -gt $COMPRESSION_THRESHOLD ]]; then
                large_files+=("memory/$(basename "$file"):$size")
            fi
        fi
    done
    
    # Status-Report
    echo "Gesamt-Kontext: $(numfmt --to=iec-i --suffix=B $total_size)"
    echo "Max erlaubt: $(numfmt --to=iec-i --suffix=B $MAX_CONTEXT_TOTAL)"
    echo "Große Dateien (>${COMPRESSION_THRESHOLD} bytes): ${#large_files[@]}"
    
    # Warnung bei Überschreitung
    if [[ $total_size -gt $MAX_CONTEXT_TOTAL ]]; then
        echo -e "${RED}⚠️  Kontext-Budget überschritten!${NC}"
        return 1
    elif [[ $total_size -gt $((MAX_CONTEXT_TOTAL * 80 / 100)) ]]; then
        echo -e "${YELLOW}⚠️  Kontext bei 80% des Budgets${NC}"
        return 2
    else
        echo -e "${GREEN}✅ Kontext-Größe OK${NC}"
        return 0
    fi
}

# Datei komprimieren mit Smart Summary
compress_file() {
    local file="$1"
    local basename=$(basename "$file")
    local compressed_file="$COMPRESSED_DIR/${basename}.compressed"
    local summary_file="$SUMMARIES_DIR/${basename}.summary"
    
    echo -e "${BLUE}🗜️  Komprimiere $basename...${NC}"
    
    # 1. Erstelle Smart Summary
    cat > "$summary_file" << EOF
# Komprimierte Datei: $basename
Originalgröße: $(numfmt --to=iec-i --suffix=B $(check_file_size "$file"))
Komprimiert am: $(date +'%Y-%m-%d %H:%M:%S')

## Wichtigste Inhalte
EOF
    
    # 2. Extrahiere wichtige Abschnitte
    if [[ "$basename" == "CLAUDE.md" ]]; then
        # Für CLAUDE.md: Behalte Hauptstruktur
        grep -E "^#+ |^- \*\*.*\*\*:|^export |^alias " "$file" | head -50 >> "$summary_file"
    elif [[ "$basename" == NEUSTART-*.md ]]; then
        # Für NEUSTART: Behalte Status und aktuelle Tasks
        sed -n '/^## Aktueller Status/,/^## /p' "$file" | head -30 >> "$summary_file"
        echo "" >> "$summary_file"
        sed -n '/^### Aktuelle Aufgaben/,/^### /p' "$file" | head -20 >> "$summary_file"
    else
        # Für andere Dateien: Erste und letzte Zeilen
        head -20 "$file" >> "$summary_file"
        echo -e "\n[... $(wc -l < "$file") Zeilen komprimiert ...]\n" >> "$summary_file"
        tail -10 "$file" >> "$summary_file"
    fi
    
    # 3. Komprimiere Original
    gzip -c "$file" > "$compressed_file"
    
    # 4. Ersetze Original durch Summary + Link
    cat > "$file" << EOF
# 🗜️ Datei komprimiert

Diese Datei wurde automatisch komprimiert, um Kontext-Platz zu sparen.

- **Original**: $compressed_file
- **Größe**: $(numfmt --to=iec-i --suffix=B $(check_file_size "$compressed_file")) (komprimiert)
- **Summary**: $summary_file

## Zusammenfassung
$(cat "$summary_file" | tail -n +5 | head -30)

---
*Verwende \`zcat $compressed_file\` um die vollständige Datei zu lesen*
EOF
    
    log "Komprimiert: $basename ($(check_file_size "$file") bytes -> $(check_file_size "$compressed_file") bytes)"
    echo -e "${GREEN}✅ Komprimiert: $(numfmt --to=iec-i --suffix=B $(check_file_size "$compressed_file"))${NC}"
}

# Kontext optimieren
optimize_context() {
    echo -e "${BLUE}🔧 Optimiere Kontext...${NC}"
    
    # 1. Finde große Dateien
    local files_to_compress=()
    
    # NEUSTART-Dateien älter als heute
    local today=$(date +%Y-%m-%d)
    for file in "$PROJECT_ROOT"/NEUSTART-*.md; do
        if [[ -f "$file" ]] && [[ ! "$file" =~ NEUSTART-${today} ]]; then
            local size=$(check_file_size "$file")
            if [[ $size -gt $COMPRESSION_THRESHOLD ]]; then
                files_to_compress+=("$file")
            fi
        fi
    done
    
    # Memory-Dateien in completed
    for file in "$CLAUDE_DIR/memory/completed"/**/*.md; do
        if [[ -f "$file" ]]; then
            local size=$(check_file_size "$file")
            if [[ $size -gt $COMPRESSION_THRESHOLD ]]; then
                files_to_compress+=("$file")
            fi
        fi
    done
    
    # 2. Komprimiere Dateien
    for file in "${files_to_compress[@]}"; do
        compress_file "$file"
    done
    
    # 3. Archiviere alte Snapshots
    find "$CONTEXT_DIR/snapshots" -type d -mtime +7 -print0 | while IFS= read -r -d '' dir; do
        local archive_name="$(basename "$dir").tar.gz"
        echo "Archiviere alten Snapshot: $(basename "$dir")"
        tar -czf "$CONTEXT_DIR/archives/$archive_name" -C "$CONTEXT_DIR/snapshots" "$(basename "$dir")"
        rm -rf "$dir"
    done
    
    echo -e "${GREEN}✅ Kontext-Optimierung abgeschlossen${NC}"
}

# Monitoring-Loop
start_monitor() {
    log "Context Monitor gestartet (Interval: ${MONITOR_INTERVAL}s)"
    
    while true; do
        sleep "$MONITOR_INTERVAL"
        
        # Analysiere Kontext
        if ! analyze_context > /dev/null; then
            # Bei Problemen optimieren
            optimize_context
        fi
    done
}

# Kontext-Report erstellen
generate_report() {
    local report_file="$CONTEXT_DIR/context-report-$(date +%Y%m%d-%H%M%S).md"
    
    cat > "$report_file" << EOF
# HCS Context Report
Generated: $(date +'%Y-%m-%d %H:%M:%S')

## Übersicht
EOF
    
    # Dateigrößen sammeln
    echo -e "\n### Dateigrößen\n" >> "$report_file"
    echo "| Datei | Größe | Status |" >> "$report_file"
    echo "|-------|-------|--------|" >> "$report_file"
    
    # CLAUDE.md
    if [[ -f "$PROJECT_ROOT/CLAUDE.md" ]]; then
        local size=$(check_file_size "$PROJECT_ROOT/CLAUDE.md")
        local status="✅ OK"
        [[ $size -gt $MAX_FILE_SIZE ]] && status="⚠️ Zu groß"
        echo "| CLAUDE.md | $(numfmt --to=iec-i --suffix=B $size) | $status |" >> "$report_file"
    fi
    
    # NEUSTART-Dateien
    for file in "$PROJECT_ROOT"/NEUSTART-*.md; do
        if [[ -f "$file" ]]; then
            local size=$(check_file_size "$file")
            local status="✅ OK"
            [[ $size -gt $MAX_FILE_SIZE ]] && status="⚠️ Zu groß"
            echo "| $(basename "$file") | $(numfmt --to=iec-i --suffix=B $size) | $status |" >> "$report_file"
        fi
    done
    
    # Gesamt-Statistik
    echo -e "\n### Gesamt-Statistik\n" >> "$report_file"
    analyze_context >> "$report_file"
    
    # Komprimierte Dateien
    echo -e "\n### Komprimierte Dateien\n" >> "$report_file"
    if [[ -d "$COMPRESSED_DIR" ]]; then
        ls -lh "$COMPRESSED_DIR"/*.compressed 2>/dev/null | tail -n +2 >> "$report_file" || echo "Keine komprimierten Dateien" >> "$report_file"
    fi
    
    echo -e "${GREEN}✅ Report erstellt: $report_file${NC}"
}

# Hauptfunktion
main() {
    init_optimizer
    
    case "${1:-help}" in
        analyze)
            analyze_context
            ;;
            
        optimize)
            optimize_context
            ;;
            
        monitor)
            # Im Hintergrund starten
            nohup bash -c "$0 monitor-loop" > /dev/null 2>&1 &
            echo -e "${GREEN}✅ Context Monitor gestartet (PID: $!)${NC}"
            ;;
            
        monitor-loop)
            start_monitor
            ;;
            
        report)
            generate_report
            ;;
            
        compress)
            if [[ -f "$2" ]]; then
                compress_file "$2"
            else
                echo -e "${RED}Fehler: Datei nicht gefunden: $2${NC}"
            fi
            ;;
            
        decompress)
            local compressed_file="$2"
            if [[ -f "$compressed_file" ]]; then
                local original_name=$(basename "$compressed_file" .compressed)
                zcat "$compressed_file" > "/tmp/$original_name"
                echo -e "${GREEN}✅ Dekomprimiert nach: /tmp/$original_name${NC}"
            else
                echo -e "${RED}Fehler: Komprimierte Datei nicht gefunden${NC}"
            fi
            ;;
            
        help|*)
            cat << EOF
HCS Context Optimizer - Intelligente Kontext-Größenverwaltung

Verwendung: $0 {analyze|optimize|monitor|report|compress|decompress|help}

Befehle:
  analyze     - Analysiert aktuelle Kontext-Größen
  optimize    - Optimiert/komprimiert große Dateien
  monitor     - Startet Hintergrund-Monitoring
  report      - Erstellt detaillierten Report
  compress    - Komprimiert eine spezifische Datei
  decompress  - Dekomprimiert eine Datei
  help        - Zeigt diese Hilfe

Limits:
  - Max Dateigröße: $(numfmt --to=iec-i --suffix=B $MAX_FILE_SIZE)
  - Max Gesamt-Kontext: $(numfmt --to=iec-i --suffix=B $MAX_CONTEXT_TOTAL)
  - Komprimierungs-Schwelle: $(numfmt --to=iec-i --suffix=B $COMPRESSION_THRESHOLD)

Umgebungsvariablen:
  CONTEXT_MONITOR_INTERVAL - Monitor-Intervall in Sekunden (Standard: 600)
EOF
            ;;
    esac
}

# Script ausführen
main "$@"