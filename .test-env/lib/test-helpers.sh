#!/bin/bash
# Test Helper Functions
# Provides progress monitoring and timeout handling for tests

# Run command with live progress dots
run_with_progress() {
    local cmd="$1"
    local desc="$2"
    local timeout="${3:-120}"  # Default 2 minutes
    
    echo ""
    echo "▶ $desc"
    echo "  Command: $cmd"
    echo "  Timeout: ${timeout}s"
    echo ""
    
    # Start command in background with output
    (
        eval "$cmd"
        echo $? > /tmp/test-exit-code-$$
    ) &
    local pid=$!
    
    # Show progress dots while running
    local elapsed=0
    while kill -0 $pid 2>/dev/null; do
        if [[ $elapsed -ge $timeout ]]; then
            kill -9 $pid 2>/dev/null
            echo ""
            echo "⚠ TIMEOUT after ${timeout}s - killing process"
            return 124
        fi
        
        echo -n "."
        sleep 2
        elapsed=$((elapsed + 2))
    done
    
    wait $pid 2>/dev/null
    local exit_code
    exit_code=$(cat /tmp/test-exit-code-$$ 2>/dev/null || echo 1)
    rm -f /tmp/test-exit-code-$$
    
    echo ""
    if [[ $exit_code -eq 0 ]]; then
        echo "✓ Completed in ${elapsed}s"
    else
        echo "✗ Failed with exit code $exit_code after ${elapsed}s"
    fi
    echo ""
    
    return "$exit_code"
}

# Run test with timeout and live output
test_with_timeout() {
    local timeout="${1:-60}"  # Default 60 seconds
    local test_script="$2"
    local test_name
    test_name=$(basename "$test_script")
    
    echo ""
    echo "════════════════════════════════════════════════════════════"
    echo "Running: $test_name (max ${timeout}s)"
    echo "════════════════════════════════════════════════════════════"
    
    # Detect if it's an expect script
    local runner="bash"
    if [[ "$test_script" == *.exp ]]; then
        runner="expect"
    fi
    
    # Run with timeout, show all output
    timeout "$timeout" "$runner" "$test_script"
    local exit_code=$?
    
    if [[ $exit_code -eq 124 ]]; then
        echo ""
        echo "⚠ TEST TIMEOUT: $test_name exceeded ${timeout}s"
        echo "  This test may be hanging on user input or infinite loop"
        return 1
    elif [[ $exit_code -ne 0 ]]; then
        echo ""
        echo "✗ TEST FAILED: $test_name (exit code: $exit_code)"
        return "$exit_code"
    else
        echo ""
        echo "✓ TEST PASSED: $test_name"
        return 0
    fi
}

# Show live progress for Docker commands
docker_exec_with_progress() {
    local container="$1"
    local cmd="$2"
    local desc="${3:-Running command in container}"
    
    echo ""
    echo "▶ $desc"
    echo "  Container: $container"
    echo ""
    
    # Run with live output (no buffering)
    docker compose exec -T "$container" bash -c "$cmd"
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        echo ""
        echo "✓ Command completed successfully"
    else
        echo ""
        echo "✗ Command failed with exit code $exit_code"
    fi
    
    return "$exit_code"
}

# Monitor background process with heartbeat
monitor_background() {
    local pid="$1"
    local desc="$2"
    local timeout="${3:-300}"
    
    echo "▶ $desc (PID: $pid)"
    
    local elapsed=0
    while kill -0 $pid 2>/dev/null; do
        if [[ $elapsed -ge $timeout ]]; then
            echo ""
            echo "⚠ Process timeout after ${timeout}s - killing PID $pid"
            kill -9 $pid 2>/dev/null
            return 124
        fi
        
        # Show heartbeat every 5 seconds
        if [[ $((elapsed % 5)) -eq 0 ]]; then
            echo -n "."
        fi
        
        sleep 1
        elapsed=$((elapsed + 1))
    done
    
    wait $pid 2>/dev/null
    local exit_code=$?
    
    echo ""
    echo "✓ Process completed in ${elapsed}s (exit: $exit_code)"
    
    return "$exit_code"
}
