#!/bin/bash
# SimplyKI Backup Manager
# Erstellt: 2025-07-24 17:20:00 CEST

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
BACKUP_ROOT="${BACKUP_ROOT:-/home/aicollab/backups}"
BACKUP_EXCLUDE="${BACKUP_EXCLUDE:-/home/aicollab/.backup-exclude}"
MAX_BACKUPS="${MAX_BACKUPS:-7}"

# Ensure backup directory exists
mkdir -p "$BACKUP_ROOT"

# Functions
log() {
    echo -e "${BLUE}[BACKUP]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    exit 1
}

success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

create_backup() {
    local backup_type="${1:-full}"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_name="simplyKI_${backup_type}_${timestamp}"
    local backup_path="$BACKUP_ROOT/$backup_name"
    
    log "Creating $backup_type backup: $backup_name"
    
    # Create exclude file if not exists
    if [[ ! -f "$BACKUP_EXCLUDE" ]]; then
        cat > "$BACKUP_EXCLUDE" << EOF
.git
node_modules
target
dist
*.log
*.tmp
.cache
EOF
        log "Created default exclude file"
    fi
    
    # Perform backup
    if [[ "$backup_type" == "full" ]]; then
        tar czf "${backup_path}.tar.gz" \
            --exclude-from="$BACKUP_EXCLUDE" \
            -C /home/aicollab \
            SimplyKI-repo \
            2>/dev/null || true
    else
        # Differential backup
        local last_full=$(find "$BACKUP_ROOT" -name "simplyKI_full_*.tar.gz" -type f | sort | tail -1)
        if [[ -z "$last_full" ]]; then
            warning "No full backup found, creating full backup instead"
            create_backup "full"
            return
        fi
        
        tar czf "${backup_path}.tar.gz" \
            --exclude-from="$BACKUP_EXCLUDE" \
            --newer-mtime="$last_full" \
            -C /home/aicollab \
            SimplyKI-repo \
            2>/dev/null || true
    fi
    
    local size=$(du -h "${backup_path}.tar.gz" 2>/dev/null | cut -f1)
    success "Backup created: ${backup_name}.tar.gz (${size})"
    
    # Cleanup old backups
    cleanup_old_backups
}

list_backups() {
    log "Available backups:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [[ -d "$BACKUP_ROOT" ]]; then
        find "$BACKUP_ROOT" -name "simplyKI_*.tar.gz" -type f -exec ls -lh {} \; | \
            awk '{print $9 " - " $5}' | sort -r
    else
        warning "No backups found"
    fi
}

restore_backup() {
    local backup_file="$1"
    
    if [[ ! -f "$backup_file" ]]; then
        error "Backup file not found: $backup_file"
    fi
    
    log "Restoring from: $(basename "$backup_file")"
    
    # Create restore directory
    local restore_dir="/tmp/simplyKI_restore_$(date +%s)"
    mkdir -p "$restore_dir"
    
    # Extract backup
    tar xzf "$backup_file" -C "$restore_dir"
    
    success "Backup extracted to: $restore_dir"
    echo "To complete restore, run:"
    echo "  rsync -av $restore_dir/SimplyKI-repo/ /home/aicollab/SimplyKI-repo/"
}

cleanup_old_backups() {
    local count=$(find "$BACKUP_ROOT" -name "simplyKI_*.tar.gz" -type f | wc -l)
    
    if [[ $count -gt $MAX_BACKUPS ]]; then
        local to_remove=$((count - MAX_BACKUPS))
        log "Removing $to_remove old backup(s)"
        
        find "$BACKUP_ROOT" -name "simplyKI_*.tar.gz" -type f | \
            sort | head -n $to_remove | xargs rm -f
    fi
}

# Main
case "${1:-status}" in
    create)
        create_backup "${2:-full}"
        ;;
    list)
        list_backups
        ;;
    restore)
        restore_backup "$2"
        ;;
    cleanup)
        cleanup_old_backups
        success "Cleanup completed"
        ;;
    status)
        echo "SimplyKI Backup Manager"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Backup Root: $BACKUP_ROOT"
        echo "Max Backups: $MAX_BACKUPS"
        echo ""
        list_backups
        ;;
    *)
        echo "Usage: $0 {create|list|restore|cleanup|status} [options]"
        echo ""
        echo "Commands:"
        echo "  create [full|diff]  Create backup (default: full)"
        echo "  list                List all backups"
        echo "  restore <file>      Restore from backup"
        echo "  cleanup             Remove old backups"
        echo "  status              Show backup status"
        exit 1
        ;;
esac