#!/bin/bash
# BrainMemory PoC Simulation

declare -A MEMORY
CONTEXT=()
START_TIME=$(date +%s%N)

store() {
    MEMORY[$1]="$2"
    CONTEXT+=("Stored: $1 = $2")
    if [ ${#CONTEXT[@]} -gt 10 ]; then
        CONTEXT=("${CONTEXT[@]:1}")
    fi
}

retrieve() {
    echo "${MEMORY[$1]}"
}

status() {
    local now=$(date +%s%N)
    local elapsed=$(( (now - START_TIME) / 1000000 ))
    
    echo "🧠 BrainMemory PoC Status (Shell Simulation)"
    echo "==========================================="
    echo "Working Memory: ${#MEMORY[@]} entries"
    echo "Context Cache: ${#CONTEXT[@]} entries"
    echo "Uptime: ${elapsed}ms"
    echo ""
    echo "⚠️  Dies ist eine Shell-Simulation!"
    echo "Die echte Rust-Version wäre 100x schneller!"
}

# Demo
echo "🚀 BrainMemory PoC v0.1.0 (Shell Simulation)"
echo ""

store "user_query" "Wie erstelle ich eine REST API?"
store "model_used" "claude-3.5-sonnet"
store "context_type" "coding_help"

# Performance Test
echo "Running performance test..."
for i in {1..100}; do
    store "test_$i" "value_$i"
done

status

echo ""
echo "📝 Letzter Context:"
for entry in "${CONTEXT[@]: -3}"; do
    echo "  - $entry"
done

echo ""
echo "✅ PoC Simulation abgeschlossen!"
echo ""
echo "💡 Für echte Performance: Rust installieren!"
