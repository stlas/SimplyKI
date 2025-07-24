#!/bin/bash
# Last modified: 2025-07-17 22:12:00 CEST
# FILE: ./core/src/cost-optimizer.sh

# cost-optimizer.sh - Intelligente Kostenoptimierung für AI-Collab
# Automatische Modellwahl und Prompt-Optimierung basierend auf Budget und Aufgabentyp

VERSION="2.0.0"
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Pfad-Konfiguration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOCAL_DIR="$PROJECT_ROOT/local"
TEMPLATES_DIR="$PROJECT_ROOT/core/templates"

# Kostenoptimierungs-Konfiguration
COST_CONFIG="$LOCAL_DIR/config/cost_optimization.json"
COST_TRACKING="$LOCAL_DIR/development/cost_tracking.json"
USAGE_ANALYTICS="$LOCAL_DIR/development/usage_analytics.json"

# Modell-Kosten (USD per 1M tokens)
declare -A MODEL_COSTS_INPUT=(
    ["claude-3.5-haiku"]="0.80"
    ["claude-3.5-sonnet"]="3.00"
    ["claude-4-sonnet"]="3.00"
    ["claude-4-opus"]="15.00"
)

declare -A MODEL_COSTS_OUTPUT=(
    ["claude-3.5-haiku"]="4.00"
    ["claude-3.5-sonnet"]="15.00"
    ["claude-4-sonnet"]="15.00"
    ["claude-4-opus"]="75.00"
)

# Modell-Fähigkeiten bewerten
declare -A MODEL_CAPABILITIES=(
    ["claude-3.5-haiku"]="speed:5,cost:5,quality:3,coding:3"
    ["claude-3.5-sonnet"]="speed:4,cost:3,quality:4,coding:5"
    ["claude-4-sonnet"]="speed:4,cost:3,quality:5,coding:5"
    ["claude-4-opus"]="speed:2,cost:1,quality:5,coding:4"
)

# Initialisierung der Kostenoptimierung
init_cost_optimizer() {
    echo -e "${BLUE}=== KOSTENOPTIMIERUNG INITIALISIEREN ===${NC}"
    
    # Verzeichnisse erstellen
    mkdir -p "$LOCAL_DIR/config" "$LOCAL_DIR/development"
    
    # Standard-Kostenoptimierungs-Konfiguration
    if [ ! -f "$COST_CONFIG" ]; then
        cat > "$COST_CONFIG" << 'EOF'
{
    "budgets": {
        "daily": 5.00,
        "weekly": 30.00,
        "monthly": 100.00
    },
    "thresholds": {
        "warning": 0.8,
        "critical": 0.95
    },
    "optimization": {
        "auto_model_selection": true,
        "template_usage": true,
        "prompt_caching": true,
        "batch_processing": true,
        "cost_aware_routing": true
    },
    "model_preferences": {
        "default": "claude-3.5-sonnet",
        "cost_sensitive": "claude-3.5-haiku",
        "quality_focused": "claude-4-opus",
        "coding_focused": "claude-3.5-sonnet"
    },
    "task_model_mapping": {
        "simple_fix": "claude-3.5-haiku",
        "documentation": "claude-3.5-haiku",
        "code_review": "claude-3.5-sonnet",
        "feature_development": "claude-3.5-sonnet",
        "architecture": "claude-4-opus",
        "complex_analysis": "claude-4-opus"
    }
}
EOF
        echo -e "${GREEN}✅ Kostenoptimierungs-Konfiguration erstellt${NC}"
    fi
    
    # Kosten-Tracking initialisieren
    if [ ! -f "$COST_TRACKING" ]; then
        echo '{}' > "$COST_TRACKING"
    fi
    
    # Usage Analytics initialisieren
    if [ ! -f "$USAGE_ANALYTICS" ]; then
        cat > "$USAGE_ANALYTICS" << 'EOF'
{
    "total_operations": 0,
    "total_cost": 0.0,
    "cost_savings": 0.0,
    "model_usage": {},
    "optimization_stats": {
        "template_reuse": 0,
        "auto_model_selection": 0,
        "prompt_optimizations": 0
    }
}
EOF
    fi
    
    echo -e "${GREEN}✅ Kostenoptimierung initialisiert${NC}"
}

