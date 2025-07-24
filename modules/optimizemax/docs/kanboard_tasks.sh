#!/bin/bash
# 2025-07-23 15:20:00
# Kanboard Task Creation Script for OptimizeMax

KANBOARD_URL="http://192.168.178.188/jsonrpc.php"
API_TOKEN="91cc77c33521efdb0a6cc74f3436012c76d6ed76839f9913a7771320be2d"

echo "=== Kanboard OptimizeMax Task Creation ==="
echo "Attempting to connect to Kanboard at $KANBOARD_URL"
echo

# Test connection with getVersion
echo "Testing connection..."
VERSION_RESPONSE=$(curl -s -X POST "$KANBOARD_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "getVersion",
    "id": 1
  }')

echo "Version Response: $VERSION_RESPONSE"
echo

# Try to get projects with API token in params
echo "Fetching projects with API token..."
PROJECTS_RESPONSE=$(curl -s -X POST "$KANBOARD_URL" \
  -H "Content-Type: application/json" \
  -d "{
    \"jsonrpc\": \"2.0\",
    \"method\": \"getAllProjects\",
    \"id\": 1,
    \"params\": {
      \"api_token\": \"$API_TOKEN\"
    }
  }")

echo "Projects Response: $PROJECTS_RESPONSE"
echo

# Alternative: Try with the application token
API_TOKEN2="66caba29825f37883f59c04ce9fd50b0d043ffe9fb198d264eb02882065e"
echo "Trying with application token..."
PROJECTS_RESPONSE2=$(curl -s -X POST "$KANBOARD_URL" \
  -H "Content-Type: application/json" \
  -d "{
    \"jsonrpc\": \"2.0\",
    \"method\": \"getAllProjects\",
    \"id\": 1,
    \"params\": {
      \"api_token\": \"$API_TOKEN2\"
    }
  }")

echo "Projects Response 2: $PROJECTS_RESPONSE2"
echo

# Summary document for manual creation
cat > /home/aicollab/OptimizeMax/kanboard_tasks_manual.md << 'EOF'
# OptimizeMax Kanboard Tasks

Da die API-Authentifizierung fehlschlägt, hier die Tasks für die manuelle Erstellung:

## Projekt: OptimizeMax
**Beschreibung**: AI-powered cost optimization system for Claude Code

## Tasks:

### 1. UserPromptSubmit Hook für additionalContext implementieren
- **Priorität**: Hoch
- **Beschreibung**: Implementierung eines Hook-Systems für die Erweiterung von User-Prompts mit zusätzlichem Kontext

### 2. Tool Confirmation System mit canUseTool Callback einrichten
- **Priorität**: Mittel
- **Beschreibung**: System zur Bestätigung von Tool-Nutzung mit Callback-Mechanismus implementieren

### 3. OptimizeMax GitHub Repository erstellen
- **Priorität**: Mittel
- **Beschreibung**: Neues GitHub Repository für OptimizeMax anlegen und Grundstruktur einrichten

### 4. Claude Code SDK Integration (TypeScript) entwickeln
- **Priorität**: Hoch
- **Beschreibung**: TypeScript SDK für die Integration mit Claude Code entwickeln

### 5. Kostenoptimierungs-Dashboard mit Echtzeit-Tracking
- **Priorität**: Mittel
- **Beschreibung**: Dashboard zur Visualisierung und Tracking von API-Kosten in Echtzeit

### 6. Multi-Model Orchestration System implementieren
- **Priorität**: Mittel
- **Beschreibung**: System zur intelligenten Orchestrierung verschiedener AI-Modelle basierend auf Aufgabentyp

### 7. Projekt-Mapping und Auto-Discovery System
- **Priorität**: Niedrig
- **Beschreibung**: Automatisches System zur Erkennung und Mapping von Projekt-Beziehungen

### 8. Integration Tests und Performance-Benchmarks
- **Priorität**: Niedrig
- **Beschreibung**: Umfassende Test-Suite und Performance-Benchmarks für OptimizeMax

## Zugang
- URL: http://192.168.178.188
- Standard Login: admin (Passwort wurde geändert)
- API Tokens in credentials-vault.json könnten veraltet sein
EOF

echo "Manual task list created at: /home/aicollab/OptimizeMax/kanboard_tasks_manual.md"
echo
echo "WICHTIG: Die API-Authentifizierung schlägt fehl. Mögliche Gründe:"
echo "1. Die API-Tokens wurden rotiert/geändert"
echo "2. Das admin Passwort wurde geändert (nicht mehr 'admin')"
echo "3. Die API könnte deaktiviert sein"
echo
echo "Bitte die Tasks manuell über die Web-Oberfläche erstellen:"
echo "http://192.168.178.188"