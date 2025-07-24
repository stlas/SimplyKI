#!/bin/bash
# pkg-manager.sh - Project Knowledge Graph Manager
# Created: 2025-07-19 21:18:00 CEST

# Farben für Ausgabe
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Basis-Pfade
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
PKG_DIR="$PROJECT_ROOT/.claude/pkg"
PROJECTS_REGISTRY="$PKG_DIR/projects.json"
API_REGISTRY="$PKG_DIR/api-registry.json"
FEATURE_MAP="$PKG_DIR/feature-map.json"
CONNECTIONS_CACHE="$PKG_DIR/connections.json"

# Erstelle PKG Verzeichnis
mkdir -p "$PKG_DIR"

# Logging
log() {
    echo -e "${BLUE}[PKG]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

# Initialisiere PKG System
init_pkg() {
    log "Initialisiere Project Knowledge Graph..."
    
    # Erstelle initiale Registry wenn nicht vorhanden
    if [ ! -f "$PROJECTS_REGISTRY" ]; then
        cat > "$PROJECTS_REGISTRY" << 'EOF'
{
  "version": "1.0.0",
  "last_updated": "",
  "projects": {}
}
EOF
        success "Projects Registry erstellt"
    fi
    
    if [ ! -f "$API_REGISTRY" ]; then
        cat > "$API_REGISTRY" << 'EOF'
{
  "version": "1.0.0",
  "last_updated": "",
  "apis": {}
}
EOF
        success "API Registry erstellt"
    fi
    
    if [ ! -f "$FEATURE_MAP" ]; then
        cat > "$FEATURE_MAP" << 'EOF'
{
  "version": "1.0.0",
  "last_updated": "",
  "features": {}
}
EOF
        success "Feature Map erstellt"
    fi
}

# Registriere ein Projekt
register_project() {
    local name="$1"
    local path="$2"
    local type="${3:-unknown}"
    local description="${4:-}"
    
    if [ -z "$name" ] || [ -z "$path" ]; then
        error "Usage: register_project <name> <path> [type] [description]"
        return 1
    fi
    
    log "Registriere Projekt: $name"
    
    # Update projects.json
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local temp_file=$(mktemp)
    
    jq --arg name "$name" \
       --arg path "$path" \
       --arg type "$type" \
       --arg desc "$description" \
       --arg ts "$timestamp" \
       '.projects[$name] = {
           "path": $path,
           "type": $type,
           "description": $desc,
           "registered": $ts,
           "apis": [],
           "dependencies": [],
           "services": {}
       } | .last_updated = $ts' "$PROJECTS_REGISTRY" > "$temp_file"
    
    mv "$temp_file" "$PROJECTS_REGISTRY"
    success "Projekt '$name' registriert"
}

# Scanne Projekt nach APIs und Services
scan_project() {
    local project_name="$1"
    
    if [ -z "$project_name" ]; then
        error "Usage: scan_project <project_name>"
        return 1
    fi
    
    # Hole Projekt-Pfad aus Registry
    local project_path=$(jq -r --arg name "$project_name" '.projects[$name].path // empty' "$PROJECTS_REGISTRY")
    
    if [ -z "$project_path" ]; then
        error "Projekt '$project_name' nicht in Registry gefunden"
        return 1
    fi
    
    log "Scanne Projekt: $project_name ($project_path)"
    
    # Node.js Projekt?
    if [ -f "$project_path/package.json" ]; then
        log "Node.js Projekt erkannt"
        
        # Extrahiere Dependencies
        local deps=$(jq -r '.dependencies // {} | keys[]' "$project_path/package.json" 2>/dev/null | grep -E "^@?smartki|ai-collab" || true)
        
        # Suche nach Express/Fastify Routes
        local api_files=$(find "$project_path" -name "*.js" -o -name "*.ts" 2>/dev/null | head -20)
        
        for file in $api_files; do
            # Suche nach API Endpoints
            grep -E "app\.(get|post|put|delete|patch)\s*\(" "$file" 2>/dev/null | while read -r line; do
                local endpoint=$(echo "$line" | grep -oE "['\"][^'\"]+['\"]" | head -1 | tr -d "'\"")
                if [ ! -z "$endpoint" ]; then
                    echo "  API Endpoint gefunden: $endpoint"
                fi
            done
        done
    fi
    
    # Docker Compose?
    if [ -f "$project_path/docker-compose.yml" ] || [ -f "$project_path/docker-compose.yaml" ]; then
        log "Docker Compose erkannt"
        # Extrahiere Ports
        grep -E "^\s*-\s*[0-9]+:[0-9]+" "$project_path/docker-compose.y*ml" 2>/dev/null | while read -r line; do
            echo "  Port Mapping: $line"
        done
    fi
    
    # Shell Scripts mit APIs?
    local sh_files=$(find "$project_path" -name "*.sh" 2>/dev/null | head -10)
    for file in $sh_files; do
        grep -E "curl|wget|http://|https://" "$file" 2>/dev/null | head -5 | while read -r line; do
            echo "  API Aufruf in $(basename "$file")"
        done
    done
}

