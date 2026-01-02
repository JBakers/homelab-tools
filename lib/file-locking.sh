#!/bin/bash
# lib/file-locking.sh - File locking utilities for concurrent execution protection
# Usage: source "$LIB_DIR/file-locking.sh"

# Acquire a lock file
# Usage: acquire_lock "lockfile_path" [timeout_seconds]
# Returns: 0 if lock acquired, 1 if failed
acquire_lock() {
    local lockfile="$1"
    local timeout="${2:-10}"
    local start_time=$SECONDS
    
    # Create lock directory if needed
    mkdir -p "$(dirname "$lockfile")"
    
    # Try to acquire lock with timeout
    while (( SECONDS - start_time < timeout )); do
        # Try to create lock file atomically
        if mkdir "$lockfile" 2>/dev/null; then
            # Store PID in lock
            echo $$ > "$lockfile/pid"
            return 0
        fi
        
        # Check if stale lock (process died)
        if [[ -f "$lockfile/pid" ]]; then
            local lock_pid
            lock_pid=$(cat "$lockfile/pid" 2>/dev/null)
            if [[ -n "$lock_pid" ]] && ! kill -0 "$lock_pid" 2>/dev/null; then
                # Stale lock, remove it
                rm -rf "$lockfile"
                continue
            fi
        fi
        
        sleep 0.5
    done
    
    return 1
}

# Release a lock file
# Usage: release_lock "lockfile_path"
release_lock() {
    local lockfile="$1"
    
    # Only release if we own the lock
    if [[ -f "$lockfile/pid" ]]; then
        local lock_pid
        lock_pid=$(cat "$lockfile/pid" 2>/dev/null)
        if [[ "$lock_pid" == "$$" ]]; then
            rm -rf "$lockfile"
        fi
    fi
}

# Setup automatic lock cleanup on exit
# Usage: setup_lock_cleanup "lockfile_path"
setup_lock_cleanup() {
    local lockfile="$1"
    trap "release_lock '$lockfile'" EXIT INT TERM
}

export -f acquire_lock release_lock setup_lock_cleanup