# Intelligente Modellauswahl
select_optimal_model() {
    local task_type="$1"
    local complexity="$2"
    local priority="$3"
    local budget_remaining="$4"
    
    echo -e "${BLUE}=== MODELLAUSWAHL ===${NC}"
    
    # Konfiguration laden
    local auto_selection=$(jq -r '.optimization.auto_model_selection' "$COST_CONFIG" 2>/dev/null || echo "true")
    
    if [ "$auto_selection" != "true" ]; then
        local default_model=$(jq -r '.model_preferences.default' "$COST_CONFIG" 2>/dev/null || echo "claude-3.5-sonnet")
        echo "$default_model"
        return 0
    fi
    
    # Budget-Check
    local budget_threshold=$(echo "$budget_remaining * 0.1" | bc -l)
    local critical_budget=$(jq -r '.thresholds.critical' "$COST_CONFIG" 2>/dev/null || echo "0.95")
    
    # Task-basierte Modellauswahl
    local suggested_model=$(jq -r --arg task "$task_type" '.task_model_mapping[$task] // .model_preferences.default' "$COST_CONFIG" 2>/dev/null)
    
    # Komplexitäts-Anpassung
    case "$complexity" in
        "low")
            if [ "$suggested_model" = "claude-4-opus" ]; then
                suggested_model="claude-3.5-sonnet"
            elif [ "$suggested_model" = "claude-3.5-sonnet" ]; then
                suggested_model="claude-3.5-haiku"
            fi
            ;;
        "high")
            if [ "$suggested_model" = "claude-3.5-haiku" ]; then
                suggested_model="claude-3.5-sonnet"
            fi
            ;;
    esac
    
    # Budget-Constraint-Anpassung
    if [ "$(echo "$budget_remaining < 1.0" | bc -l)" = "1" ]; then
        suggested_model="claude-3.5-haiku"
    elif [ "$(echo "$budget_remaining < 5.0" | bc -l)" = "1" ] && [ "$suggested_model" = "claude-4-opus" ]; then
        suggested_model="claude-3.5-sonnet"
    fi
    
    # Prioritäts-Override
    if [ "$priority" = "critical" ] && [ "$(echo "$budget_remaining > 2.0" | bc -l)" = "1" ]; then
        suggested_model="claude-4-opus"
    fi
    
    echo -e "${CYAN}📊 Task: $task_type, Komplexität: $complexity, Priorität: $priority${NC}"
    echo -e "${CYAN}💰 Budget verbleibend: \$${budget_remaining}${NC}"
    echo -e "${GREEN}🎯 Ausgewähltes Modell: $suggested_model${NC}"
    
    # Auswahl protokollieren
    update_usage_analytics "auto_model_selection" "$suggested_model"
    
    echo "$suggested_model"
}

