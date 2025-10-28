#!/bin/bash
# start_services.sh - Start all SeaweedFS services for test setup

set -e

# Check if weed binary is available in PATH
if ! command -v weed >/dev/null 2>&1; then
    echo "Error: 'weed' command not found in PATH. Please install SeaweedFS and ensure 'weed' is available in your PATH."
    exit 1
fi

echo "Starting SeaweedFS services..."

# Function to start a service in background
start_service() {
    local name=$1
    local command=$2
    local log_file=$3

    echo "Starting $name..."
    # Ensure log file exists and is writable
    mkdir -p ../logs
    touch ../logs/${log_file}.log
    nohup $command >> ../logs/${log_file}.log 2>&1 &
    local pid=$!
    sleep 1  # Give process time to start
    if kill -0 $pid 2>/dev/null; then
        echo $pid > ../logs/${name}.pid
        echo "$name started with PID $pid"
    else
        echo "Failed to start $name"
        return 1
    fi
}

# Start Master Server
start_service "master" "weed master -port=9333 -mdir=../data/master" "master"

# Wait a moment for master to initialize
sleep 2

# Start Volume Servers
for i in {1..3}; do
    port=$((8079 + i))
    start_service "volume${i}" "weed volume -port=${port} -dir=../data/volume${i} -mserver=localhost:9333" "volume${i}"
done

# Start Filer Server
start_service "filer" "weed filer -port=8888 -master=localhost:9333" "filer"

echo ""
echo "All services started successfully!"
echo "Master Server: http://localhost:9333"
echo "Filer Server: http://localhost:8888"
echo "Volume Servers: http://localhost:8080, http://localhost:8081, http://localhost:8082"
echo ""
echo "Check logs in ../logs/ directory"
echo "Use stop_services.sh to stop all services"