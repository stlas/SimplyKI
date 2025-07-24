#!/bin/bash
# Created: 2025-07-24 09:33:00 CEST
# Leichtgewichtiges System-Monitoring ohne Performance-Impact

# Konfiguration
MONITOR_LOG="/home/aicollab/local/development/logs/system-monitor.log"
MONITOR_INTERVAL=${MONITOR_INTERVAL:-60}  # Sekunden
MAX_LOG_SIZE=$((10 * 1024 * 1024))  # 10MB

# Minimaler Overhead: Nur essenzielle Metriken
log_metrics() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Memory (nur eine Zeile aus /proc/meminfo)
    local mem_info=$(grep -E '^(MemTotal|MemAvailable):' /proc/meminfo | awk '{print $2}' | paste -sd ',')
    
    # CPU (nur load average)
    local load_avg=$(cat /proc/loadavg | cut -d' ' -f1-3)
    
    # Disk I/O (nur reads/writes)
    local disk_io=$(awk '/sda/ {print $6","$10}' /proc/diskstats 2>/dev/null | head -1)
    
    # Process count
    local proc_count=$(ls /proc | grep -c '^[0-9]')
    
    # Log als CSV für minimalen Overhead
    echo "$timestamp,$mem_info,$load_avg,$disk_io,$proc_count" >> "$MONITOR_LOG"
}

# Log-Rotation (verhindert Festplatten-Füllstand)
rotate_log() {
    if [[ -f "$MONITOR_LOG" ]] && [[ $(stat -c%s "$MONITOR_LOG") -gt $MAX_LOG_SIZE ]]; then
        mv "$MONITOR_LOG" "${MONITOR_LOG}.old"
        echo "timestamp,mem_total,mem_available,load_1m,load_5m,load_15m,disk_reads,disk_writes,proc_count" > "$MONITOR_LOG"
    fi
}

# Hauptloop
if [[ "$1" == "start" ]]; then
    # Header schreiben
    echo "timestamp,mem_total,mem_available,load_1m,load_5m,load_15m,disk_reads,disk_writes,proc_count" > "$MONITOR_LOG"
    
    while true; do
        log_metrics
        rotate_log
        sleep $MONITOR_INTERVAL
    done &
    
    echo $! > /tmp/lightweight-monitor.pid
    echo "Monitor gestartet (PID: $!)"
    
elif [[ "$1" == "stop" ]]; then
    if [[ -f /tmp/lightweight-monitor.pid ]]; then
        kill $(cat /tmp/lightweight-monitor.pid) 2>/dev/null
        rm -f /tmp/lightweight-monitor.pid
        echo "Monitor gestoppt"
    fi
    
elif [[ "$1" == "analyze" ]]; then
    # Einfache Analyse der letzten Stunde
    if [[ -f "$MONITOR_LOG" ]]; then
        echo "=== System-Analyse (letzte 60 Einträge) ==="
        tail -n 61 "$MONITOR_LOG" | awk -F',' '
        NR==1 {next}
        {
            mem_used = ($2-$3)/$2*100
            load = $4
            if (mem_used > max_mem) max_mem = mem_used
            if (load > max_load) max_load = load
            sum_mem += mem_used
            sum_load += load
            count++
        }
        END {
            printf "Durchschnitt Memory: %.1f%%\n", sum_mem/count
            printf "Maximum Memory: %.1f%%\n", max_mem
            printf "Durchschnitt Load: %.2f\n", sum_load/count
            printf "Maximum Load: %.2f\n", max_load
        }'
    fi
else
    echo "Usage: $0 {start|stop|analyze}"
    echo "  start   - Startet das Monitoring (60s Intervall)"
    echo "  stop    - Stoppt das Monitoring"
    echo "  analyze - Zeigt Analyse der letzten Stunde"
fi