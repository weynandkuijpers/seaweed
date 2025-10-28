#!/bin/bash
# test_setup.sh - Test the SeaweedFS setup functionality

set -e

echo "Testing SeaweedFS setup..."

# Test Master Server
echo "Testing Master Server..."
if curl -s http://localhost:9333/cluster/status > /dev/null; then
    echo "✓ Master Server is responding"
else
    echo "✗ Master Server is not responding"
    exit 1
fi

# Test Filer Server
echo "Testing Filer Server..."
if curl -s http://localhost:8888/ > /dev/null; then
    echo "✓ Filer Server is responding"
else
    echo "✗ Filer Server is not responding"
    exit 1
fi

# Test Volume Servers
for i in {1..3}; do
    port=$((8079 + i))
    echo "Testing Volume Server $i (port $port)..."
    if curl -s --connect-timeout 5 http://192.168.50.33:$port/status > /dev/null; then
        echo "✓ Volume Server $i is responding"
    else
        echo "✗ Volume Server $i is not responding"
        exit 1
    fi
done

# Test file operations
echo "Testing file operations..."

# Upload a test file
echo "Hello SeaweedFS Test Setup" > test_file.txt
if curl -s -F "file=@test_file.txt" "http://localhost:8888/test_file.txt" > /dev/null; then
    echo "✓ File upload successful"
else
    echo "✗ File upload failed"
    rm -f test_file.txt
    exit 1
fi

# Download the file
if curl -s "http://localhost:8888/test_file.txt" | grep -q "Hello SeaweedFS Test Setup"; then
    echo "✓ File download successful"
else
    echo "✗ File download failed"
fi

# List directory
if curl -s "http://localhost:8888/" | grep -q "test_file.txt"; then
    echo "✓ Directory listing successful"
else
    echo "✗ Directory listing failed"
fi

# Cleanup
rm -f test_file.txt

echo ""
echo "All tests passed! SeaweedFS setup is working correctly."
echo ""
echo "Web Interfaces:"
echo "  Master UI: http://localhost:9333/"
echo "  Filer UI:  http://localhost:8888/"