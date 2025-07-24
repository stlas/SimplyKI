#!/bin/bash
# Created: 2025-07-19 20:48 CEST
# HCS Auto-Detection System
# Automatische Erkennung und Verifikation des Hybrid Context Systems

# Setze locale auf verfügbare UTF-8 locale
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

# Farben
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Konfiguration
HCS_STATUS_FILE="/home/aicollab/.claude/runtime/hcs-status.json"
CLAUDE_MD="/home/aicollab/CLAUDE.md"
LOG_FILE="/home/aicollab/.claude/runtime/hcs-detection.log"

# Log-Funktion
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# HCS Status prüfen
check_hcs_status() {
    local status="inactive"
    local checks_passed=0
    local total_checks=6
    local details=""
    
    echo -e "${BLUE}🔍 HCS Auto-Detection läuft...${NC}"
    
    # 1. CLAUDE.md vorhanden?
    if [ -f "$CLAUDE_MD" ]; then
        ((checks_passed++))
        details+="✓ CLAUDE.md gefunden\n"
    else
        details+="✗ CLAUDE.md fehlt\n"
    fi
    
    # 2. NEUSTART-Datei vorhanden?
    if ls /home/aicollab/NEUSTART-*.md >/dev/null 2>&1; then
        ((checks_passed++))
        local neustart_file=$(ls -t /home/aicollab/NEUSTART-*.md | head -1)
        details+="✓ NEUSTART: $(basename "$neustart_file")\n"
    else
        details+="✗ Keine NEUSTART-Datei\n"
    fi
    
    # 3. Memory-System aktiv?
    if [ -d "/home/aicollab/.claude/memory/current" ] && [ "$(ls -A /home/aicollab/.claude/memory/current 2>/dev/null)" ]; then
        ((checks_passed++))
        local memory_count=$(ls -1 /home/aicollab/.claude/memory/current/*.md 2>/dev/null | wc -l)
        details+="✓ Memory: $memory_count aktive Dateien\n"
    else
        details+="✗ Memory-System inaktiv\n"
    fi
    
    # 4. HCS Manager verfügbar?
    if [ -x "/home/aicollab/core/src/hybrid-context-manager.sh" ]; then
        ((checks_passed++))
        details+="✓ HCS Manager ausführbar\n"
    else
        details+="✗ HCS Manager nicht verfügbar\n"
    fi
    
    # 5. Snapshots vorhanden?
    if [ -d "/home/aicollab/.claude/context/snapshots" ] && [ "$(ls -A /home/aicollab/.claude/context/snapshots 2>/dev/null)" ]; then
        ((checks_passed++))
        local snapshot_count=$(ls -1 /home/aicollab/.claude/context/snapshots 2>/dev/null | wc -l)
        details+="✓ Snapshots: $snapshot_count verfügbar\n"
    else
        details+="✗ Keine Snapshots\n"
    fi
    
    # 6. MCP Server konfiguriert?
    if grep -q "mcp-server-simple.js" /home/aicollab/.claude.json 2>/dev/null; then
        ((checks_passed++))
        details+="✓ MCP Server konfiguriert\n"
    else
        details+="✗ MCP Server nicht konfiguriert\n"
    fi
    
    # 7. Project Knowledge Graph aktiv? (Optional aber empfohlen)
    if [ -f "/home/aicollab/.claude/pkg/projects.json" ]; then
        local project_count=$(jq '.projects | length' "/home/aicollab/.claude/pkg/projects.json" 2>/dev/null || echo "0")
        details+="✓ PKG: $project_count Projekte registriert\n"
    else
        details+="ℹ️  PKG: Nicht initialisiert (optional)\n"
    fi
    
    # Status bestimmen
    if [ $checks_passed -eq $total_checks ]; then
        status="active"
        echo -e "${GREEN}✅ HCS vollständig aktiv ($checks_passed/$total_checks)${NC}"
    elif [ $checks_passed -ge 4 ]; then
        status="partial"
        echo -e "${YELLOW}⚠️  HCS teilweise aktiv ($checks_passed/$total_checks)${NC}"
    else
        status="inactive"
        echo -e "${RED}❌ HCS nicht aktiv ($checks_passed/$total_checks)${NC}"
    fi
    
    # Details anzeigen
    echo -e "\n${BLUE}Details:${NC}"
    echo -e "$details"
    
    # Status speichern
    mkdir -p "$(dirname "$HCS_STATUS_FILE")"
    cat > "$HCS_STATUS_FILE" << EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "status": "$status",
  "checks_passed": $checks_passed,
  "total_checks": $total_checks,
  "percentage": $(( checks_passed * 100 / total_checks )),
  "details": {
    "claude_md": $([ -f "$CLAUDE_MD" ] && echo "true" || echo "false"),
    "neustart": $(ls /home/aicollab/NEUSTART-*.md >/dev/null 2>&1 && echo "true" || echo "false"),
    "memory_active": $([ -d "/home/aicollab/.claude/memory/current" ] && [ "$(ls -A /home/aicollab/.claude/memory/current 2>/dev/null)" ] && echo "true" || echo "false"),
    "hcs_manager": $([ -x "/home/aicollab/core/src/hybrid-context-manager.sh" ] && echo "true" || echo "false"),
    "snapshots": $([ -d "/home/aicollab/.claude/context/snapshots" ] && [ "$(ls -A /home/aicollab/.claude/context/snapshots 2>/dev/null)" ] && echo "true" || echo "false"),
    "mcp_configured": $(grep -q "mcp-server-simple.js" /home/aicollab/.claude.json 2>/dev/null && echo "true" || echo "false")
  }
}
EOF
    
    log "HCS Status: $status ($checks_passed/$total_checks)"
    
    return $([ "$status" = "active" ] && echo 0 || echo 1)
}

# CLAUDE.md Status-Marker aktualisieren
update_claude_md_marker() {
    local status_marker="<!-- HCS-STATUS: $(date +'%Y-%m-%d %H:%M:%S') -->"
    
    if [ -f "$CLAUDE_MD" ]; then
        # Entferne alte Marker
        sed -i '/<!-- HCS-STATUS:/d' "$CLAUDE_MD"
        
        # Füge neuen Marker am Anfang hinzu
        sed -i "1i\\$status_marker" "$CLAUDE_MD"
        
        echo -e "${GREEN}✓ CLAUDE.md mit Status-Marker aktualisiert${NC}"
    fi
}

# Auto-Recovery wenn HCS nicht aktiv
auto_recovery() {
    echo -e "${YELLOW}🔧 Starte Auto-Recovery...${NC}"
    
    # Versuche Smart-Restore
    if [ -x "/home/aicollab/core/src/hybrid-context-manager.sh" ]; then
        /home/aicollab/core/src/hybrid-context-manager.sh smart-restore
    else
        echo -e "${RED}❌ HCS Manager nicht verfügbar für Recovery${NC}"
    fi
}

# Hauptfunktion
main() {
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo -e "${BLUE}   HCS Auto-Detection & Verification   ${NC}"
    echo -e "${BLUE}═══════════════════════════════════════${NC}\n"
    
    # Status prüfen
    if check_hcs_status; then
        update_claude_md_marker
        echo -e "\n${GREEN}✅ HCS ist vollständig funktionsfähig!${NC}"
        
        # Quick-Status für Claude
        echo -e "\n${BLUE}📋 Quick-Status für Claude:${NC}"
        echo "- HCS: ✅ Aktiv"
        echo "- NEUSTART: $(ls -t /home/aicollab/NEUSTART-*.md 2>/dev/null | head -1 | xargs basename)"
        echo "- Memory: $(ls -1 /home/aicollab/.claude/memory/current/*.md 2>/dev/null | wc -l) Dateien"
        echo "- Status-Datei: $HCS_STATUS_FILE"
    else
        echo -e "\n${YELLOW}⚠️  HCS ist nicht vollständig aktiv${NC}"
        
        # Auto-Recovery anbieten
        read -p "Auto-Recovery starten? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            auto_recovery
        fi
    fi
    
    echo -e "\n${BLUE}═══════════════════════════════════════${NC}"
}

# Script ausführen
main "$@"