# Trace Verbindungen zwischen Projekten
trace_connections() {
    log "Suche Verbindungen zwischen Projekten..."
    
    local temp_connections=$(mktemp)
    echo '{"connections": []}' > "$temp_connections"
    
    # Durchsuche alle registrierten Projekte
    jq -r '.projects | keys[]' "$PROJECTS_REGISTRY" | while read -r project; do
        local project_path=$(jq -r --arg p "$project" '.projects[$p].path' "$PROJECTS_REGISTRY")
        
        if [ -d "$project_path" ]; then
            log "Durchsuche $project..."
            
            # Suche nach URLs zu anderen Services
            grep -r "http://\|https://\|localhost:\|192\.168\." \
                --include="*.js" --include="*.ts" --include="*.json" --include="*.sh" \
                "$project_path" 2>/dev/null | head -20 | while read -r match; do
                
                local file=$(echo "$match" | cut -d: -f1)
                local url=$(echo "$match" | grep -oE "(https?://[^[:space:]\"']+|localhost:[0-9]+|192\.168\.[0-9]+\.[0-9]+)" | head -1)
                
                if [ ! -z "$url" ]; then
                    jq --arg from "$project" \
                       --arg to "$url" \
                       --arg file "$file" \
                       '.connections += [{
                           "from": $from,
                           "to": $to,
                           "file": $file,
                           "type": "http"
                       }]' "$temp_connections" > "$temp_connections.tmp"
                    mv "$temp_connections.tmp" "$temp_connections"
                fi
            done
        fi
    done
    
    # Speichere Connections
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    jq --arg ts "$timestamp" '.last_updated = $ts' "$temp_connections" > "$CONNECTIONS_CACHE"
    rm -f "$temp_connections"
    
    local conn_count=$(jq '.connections | length' "$CONNECTIONS_CACHE")
    success "$conn_count Verbindungen gefunden"
}

# Zeige PKG Status
show_status() {
    echo -e "\n${BLUE}═══════════════════════════════════════${NC}"
    echo -e "${BLUE}   Project Knowledge Graph Status      ${NC}"
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    
    if [ -f "$PROJECTS_REGISTRY" ]; then
        local project_count=$(jq '.projects | length' "$PROJECTS_REGISTRY")
        local last_update=$(jq -r '.last_updated // "never"' "$PROJECTS_REGISTRY")
        echo -e "Projekte:        ${GREEN}$project_count${NC} registriert"
        echo -e "Letztes Update:  $last_update"
    else
        echo -e "Projekte:        ${RED}Nicht initialisiert${NC}"
    fi
    
    if [ -f "$API_REGISTRY" ]; then
        local api_count=$(jq '.apis | length' "$API_REGISTRY")
        echo -e "APIs:            ${GREEN}$api_count${NC} dokumentiert"
    fi
    
    if [ -f "$CONNECTIONS_CACHE" ]; then
        local conn_count=$(jq '.connections | length' "$CONNECTIONS_CACHE")
        echo -e "Verbindungen:    ${GREEN}$conn_count${NC} gefunden"
    fi
    
    echo -e "${BLUE}═══════════════════════════════════════${NC}\n"
}

# Liste alle Projekte
list_projects() {
    if [ ! -f "$PROJECTS_REGISTRY" ]; then
        error "PKG nicht initialisiert. Führe 'init' aus."
        return 1
    fi
    
    echo -e "\n${BLUE}Registrierte Projekte:${NC}"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    jq -r '.projects | to_entries[] | "\(.key)|\(.value.type)|\(.value.path)|\(.value.description // "")"' "$PROJECTS_REGISTRY" | \
    while IFS='|' read -r name type path desc; do
        printf "%-20s %-12s %-40s %s\n" "$name" "[$type]" "$path" "$desc"
    done
}

# Exportiere als Mermaid Diagramm
export_mermaid() {
    local output_file="${1:-$PKG_DIR/project-graph.mermaid}"
    
    log "Exportiere Mermaid Diagramm nach $output_file"
    
    cat > "$output_file" << 'EOF'
graph TD
    %% Project Knowledge Graph
    %% Generated: 
EOF
    echo "    %% $(date)" >> "$output_file"
    echo "" >> "$output_file"
    
    # Füge Projekte hinzu
    jq -r '.projects | to_entries[] | "    \(.key)[\(.key)<br/>\(.value.type)]"' "$PROJECTS_REGISTRY" >> "$output_file"
    echo "" >> "$output_file"
    
    # Füge Verbindungen hinzu
    if [ -f "$CONNECTIONS_CACHE" ]; then
        jq -r '.connections[] | "    \(.from) --> |\(.type)| \(.to)"' "$CONNECTIONS_CACHE" | sort -u >> "$output_file"
    fi
    
    success "Mermaid Diagramm exportiert: $output_file"
}

# Hauptfunktion
main() {
    local command="${1:-help}"
    
    case "$command" in
        init)
            init_pkg
            ;;
        register)
            register_project "$2" "$3" "$4" "$5"
            ;;
        scan)
            scan_project "$2"
            ;;
        trace)
            trace_connections
            ;;
        status)
            show_status
            ;;
        list)
            list_projects
            ;;
        export)
            export_mermaid "$2"
            ;;
        help|*)
            echo "Project Knowledge Graph Manager"
            echo ""
            echo "Usage: $0 <command> [args]"
            echo ""
            echo "Commands:"
            echo "  init                    - Initialisiere PKG System"
            echo "  register <name> <path>  - Registriere ein Projekt"
            echo "  scan <name>            - Scanne Projekt nach APIs"
            echo "  trace                  - Finde Verbindungen zwischen Projekten"
            echo "  status                 - Zeige PKG Status"
            echo "  list                   - Liste alle Projekte"
            echo "  export [file]          - Exportiere als Mermaid Diagramm"
            ;;
    esac
}

# Führe main aus
main "$@"