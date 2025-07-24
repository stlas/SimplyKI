#!/bin/bash
# Last modified: 2025-07-17 22:12:00 CEST
# hybrid-context-manager.sh - Integriertes Kontext-Management-System

# Setze locale auf verfügbare UTF-8 locale
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

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
MEMORY_DIR="$CLAUDE_DIR/memory"
CONTEXT_DIR="$CLAUDE_DIR/context"

# Initialisierung
init_hybrid_system() {
    echo -e "${BLUE}=== INITIALISIERE HYBRID CONTEXT SYSTEM ===${NC}"
    
    # Verzeichnisstruktur erstellen
    mkdir -p "$MEMORY_DIR"/{current,completed,knowledge}
    mkdir -p "$CONTEXT_DIR"/{snapshots,archives}
    mkdir -p "$CLAUDE_DIR"/{hooks,templates,commands}
    
    # CLAUDE.md erstellen wenn nicht vorhanden
    if [[ ! -f "$PROJECT_ROOT/CLAUDE.md" ]]; then
        create_claude_md
    fi
    
    # Hooks installieren
    install_hooks
    
    # MCP-Integration prüfen
    check_mcp_integration
    
    echo -e "${GREEN}✅ Hybrid Context System initialisiert${NC}"
}

# CLAUDE.md Template
create_claude_md() {
    cat > "$PROJECT_ROOT/CLAUDE.md" << 'EOF'
# ai-collab - Claude Development Context

## Project Overview
Universeller KI-Entwicklungsassistent für kostenoptimierte Softwareentwicklung

## Context Management
- **Project Context**: CLAUDE.md (this file)
- **Session Context**: NEUSTART-*.md files
- **Task Context**: .claude/memory/current/
- **History**: .claude/context/snapshots/

## Automatic Features
- Session restoration via NEUSTART files
- Memory persistence for tasks
- MCP tool integration
- Continuous logging

## Commands
- `context status` - Show context hierarchy
- `context save` - Create snapshot
- `context restore` - Restore from snapshot
- `context compact` - Archive old context

## Hooks
- pre_session: Auto-load latest NEUSTART
- post_task: Update memory files
- on_exit: Create context snapshot
EOF
    echo -e "${GREEN}✅ CLAUDE.md erstellt${NC}"
}

