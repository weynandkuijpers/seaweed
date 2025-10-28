#!/bin/bash
# stop_services.sh - Stop all SeaweedFS services

echo "Stopping SeaweedFS services..."

# Function to stop a service
stop_service() {
    local name=$1
    local pid_file="../logs/${name}.pid"

    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            echo "Stopping $name (PID: $pid)..."
            kill "$pid"
            # Wait for process to stop
            for i in {1..10}; do
                if ! kill -0 "$pid" 2>/dev/null; then
                    break
                fi
                sleep 1
            done
            # Force kill if still running
            if kill -0 "$pid" 2>/dev/null; then
                echo "Force killing $name..."
                kill -9 "$pid"
            fi
        else
            echo "$name is not running"
        fi
        rm -f "$pid_file"
    else
        echo "PID file for $name not found"
    fi
}

# Stop services in reverse order
stop_service "filer"
stop_service "volume3"
stop_service "volume2"
stop_service "volume1"
stop_service "master"

echo "All services stopped."