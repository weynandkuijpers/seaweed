#!/bin/bash
# create_config.sh - Create configuration files for SeaweedFS test setup

set -e

echo "Creating SeaweedFS configuration files..."

# Create config directory if it doesn't exist
mkdir -p ../config

# Master config
cat > ../config/master.toml << 'EOF'
port=9333
defaultReplication=001
volumeSizeLimitMB=1024
mdir=data/master
EOF

# Filer config
cat > ../config/filer.toml << 'EOF'
port=8888
master=localhost:9333
defaultReplicaPlacement=001
EOF

# Volume configs
for i in {1..3}; do
    port=$((8079 + i))
    cat > ../config/volume${i}.toml << EOF
port=${port}
publicUrl=localhost:${port}
dataCenter=dc1
rack=rack1
dir=data/volume${i}
max=0
ip=localhost
mserver=localhost:9333
EOF
done

echo "Configuration files created successfully in ../config/"
echo "Creating data directories..."
mkdir -p ../data/volume2 ../data/volume3
echo "Files created:"
ls -la ../config/