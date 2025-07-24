#!/bin/bash
# pkg-api-documenter.sh - API Dokumentation für PKG
# Created: 2025-07-19 21:20:00 CEST

# Basis-Pfade
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
PKG_DIR="$PROJECT_ROOT/.claude/pkg"
API_REGISTRY="$PKG_DIR/api-registry.json"

# Dokumentiere ai-collab APIs
document_ai_collab_apis() {
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local temp_file=$(mktemp)
    
    # Lese existierende Registry
    if [ -f "$API_REGISTRY" ]; then
        cp "$API_REGISTRY" "$temp_file"
    else
        echo '{"version": "1.0.0", "apis": {}}' > "$temp_file"
    fi
    
    # Füge ai-collab Web-API hinzu
    jq --arg ts "$timestamp" '
    .apis["ai-collab/web-api"] = {
        "base_url": "http://192.168.178.183:3300",
        "version": "1.0.0",
        "description": "AI-Collab Web API für externe Integration",
        "endpoints": {
            "/health": {
                "method": "GET",
                "description": "Service health check",
                "response": {
                    "service": "string",
                    "status": "string",
                    "version": "string",
                    "uptime": "number"
                }
            },
            "/status": {
                "method": "GET",
                "description": "Detaillierter System-Status",
                "response": {
                    "ai_collab": "object",
                    "sessions": "array",
                    "costs": "object"
                }
            },
            "/analyze": {
                "method": "POST",
                "description": "Code oder Prompt analysieren",
                "body": {
                    "prompt": "string",
                    "context": "string?",
                    "model": "string?",
                    "task_type": "string?"
                },
                "response": {
                    "model": "string",
                    "cost_estimate": "object",
                    "optimization_tips": "array"
                }
            },
            "/sessions": {
                "method": "GET",
                "description": "Liste aller Sessions",
                "response": ["array of session objects"]
            },
            "/sessions/:id": {
                "method": "GET",
                "description": "Details einer spezifischen Session",
                "params": {"id": "session name"},
                "response": "session object"
            }
        }
    } |
    .apis["ai-collab/mcp-server"] = {
        "protocol": "stdio/jsonrpc",
        "version": "1.0.0",
        "description": "MCP Server für Claude Integration",
        "capabilities": [
            "filesystem",
            "git",
            "logging",
            "session-management"
        ],
        "tools": [
            "/status",
            "/analyze",
            "/cost",
            "/session"
        ]
    } |
    .last_updated = $ts' "$temp_file" > "$API_REGISTRY"
    
    echo "✓ AI-Collab APIs dokumentiert"
}

# Dokumentiere SmartKI APIs (falls Projekt existiert)
document_smartki_apis() {
    if [ -d "/home/aicollab/projects/SmartKI" ]; then
        local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        
        jq --arg ts "$timestamp" '
        .apis["SmartKI/backend"] = {
            "base_url": "http://localhost:3000/api",
            "version": "2.0.0",
            "description": "SmartKI Backend API",
            "auth": "JWT Bearer Token",
            "endpoints": {
                "/auth/login": {
                    "method": "POST",
                    "description": "User authentication",
                    "body": {"email": "string", "password": "string"}
                },
                "/auth/register": {
                    "method": "POST",
                    "description": "User registration"
                },
                "/projects": {
                    "method": "GET",
                    "description": "List user projects",
                    "auth": "required"
                },
                "/ai/chat": {
                    "method": "POST",
                    "description": "AI Chat endpoint",
                    "auth": "required"
                }
            }
        } |
        .last_updated = $ts' "$API_REGISTRY" > "$API_REGISTRY.tmp"
        
        mv "$API_REGISTRY.tmp" "$API_REGISTRY"
        echo "✓ SmartKI APIs dokumentiert"
    fi
}

# Dokumentiere Pangolin APIs
document_pangolin_apis() {
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    jq --arg ts "$timestamp" '
    .apis["Pangolin/auth"] = {
        "base_url": "http://192.168.178.186:3002/api",
        "version": "latest",
        "description": "Pangolin Authentication Service",
        "endpoints": {
            "/auth/login": {
                "method": "POST",
                "description": "User login",
                "body": {"username": "string", "password": "string"}
            },
            "/auth/logout": {
                "method": "POST",
                "description": "User logout"
            },
            "/auth/verify": {
                "method": "GET",
                "description": "Verify authentication token"
            }
        }
    } |
    .apis["Pangolin/webapp"] = {
        "base_url": "http://192.168.178.186/",
        "description": "Pangolin Web Application",
        "login": "admin@haossl.de",
        "features": ["project-management", "user-management", "api-gateway"]
    } |
    .last_updated = $ts' "$API_REGISTRY" > "$API_REGISTRY.tmp"
    
    mv "$API_REGISTRY.tmp" "$API_REGISTRY"
    echo "✓ Pangolin APIs dokumentiert"
}

# Dokumentiere Obsidian APIs
document_obsidian_apis() {
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    jq --arg ts "$timestamp" '
    .apis["SmartKI-Obsidian/rest-api"] = {
        "base_url": "http://192.168.178.187:3001",
        "version": "1.0.0",
        "description": "Obsidian REST API für Knowledge Base Zugriff",
        "endpoints": {
            "/notes": {
                "method": "GET",
                "description": "Liste aller Notizen abrufen",
                "response": "array of notes"
            },
            "/notes/:id": {
                "method": "GET",
                "description": "Einzelne Notiz abrufen",
                "params": {"id": "note identifier"}
            },
            "/notes": {
                "method": "POST",
                "description": "Neue Notiz erstellen",
                "body": {"title": "string", "content": "string", "tags": "array"}
            },
            "/search": {
                "method": "GET",
                "description": "Volltext-Suche in Notizen",
                "query": {"q": "search query", "tags": "filter by tags"}
            },
            "/tags": {
                "method": "GET",
                "description": "Alle Tags abrufen"
            }
        }
    } |
    .apis["SmartKI-Obsidian/web"] = {
        "base_url": "http://192.168.178.187:3000",
        "description": "Obsidian Web Interface",
        "features": ["note-editor", "graph-view", "tag-manager", "search"]
    } |
    .last_updated = $ts' "$API_REGISTRY" > "$API_REGISTRY.tmp"
    
    mv "$API_REGISTRY.tmp" "$API_REGISTRY"
    echo "✓ Obsidian APIs dokumentiert"
}

# Hauptfunktion
main() {
    echo "📝 Dokumentiere APIs für PKG..."
    
    document_ai_collab_apis
    document_smartki_apis
    document_pangolin_apis
    document_obsidian_apis
    
    # Zeige Zusammenfassung
    local api_count=$(jq '.apis | length' "$API_REGISTRY")
    echo ""
    echo "✅ $api_count APIs dokumentiert"
    echo "📄 Registry: $API_REGISTRY"
}

main "$@"