# Kosten schätzen
estimate_cost() {
    local prompt="$1"
    local model="$2"
    local expected_output_ratio="${3:-0.5}"
    
    # Token-Schätzung (vereinfacht: 4 Zeichen = 1 Token)
    local input_tokens=$((${#prompt} / 4))
    local output_tokens=$(echo "$input_tokens * $expected_output_ratio" | bc -l | cut -d. -f1)
    
    # Kosten berechnen
    local input_cost=$(echo "scale=6; $input_tokens * ${MODEL_COSTS_INPUT[$model]} / 1000000" | bc -l)
    local output_cost=$(echo "scale=6; $output_tokens * ${MODEL_COSTS_OUTPUT[$model]} / 1000000" | bc -l)
    local total_cost=$(echo "scale=6; $input_cost + $output_cost" | bc -l)
    
    echo "$total_cost"
}

# Prompt optimieren für Kosteneffizienz
optimize_prompt() {
    local prompt="$1"
    local task_type="$2"
    local optimization_level="${3:-medium}"
    
    echo -e "${BLUE}=== PROMPT-OPTIMIERUNG ===${NC}"
    
    local optimized_prompt="$prompt"
    local template_used=""
    
    # Template-basierte Optimierung
    local template_file="$TEMPLATES_DIR/$task_type.template"
    if [ -f "$template_file" ]; then
        optimized_prompt=$(sed "s/\${PROMPT}/$prompt/g" "$template_file")
        template_used="$task_type"
        echo -e "${GREEN}✅ Template angewendet: $task_type${NC}"
        
        # Template-Nutzung protokollieren
        update_usage_analytics "template_reuse" "$task_type"
    fi
    
    # Optimierungs-Level anwenden
    case "$optimization_level" in
        "high")
            # Aggressive Optimierung
            optimized_prompt="WICHTIG: Sei präzise und effizient. Fokussiere auf das Wesentliche. $optimized_prompt"
            ;;
        "medium")
            # Standard-Optimierung
            optimized_prompt="Bitte sei spezifisch und strukturiert. $optimized_prompt"
            ;;
        "low")
            # Minimale Optimierung
            ;;
    esac
    
    # Längen-Optimierung
    local original_length=${#prompt}
    local optimized_length=${#optimized_prompt}
    local length_change=$((optimized_length - original_length))
    
    echo -e "${CYAN}📏 Original: $original_length Zeichen${NC}"
    echo -e "${CYAN}📏 Optimiert: $optimized_length Zeichen (${length_change:+$length_change})${NC}"
    
    if [ -n "$template_used" ]; then
        echo -e "${CYAN}📋 Template: $template_used${NC}"
    fi
    
    # Optimierung protokollieren
    update_usage_analytics "prompt_optimizations" "length_change:$length_change"
    
    echo "$optimized_prompt"
}

# Aktuelles Budget abrufen
get_remaining_budget() {
    local period="${1:-daily}"
    local date_filter
    
    case "$period" in
        "daily")
            date_filter=$(date +"%Y-%m-%d")
            ;;
        "weekly")
            date_filter=$(date -d "monday" +"%Y-%m-%d")
            ;;
        "monthly")
            date_filter=$(date +"%Y-%m")
            ;;
    esac
    
    # Budget-Limit laden
    local budget_limit=$(jq -r --arg period "$period" '.budgets[$period]' "$COST_CONFIG" 2>/dev/null || echo "5.00")
    
    # Verwendete Kosten berechnen
    local used_cost="0.0"
    if [ -f "$COST_TRACKING" ]; then
        case "$period" in
            "daily")
                used_cost=$(jq -r --arg date "$date_filter" '.[$date] // [] | map(.cost) | add // 0' "$COST_TRACKING" 2>/dev/null || echo "0.0")
                ;;
            "weekly"|"monthly")
                used_cost=$(jq -r --arg filter "$date_filter" '[to_entries[] | select(.key | startswith($filter)) | .value[].cost] | add // 0' "$COST_TRACKING" 2>/dev/null || echo "0.0")
                ;;
        esac
    fi
    
    local remaining=$(echo "scale=2; $budget_limit - $used_cost" | bc -l)
    echo "$remaining"
}

