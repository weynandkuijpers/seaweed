# SeaweedFS Single-Node Test Setup Installation Manual

## Overview
This manual provides step-by-step instructions to set up a SeaweedFS test environment on a single node with 1 master server, 1 filer server, and 3 volume servers.

## Prerequisites
Before starting, ensure all prerequisites from `prerequisites.md` are met.

## Step 1: Download and Install SeaweedFS

### Option 1: Download Pre-built Binaries
```bash
# Create installation directory
sudo mkdir -p /opt/seaweedfs/bin
cd /opt/seaweedfs/bin

# Download latest release (replace VERSION with actual version)
wget https://github.com/seaweedfs/seaweedfs/releases/download/VERSION/linux_amd64.tar.gz
tar -xzf linux_amd64.tar.gz
chmod +x weed
```

### Option 2: Build from Source
```bash
# Install Go if not already installed
# Visit https://golang.org/dl/ for installation instructions

git clone https://github.com/seaweedfs/seaweedfs.git
cd seaweedfs
make install
sudo cp weed /opt/seaweedfs/bin/
```

## Step 2: Create Directory Structure
```bash
sudo mkdir -p /opt/seaweedfs/{data/master,data/filer,data/volume1,data/volume2,data/volume3,config,logs}
sudo chown -R $USER:$USER /opt/seaweedfs
```

## Step 3: Configure Components

### Master Server Configuration
Create `/opt/seaweedfs/config/master.toml`:
```toml
port=9333
defaultReplication=001
volumeSizeLimitMB=1024
mdir=data/master
```

### Filer Server Configuration
Create `/opt/seaweedfs/config/filer.toml`:
```toml
port=8888
master=localhost:9333
defaultReplicaPlacement=001
```

### Volume Server Configurations

#### Volume Server 1 (`/opt/seaweedfs/config/volume1.toml`):
```toml
port=8080
publicUrl=localhost:8080
dataCenter=dc1
rack=rack1
dir=data/volume1
max=0
ip=localhost
mserver=localhost:9333
```

#### Volume Server 2 (`/opt/seaweedfs/config/volume2.toml`):
```toml
port=8081
publicUrl=localhost:8081
dataCenter=dc1
rack=rack1
dir=data/volume2
max=0
ip=localhost
mserver=localhost:9333
```

#### Volume Server 3 (`/opt/seaweedfs/config/volume3.toml`):
```toml
port=8082
publicUrl=localhost:8082
dataCenter=dc1
rack=rack1
dir=data/volume3
max=0
ip=localhost
mserver=localhost:9333
```

### Create Configuration Files Script
Create a script file `create_config.sh` with the following content and run it:
```bash
#!/bin/bash
# create_config.sh

mkdir -p /opt/seaweedfs/config

# Master config
cat > /opt/seaweedfs/config/master.toml << 'EOF'
port=9333
defaultReplication=001
volumeSizeLimitMB=1024
mdir=data/master
EOF

# Filer config
cat > /opt/seaweedfs/config/filer.toml << 'EOF'
port=8888
master=localhost:9333
defaultReplicaPlacement=001
EOF

# Volume configs
for i in {1..3}; do
    port=$((8079 + i))
    cat > /opt/seaweedfs/config/volume${i}.toml << EOF
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

echo "Configuration files created successfully"
```

Make it executable and run:
```bash
chmod +x create_config.sh
./create_config.sh
```

## Step 4: Start Services

### Start Master Server
```bash
cd /opt/seaweedfs
nohup ./bin/weed master -options=config/master.toml > logs/master.log 2>&1 &
echo $! > master.pid
```

### Start Volume Servers
```bash
# Volume Server 1
nohup ./bin/weed volume -options=config/volume1.toml > logs/volume1.log 2>&1 &
echo $! > volume1.pid

# Volume Server 2
nohup ./bin/weed volume -options=config/volume2.toml > logs/volume2.log 2>&1 &
echo $! > volume2.pid

# Volume Server 3
nohup ./bin/weed volume -options=config/volume3.toml > logs/volume3.log 2>&1 &
echo $! > volume3.pid
```

### Start Filer Server
```bash
nohup ./bin/weed filer -options=config/filer.toml > logs/filer.log 2>&1 &
echo $! > filer.pid
```

## Step 5: Verify Installation

### Check Service Status
```bash
# Check if processes are running
ps aux | grep weed

# Check Master Server
curl http://localhost:9333/cluster/status

# Check Filer Server
curl http://localhost:8888/

# Check Volume Servers
curl http://localhost:8080/status
curl http://localhost:8081/status
curl http://localhost:8082/status
```

### Test File Operations
```bash
# Upload a test file
echo "Hello SeaweedFS" > test.txt
curl -F file=@test.txt "http://localhost:8888/test.txt"

# Download the file
curl "http://localhost:8888/test.txt"

# List directory
curl "http://localhost:8888/"
```

## Step 6: Access Web Interfaces

- **Master Server UI**: http://localhost:9333/
- **Filer Server UI**: http://localhost:8888/

## Step 7: Stop Services (When Needed)
```bash
# Stop all services
kill $(cat master.pid)
kill $(cat volume1.pid)
kill $(cat volume2.pid)
kill $(cat volume3.pid)
kill $(cat filer.pid)

# Clean up PID files
rm *.pid
```

## Troubleshooting

### Common Issues

1. **Port conflicts**: Check if ports are already in use
   ```bash
   netstat -tlnp | grep :9333
   ```

2. **Permission issues**: Ensure proper permissions on data directories
   ```bash
   chmod -R 755 /opt/seaweedfs/data
   ```

3. **Service not starting**: Check log files
   ```bash
   tail -f /opt/seaweedfs/logs/*.log
   ```

### Logs Location
- Master: `/opt/seaweedfs/logs/master.log`
- Filer: `/opt/seaweedfs/logs/filer.log`
- Volume1: `/opt/seaweedfs/logs/volume1.log`
- Volume2: `/opt/seaweedfs/logs/volume2.log`
- Volume3: `/opt/seaweedfs/logs/volume3.log`

## Next Steps
- Configure replication settings
- Set up monitoring
- Configure backup strategies
- Test with actual workloads

## Best Practices for Production

### Security
- Use HTTPS/TLS for all communications
- Implement authentication and authorization
- Configure firewall rules properly
- Regularly update SeaweedFS to latest stable version

### Monitoring
- Monitor disk usage, CPU, and memory
- Set up alerts for service failures
- Use the built-in metrics endpoints
- Implement log aggregation

### Backup
- Regular backups of metadata (filer store)
- Backup volume data
- Test restore procedures
- Implement off-site backups

### Performance Tuning
- Adjust volume size limits based on workload
- Configure appropriate replication levels
- Monitor and optimize disk I/O
- Tune JVM settings if using Java clients

## Troubleshooting Guide

### Service Won't Start
1. Check port availability: `netstat -tlnp | grep :PORT`
2. Verify configuration file syntax
3. Check file permissions on data directories
4. Review log files for error messages

### High Memory Usage
- Reduce volume server cache sizes
- Monitor for memory leaks
- Consider increasing system RAM

### Slow Performance
- Check disk I/O performance
- Verify network connectivity
- Monitor CPU usage
- Review replication settings

### Data Inconsistency
- Check volume server health
- Verify master-filer communication
- Run consistency checks
- Restore from backup if necessary