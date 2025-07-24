#!/bin/bash
# pkg-neustart-integration.sh - PKG Integration für NEUSTART
# Created: 2025-07-19 21:21:00 CEST

# Basis-Pfade
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
PKG_DIR="$PROJECT_ROOT/.claude/pkg"

# Generiere PKG Section für NEUSTART
generate_pkg_section() {
    echo "## Project Knowledge Graph Status"
    echo ""
    
    if [ -f "$PKG_DIR/projects.json" ]; then
        local project_count=$(jq '.projects | length' "$PKG_DIR/projects.json")
        local last_update=$(jq -r '.last_updated // "unbekannt"' "$PKG_DIR/projects.json")
        echo "- **Registrierte Projekte**: $project_count"
        echo "- **Letztes Update**: $last_update"
        
        # Liste Projekte
        echo ""
        echo "### Registrierte Projekte"
        jq -r '.projects | to_entries[] | "- **\(.key)** [\(.value.type)]: \(.value.description // "keine Beschreibung")"' "$PKG_DIR/projects.json"
    else
        echo "- PKG nicht initialisiert"
    fi
    
    if [ -f "$PKG_DIR/api-registry.json" ]; then
        local api_count=$(jq '.apis | length' "$PKG_DIR/api-registry.json")
        echo ""
        echo "### Dokumentierte APIs"
        echo "- **Anzahl APIs**: $api_count"
        
        # Liste wichtigste APIs
        echo ""
        jq -r '.apis | to_entries[] | "- **\(.key)**: \(.value.description // .value.base_url)"' "$PKG_DIR/api-registry.json" | head -10
    fi
    
    if [ -f "$PKG_DIR/connections.json" ]; then
        local conn_count=$(jq '.connections | length' "$PKG_DIR/connections.json")
        echo ""
        echo "### Projekt-Verbindungen"
        echo "- **Gefundene Verbindungen**: $conn_count"
    fi
    
    echo ""
    echo "### PKG Quick Commands"
    echo '```bash'
    echo '# Status anzeigen'
    echo './core/src/pkg-manager.sh status'
    echo ''
    echo '# Projekte auflisten'
    echo './core/src/pkg-manager.sh list'
    echo ''
    echo '# Verbindungen tracen'
    echo './core/src/pkg-manager.sh trace'
    echo ''
    echo '# Mermaid-Diagramm exportieren'
    echo './core/src/pkg-manager.sh export'
    echo '```'
}

# Füge PKG Section zu bestehender NEUSTART hinzu
append_to_neustart() {
    local neustart_file="$1"
    
    if [ -f "$neustart_file" ]; then
        # Prüfe ob PKG Section bereits existiert
        if ! grep -q "## Project Knowledge Graph Status" "$neustart_file"; then
            echo "" >> "$neustart_file"
            generate_pkg_section >> "$neustart_file"
            echo "✓ PKG Section zu NEUSTART hinzugefügt"
        else
            echo "⚠ PKG Section bereits in NEUSTART vorhanden"
        fi
    else
        echo "❌ NEUSTART-Datei nicht gefunden: $neustart_file"
    fi
}

# Hauptfunktion
main() {
    local command="${1:-generate}"
    
    case "$command" in
        generate)
            generate_pkg_section
            ;;
        append)
            local neustart_file="${2:-}"
            if [ -z "$neustart_file" ]; then
                # Finde neueste NEUSTART
                neustart_file=$(ls -t $PROJECT_ROOT/NEUSTART-*.md 2>/dev/null | head -1)
            fi
            
            if [ ! -z "$neustart_file" ]; then
                append_to_neustart "$neustart_file"
            else
                echo "Keine NEUSTART-Datei gefunden"
            fi
            ;;
        *)
            echo "Usage: $0 [generate|append [neustart-file]]"
            ;;
    esac
}

main "$@"