# Kosten tracken
track_cost() {
    local model="$1"
    local cost="$2"
    local operation_type="$3"
    local input_tokens="$4"
    local output_tokens="$5"
    
    local date=$(date +"%Y-%m-%d")
    local timestamp=$(date -Iseconds)
    
    # Kosten-Eintrag erstellen
    local cost_entry=$(jq -n \
        --arg model "$model" \
        --arg cost "$cost" \
        --arg operation "$operation_type" \
        --arg input_tokens "$input_tokens" \
        --arg output_tokens "$output_tokens" \
        --arg timestamp "$timestamp" \
        '{
            model: $model,
            cost: ($cost | tonumber),
            operation: $operation,
            input_tokens: ($input_tokens | tonumber),
            output_tokens: ($output_tokens | tonumber),
            timestamp: $timestamp
        }')
    
    # In Tracking-Datei hinzufügen
    jq --arg date "$date" --argjson entry "$cost_entry" \
        '.[$date] = (.[$date] // []) + [$entry]' \
        "$COST_TRACKING" > "${COST_TRACKING}.tmp" && \
        mv "${COST_TRACKING}.tmp" "$COST_TRACKING"
    
    # Usage Analytics aktualisieren
    jq --arg cost "$cost" --arg model "$model" \
        '.total_operations += 1 |
         .total_cost += ($cost | tonumber) |
         .model_usage[$model] = (.model_usage[$model] // 0) + 1' \
        "$USAGE_ANALYTICS" > "${USAGE_ANALYTICS}.tmp" && \
        mv "${USAGE_ANALYTICS}.tmp" "$USAGE_ANALYTICS"
    
    echo -e "${GREEN}✅ Kosten getrackt: \$${cost} für $model${NC}"
}

# Usage Analytics aktualisieren
update_usage_analytics() {
    local metric="$1"
    local value="$2"
    
    if [ ! -f "$USAGE_ANALYTICS" ]; then
        return 1
    fi
    
    jq --arg metric "$metric" --arg value "$value" \
        '.optimization_stats[$metric] = (.optimization_stats[$metric] // 0) + 1' \
        "$USAGE_ANALYTICS" > "${USAGE_ANALYTICS}.tmp" && \
        mv "${USAGE_ANALYTICS}.tmp" "$USAGE_ANALYTICS"
}

# Kostenoptimierungs-Report
generate_cost_report() {
    local period="${1:-daily}"
    
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                    KOSTENOPTIMIERUNGS-REPORT                 ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Budget-Status
    local remaining_budget=$(get_remaining_budget "$period")
    local budget_limit=$(jq -r --arg period "$period" '.budgets[$period]' "$COST_CONFIG" 2>/dev/null || echo "5.00")
    local used_budget=$(echo "$budget_limit - $remaining_budget" | bc -l)
    local usage_percentage=$(echo "scale=1; $used_budget * 100 / $budget_limit" | bc -l)
    
    echo -e "${CYAN}=== BUDGET-STATUS ($period) ===${NC}"
    echo -e "${YELLOW}💰 Budget-Limit: \$${budget_limit}${NC}"
    echo -e "${YELLOW}💸 Verwendet: \$${used_budget} (${usage_percentage}%)${NC}"
    echo -e "${YELLOW}💳 Verbleibend: \$${remaining_budget}${NC}"
    
    # Warnung bei hoher Nutzung
    local warning_threshold=$(jq -r '.thresholds.warning' "$COST_CONFIG" 2>/dev/null || echo "0.8")
    if [ "$(echo "$usage_percentage / 100 > $warning_threshold" | bc -l)" = "1" ]; then
        echo -e "${RED}⚠️  WARNUNG: Budget-Limit erreicht bald!${NC}"
    fi
    
    echo ""
    
    # Modell-Nutzung
    echo -e "${CYAN}=== MODELL-NUTZUNG ===${NC}"
    if [ -f "$USAGE_ANALYTICS" ]; then
        jq -r '.model_usage | to_entries[] | "\(.key): \(.value) Operationen"' "$USAGE_ANALYTICS" | while read -r line; do
            echo -e "${GREEN}📊 $line${NC}"
        done
    fi
    
    echo ""
    
    # Optimierungs-Statistiken
    echo -e "${CYAN}=== OPTIMIERUNGS-ERFOLG ===${NC}"
    if [ -f "$USAGE_ANALYTICS" ]; then
        local template_reuse=$(jq -r '.optimization_stats.template_reuse // 0' "$USAGE_ANALYTICS")
        local auto_selection=$(jq -r '.optimization_stats.auto_model_selection // 0' "$USAGE_ANALYTICS")
        local prompt_opts=$(jq -r '.optimization_stats.prompt_optimizations // 0' "$USAGE_ANALYTICS")
        local total_savings=$(jq -r '.cost_savings // 0' "$USAGE_ANALYTICS")
        
        echo -e "${GREEN}🔄 Template-Wiederverwendung: $template_reuse mal${NC}"
        echo -e "${GREEN}🤖 Automatische Modellwahl: $auto_selection mal${NC}"
        echo -e "${GREEN}✨ Prompt-Optimierungen: $prompt_opts mal${NC}"
        echo -e "${GREEN}💰 Geschätzte Ersparnis: \$${total_savings}${NC}"
    fi
    
    echo ""
    
    # Empfehlungen
    echo -e "${CYAN}=== OPTIMIERUNGS-EMPFEHLUNGEN ===${NC}"
    
    # Budget-basierte Empfehlungen
    if [ "$(echo "$remaining_budget < 1.0" | bc -l)" = "1" ]; then
        echo -e "${YELLOW}💡 Verwende ausschließlich claude-3.5-haiku für verbleibende Operationen${NC}"
    elif [ "$(echo "$remaining_budget < 3.0" | bc -l)" = "1" ]; then
        echo -e "${YELLOW}💡 Bevorzuge claude-3.5-haiku für einfache Aufgaben${NC}"
    fi
    
    # Template-Empfehlungen
    if [ "$template_reuse" -lt 5 ]; then
        echo -e "${YELLOW}💡 Nutze mehr Templates für 60-70% Kostenersparnis${NC}"
    fi
    
    echo -e "${YELLOW}💡 Verwende Batch-Processing für mehrere ähnliche Operationen${NC}"
    echo -e "${YELLOW}💡 Aktiviere Prompt-Caching für wiederkehrende Aufgaben${NC}"
}

# Batch-Kostenoptimierung
optimize_batch() {
    local batch_file="$1"
    local task_type="$2"
    
    if [ ! -f "$batch_file" ]; then
        echo -e "${RED}❌ Batch-Datei nicht gefunden: $batch_file${NC}"
        return 1
    fi
    
    echo -e "${BLUE}=== BATCH-OPTIMIERUNG ===${NC}"
    
    local total_prompts=$(wc -l < "$batch_file")
    local estimated_savings=0
    
    echo -e "${CYAN}📦 Batch-Größe: $total_prompts Prompts${NC}"
    
    # Optimales Modell für Batch bestimmen
    local batch_model=$(jq -r --arg task "$task_type" '.task_model_mapping[$task] // "claude-3.5-haiku"' "$COST_CONFIG")
    echo -e "${CYAN}🎯 Batch-Modell: $batch_model${NC}"
    
    # Kosten schätzen
    local total_estimated_cost=0
    while IFS= read -r prompt; do
        if [ -n "$prompt" ]; then
            local cost=$(estimate_cost "$prompt" "$batch_model" "0.3")
            total_estimated_cost=$(echo "$total_estimated_cost + $cost" | bc -l)
        fi
    done < "$batch_file"
    
    # Batch-Rabatt anwenden (50% Ersparnis laut API)
    local batch_cost=$(echo "$total_estimated_cost * 0.5" | bc -l)
    local savings=$(echo "$total_estimated_cost - $batch_cost" | bc -l)
    
    echo -e "${YELLOW}💰 Einzelkosten: \$${total_estimated_cost}${NC}"
    echo -e "${GREEN}💰 Batch-Kosten: \$${batch_cost}${NC}"
    echo -e "${GREEN}💰 Ersparnis: \$${savings} (50%)${NC}"
    
    # Ersparnis in Analytics aktualisieren
    if [ -f "$USAGE_ANALYTICS" ]; then
        jq --arg savings "$savings" \
            '.cost_savings = (.cost_savings + ($savings | tonumber))' \
            "$USAGE_ANALYTICS" > "${USAGE_ANALYTICS}.tmp" && \
            mv "${USAGE_ANALYTICS}.tmp" "$USAGE_ANALYTICS"
    fi
    
    echo -e "${GREEN}✅ Batch-Optimierung abgeschlossen${NC}"
}

# Hauptprogramm
case "${1:-help}" in
    "init")
        init_cost_optimizer
        ;;
    "select-model")
        select_optimal_model "$2" "$3" "$4" "$5"
        ;;
    "estimate")
        estimate_cost "$2" "$3" "$4"
        ;;
    "optimize-prompt")
        optimize_prompt "$2" "$3" "$4"
        ;;
    "budget")
        get_remaining_budget "$2"
        ;;
    "track")
        track_cost "$2" "$3" "$4" "$5" "$6"
        ;;
    "report")
        generate_cost_report "$2"
        ;;
    "batch")
        optimize_batch "$2" "$3"
        ;;
    "help")
        echo "Cost Optimizer für ai-collab v$VERSION"
        echo ""
        echo "Commands:"
        echo "  init                          - Kostenoptimierung initialisieren"
        echo "  select-model <task> <complexity> <priority> <budget> - Optimales Modell auswählen"
        echo "  estimate <prompt> <model> [ratio] - Kosten schätzen"
        echo "  optimize-prompt <prompt> <task> [level] - Prompt optimieren"
        echo "  budget [period]               - Verbleibendes Budget anzeigen"
        echo "  track <model> <cost> <op> <in> <out> - Kosten tracken"
        echo "  report [period]               - Kostenoptimierungs-Report"
        echo "  batch <file> <task>           - Batch-Optimierung"
        echo "  help                          - Diese Hilfe"
        echo ""
        echo "Beispiele:"
        echo "  $0 select-model code_review high normal 5.00"
        echo "  $0 estimate \"Fix this bug\" claude-3.5-sonnet"
        echo "  $0 optimize-prompt \"Review code\" code_review high"
        echo "  $0 report daily"
        ;;
    *)
        echo -e "${BLUE}Cost Optimizer für ai-collab${NC}"
        echo -e "${YELLOW}Verwende '$0 help' für alle Kommandos${NC}"
        ;;
esac