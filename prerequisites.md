# SeaweedFS Installation Prerequisites

## System Requirements

### Operating System
- Linux (Ubuntu 18.04+, CentOS 7+, RHEL 7+)
- macOS (10.14+)
- Windows (10+ with WSL recommended)

### Hardware Requirements
- **CPU**: 2+ cores recommended
- **RAM**: 4GB+ minimum, 8GB+ recommended
- **Disk**: 10GB+ free space for data storage
- **Network**: Stable network connection

### Software Dependencies

#### Required
- **Go**: Version 1.19 or later (only if building from source)
- **Git**: For cloning repository (optional)

#### Optional but Recommended
- **Docker**: For containerized deployment
- **curl/wget**: For downloading binaries
- **tar/gzip**: For extracting archives

## Network Requirements

### Ports
Ensure the following ports are available and not blocked by firewall:

| Component | Default Port | Purpose |
|-----------|--------------|---------|
| Master Server | 9333 | HTTP API, Web UI |
| Filer Server | 8888 | HTTP API, WebDAV |
| Volume Server 1 | 8080 | Data storage |
| Volume Server 2 | 8081 | Data storage |
| Volume Server 3 | 8082 | Data storage |

### Firewall Configuration
```bash
# Example for Linux (adjust for your OS)
sudo ufw allow 9333/tcp
sudo ufw allow 8888/tcp
sudo ufw allow 8080/tcp
sudo ufw allow 8081/tcp
sudo ufw allow 8082/tcp
```

## Installation Methods

### Option 1: Pre-built Binaries (Recommended)
Download from GitHub releases: https://github.com/seaweedfs/seaweedfs/releases

### Option 2: Build from Source
Requires Go 1.19+
```bash
git clone https://github.com/seaweedfs/seaweedfs.git
cd seaweedfs
make install
```

### Option 3: Docker
```bash
docker pull chrislusf/seaweedfs:latest
```

## Directory Structure
Create the following directory structure for the setup:
```
/opt/seaweedfs/
├── bin/           # SeaweedFS binaries
├── data/          # Data directories
│   ├── master/
│   ├── filer/
│   ├── volume1/
│   ├── volume2/
│   └── volume3/
├── config/        # Configuration files
└── logs/          # Log files
```

## Environment Variables
Set these environment variables for optimal performance:
```bash
export WEED_HOME=/opt/seaweedfs
export PATH=$PATH:$WEED_HOME/bin