# Hook-Installation
install_hooks() {
    # Pre-Session Hook
    cat > "$CLAUDE_DIR/hooks/pre-session.sh" << 'EOF'
#!/bin/bash
# Automatisches Laden des letzten Kontexts

echo "🔄 Loading previous context..."

# 1. Finde neueste NEUSTART
latest_neustart=$(ls -t NEUSTART-*.md 2>/dev/null | head -1)
if [[ -f "$latest_neustart" ]]; then
    echo "📄 Found session context: $latest_neustart"
fi

# 2. Prüfe offene Tasks
if [[ -d ".claude/memory/current" ]]; then
    task_count=$(ls .claude/memory/current/*.md 2>/dev/null | wc -l)
    if [[ $task_count -gt 0 ]]; then
        echo "📋 Found $task_count active tasks"
    fi
fi

# 3. Zeige letzten Git-Status
if git rev-parse --git-dir > /dev/null 2>&1; then
    changes=$(git status --porcelain | wc -l)
    echo "🔧 Git: $changes uncommitted changes"
fi
EOF
    chmod +x "$CLAUDE_DIR/hooks/pre-session.sh"
    
    # Post-Task Hook
    cat > "$CLAUDE_DIR/hooks/post-task.sh" << 'EOF'
#!/bin/bash
# Aktualisiere Memory nach Task-Abschluss

task_name="$1"
task_status="$2"
timestamp=$(date +"%Y-%m-%d %H:%M:%S")

# Update current task
if [[ -n "$task_name" ]]; then
    echo "[$timestamp] Status: $task_status" >> ".claude/memory/current/$task_name.md"
    
    # Wenn completed, verschiebe zu completed
    if [[ "$task_status" == "completed" ]]; then
        mkdir -p ".claude/memory/completed/$(date +%Y-%m-%d)"
        mv ".claude/memory/current/$task_name.md" \
           ".claude/memory/completed/$(date +%Y-%m-%d)/"
    fi
fi
EOF
    chmod +x "$CLAUDE_DIR/hooks/post-task.sh"
    
    echo -e "${GREEN}✅ Hooks installiert${NC}"
}

# MCP-Integration Check
check_mcp_integration() {
    if [[ -f "$PROJECT_ROOT/.claude.json" ]]; then
        # Füge context_manager Tool hinzu
        if ! grep -q "context_manager" "$PROJECT_ROOT/.claude.json"; then
            echo -e "${YELLOW}⚠️  MCP context_manager Tool nicht gefunden${NC}"
            echo "   Füge manuell zu .claude.json hinzu für volle Integration"
        fi
    fi
}

# Context Status anzeigen
show_context_status() {
    echo -e "${BLUE}📊 Context Status Dashboard${NC}"
    echo ""
    
    # Project Level
    echo -n "├── Project: "
    if [[ -f "$PROJECT_ROOT/CLAUDE.md" ]]; then
        echo -e "${GREEN}ai-collab (CLAUDE.md ✓)${NC}"
    else
        echo -e "${RED}CLAUDE.md fehlt ✗${NC}"
    fi
    
    # Session Level
    echo -n "├── Session: "
    latest_neustart=$(ls -t NEUSTART-*.md 2>/dev/null | head -1)
    if [[ -f "$latest_neustart" ]]; then
        session_time=$(stat -c %y "$latest_neustart" 2>/dev/null | cut -d' ' -f2 | cut -d'.' -f1)
        echo -e "${GREEN}${latest_neustart} (${session_time})${NC}"
    else
        echo -e "${YELLOW}Keine NEUSTART-Datei${NC}"
    fi
    
    # Memory Level
    echo -n "├── Memory: "
    current_tasks=$(ls "$MEMORY_DIR/current/"*.md 2>/dev/null | wc -l)
    completed_today=$(find "$MEMORY_DIR/completed/$(date +%Y-%m-%d)" -name "*.md" 2>/dev/null | wc -l)
    echo "$current_tasks active, $completed_today completed today"
    
    # Logs
    echo -n "├── Logs: "
    if [[ -d "$PROJECT_ROOT/local/development/continuous-logs" ]]; then
        log_size=$(du -sh "$PROJECT_ROOT/local/development/continuous-logs" 2>/dev/null | cut -f1)
        echo "$log_size"
    else
        echo "Not configured"
    fi
    
    # MCP Status
    echo -n "└── MCP: "
    if pgrep -f "mcp-server" > /dev/null; then
        echo -e "${GREEN}Connected ✓${NC}"
    else
        echo -e "${RED}Disconnected ✗${NC}"
    fi
}

# Context Snapshot erstellen
create_context_snapshot() {
    local snapshot_name="${1:-snapshot-$(date +%Y%m%d-%H%M%S)}"
    local snapshot_dir="$CONTEXT_DIR/snapshots/$snapshot_name"
    
    echo -e "${BLUE}📸 Creating context snapshot: $snapshot_name${NC}"
    
    mkdir -p "$snapshot_dir"
    
    # 1. Kopiere CLAUDE.md
    cp "$PROJECT_ROOT/CLAUDE.md" "$snapshot_dir/" 2>/dev/null
    
    # 2. Kopiere neueste NEUSTART
    latest_neustart=$(ls -t NEUSTART-*.md 2>/dev/null | head -1)
    if [[ -f "$latest_neustart" ]]; then
        cp "$latest_neustart" "$snapshot_dir/"
    fi
    
    # 3. Kopiere Memory Files
    cp -r "$MEMORY_DIR/current" "$snapshot_dir/memory-current" 2>/dev/null
    
    # 4. Git Status speichern
    git status --porcelain > "$snapshot_dir/git-status.txt" 2>/dev/null
    git log --oneline -10 > "$snapshot_dir/git-log.txt" 2>/dev/null
    
    # 5. Erstelle Manifest
    cat > "$snapshot_dir/manifest.json" << EOF
{
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "name": "$snapshot_name",
    "session_id": "${SESSION_ID:-unknown}",
    "files": {
        "claude_md": $(ls "$snapshot_dir/CLAUDE.md" 2>/dev/null && echo "true" || echo "false"),
        "neustart": "$(basename "$latest_neustart" 2>/dev/null)",
        "memory_tasks": $(ls "$snapshot_dir/memory-current/"*.md 2>/dev/null | wc -l),
        "git_changes": $(wc -l < "$snapshot_dir/git-status.txt" 2>/dev/null)
    }
}
EOF
    
    echo -e "${GREEN}✅ Snapshot erstellt: $snapshot_dir${NC}"
}

# Context wiederherstellen
restore_context_snapshot() {
    local snapshot_name="$1"
    
    if [[ -z "$snapshot_name" ]]; then
        # Liste verfügbare Snapshots
        echo -e "${BLUE}Verfügbare Snapshots:${NC}"
        ls -t "$CONTEXT_DIR/snapshots" 2>/dev/null | head -10
        return 1
    fi
    
    local snapshot_dir="$CONTEXT_DIR/snapshots/$snapshot_name"
    
    if [[ ! -d "$snapshot_dir" ]]; then
        echo -e "${RED}❌ Snapshot nicht gefunden: $snapshot_name${NC}"
        return 1
    fi
    
    echo -e "${BLUE}♻️  Restoring context from: $snapshot_name${NC}"
    
    # 1. Memory Files wiederherstellen
    if [[ -d "$snapshot_dir/memory-current" ]]; then
        rm -rf "$MEMORY_DIR/current"
        cp -r "$snapshot_dir/memory-current" "$MEMORY_DIR/current"
        echo "✓ Memory files restored"
    fi
    
    # 2. NEUSTART-Link erstellen
    neustart_file=$(ls "$snapshot_dir"/NEUSTART-*.md 2>/dev/null | head -1)
    if [[ -f "$neustart_file" ]]; then
        ln -sf "$neustart_file" "$PROJECT_ROOT/LAST-NEUSTART.md"
        echo "✓ NEUSTART linked: $(basename "$neustart_file")"
    fi
    
    # 3. Git-Status anzeigen
    if [[ -f "$snapshot_dir/git-status.txt" ]]; then
        echo ""
        echo "Git status at snapshot time:"
        echo "---"
        head -5 "$snapshot_dir/git-status.txt"
        echo "..."
    fi
    
    echo -e "${GREEN}✅ Context restored${NC}"
}

# Context komprimieren
compact_old_context() {
    local days="${1:-7}"
    local archive_name="archive-$(date +%Y%m%d).tar.gz"
    
    echo -e "${BLUE}🗜️  Compacting context older than $days days${NC}"
    
    # 1. Alte NEUSTART-Dateien archivieren
    find "$PROJECT_ROOT" -name "NEUSTART-*.md" -mtime +$days -print0 | \
        tar -czf "$CONTEXT_DIR/archives/$archive_name" --null -T -
    
    # 2. Alte Memory Files archivieren
    find "$MEMORY_DIR/completed" -type f -mtime +$days -print0 | \
        tar -rzf "$CONTEXT_DIR/archives/$archive_name" --null -T -
    
    # 3. Alte Dateien löschen
    find "$PROJECT_ROOT" -name "NEUSTART-*.md" -mtime +$days -delete
    find "$MEMORY_DIR/completed" -type f -mtime +$days -delete
    
    # 4. Zusammenfassung erstellen
    cat > "$CONTEXT_DIR/archives/$archive_name.summary" << EOF
Archive: $archive_name
Created: $(date)
Period: Older than $days days
Contents:
- NEUSTART files: $(tar -tf "$CONTEXT_DIR/archives/$archive_name" | grep -c "NEUSTART-")
- Memory files: $(tar -tf "$CONTEXT_DIR/archives/$archive_name" | grep -c "memory/")
EOF
    
    echo -e "${GREEN}✅ Context compacted to: $archive_name${NC}"
}

# Smart Restore
smart_restore() {
    echo -e "${BLUE}🤖 Smart Context Restore${NC}"
    
    # 1. Finde beste Restore-Quelle
    echo "Analyzing context sources..."
    
    # Neueste NEUSTART
    latest_neustart=$(ls -t NEUSTART-*.md 2>/dev/null | head -1)
    
    # Neuester Snapshot
    latest_snapshot=$(ls -t "$CONTEXT_DIR/snapshots" 2>/dev/null | head -1)
    
    # 2. Entscheide basierend auf Aktualität
    if [[ -f "$latest_neustart" ]] && [[ -z "$latest_snapshot" ]]; then
        echo "→ Using NEUSTART file"
        echo "  File: $latest_neustart"
    elif [[ -n "$latest_snapshot" ]]; then
        neustart_time=$(stat -c %Y "$latest_neustart" 2>/dev/null || echo 0)
        snapshot_time=$(stat -c %Y "$CONTEXT_DIR/snapshots/$latest_snapshot" 2>/dev/null || echo 0)
        
        if [[ $snapshot_time -gt $neustart_time ]]; then
            echo "→ Using snapshot (more recent)"
            restore_context_snapshot "$latest_snapshot"
        else
            echo "→ Using NEUSTART file (more recent)"
            echo "  File: $latest_neustart"
        fi
    else
        echo "→ No context found, starting fresh"
        init_hybrid_system
    fi
    
    # 3. Zeige Status
    echo ""
    show_context_status
}

# Memory Task erstellen
create_memory_task() {
    local task_name="$1"
    local description="$2"
    
    if [[ -z "$task_name" ]]; then
        echo -e "${RED}❌ Task name required${NC}"
        return 1
    fi
    
    local task_file="$MEMORY_DIR/current/${task_name}.md"
    
    cat > "$task_file" << EOF
# Task: $task_name
**Created**: $(date)
**Status**: active

## Description
$description

## Progress Log
- [$(date +"%Y-%m-%d %H:%M")] Task created

## Decisions

## Blockers

## Notes

EOF
    
    echo -e "${GREEN}✅ Memory task created: $task_name${NC}"
}

# Hauptfunktion
case "${1:-help}" in
    init)
        init_hybrid_system
        ;;
    status)
        show_context_status
        ;;
    snapshot)
        create_context_snapshot "$2"
        ;;
    restore)
        restore_context_snapshot "$2"
        ;;
    compact)
        compact_old_context "$2"
        ;;
    smart-restore)
        smart_restore
        ;;
    task)
        create_memory_task "$2" "$3"
        ;;
    analyze)
        # Analysiere Kontext-Größen
        "$SCRIPT_DIR/hcs-context-optimizer.sh" analyze
        ;;
    optimize)
        # Optimiere große Dateien
        "$SCRIPT_DIR/hcs-context-optimizer.sh" optimize
        ;;
    help)
        cat << EOF
Hybrid Context Manager - Integriertes Kontext-Management

Verwendung: $0 [command] [options]

Commands:
  init          - Initialisiere Hybrid Context System
  status        - Zeige Context Status Dashboard
  snapshot      - Erstelle Context Snapshot
  restore       - Stelle Context wieder her
  compact       - Komprimiere alten Context
  smart-restore - Intelligente Context-Wiederherstellung
  task          - Erstelle Memory Task
  analyze       - Analysiere Kontext-Größen
  optimize      - Optimiere/komprimiere große Dateien
  help          - Zeige diese Hilfe

Beispiele:
  $0 init                    # System initialisieren
  $0 status                  # Status anzeigen
  $0 snapshot my-snapshot    # Snapshot erstellen
  $0 restore my-snapshot     # Snapshot wiederherstellen
  $0 compact 30              # Context älter als 30 Tage archivieren
  $0 task "feature-x" "Implement new feature X"
EOF
        ;;
    *)
        echo -e "${RED}Unbekannter Befehl: $1${NC}"
        echo "Verwende '$0 help' für Hilfe"
        exit 1
        ;;
esac