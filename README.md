# pgpool

Builds pgpool2 from source and publishes to DockerHub.

## Usage

This repository contains a GitHub Actions workflow that builds pgpool2 from the official pgpool.net downloads.

### Triggering a Build

1. Go to Actions tab in GitHub
2. Select "Build and Publish pgpool" workflow
3. Click "Run workflow"
4. Enter the desired pgpool2 version (e.g., `4.7.0`)
5. Run the workflow

The workflow will:
- Download the specified version from https://www.pgpool.net/mediawiki/download.php?f=pgpool-II-{tag}.tar.gz
- Build pgpool2 using dhi/debian-base base image
- Publish to cagriekin/pgpool:{tag}

## Prerequisites

Configure the following secrets in GitHub repository settings:
- `DOCKER_USERNAME`: Docker registry username (used for both DockerHub and dhi.io)
- `DOCKER_TOKEN`: Docker registry access token (used for both DockerHub and dhi.io)

## Docker Image

The built image:
- Uses dhi/debian-base as base
- Runs pgpool as non-root user (uid 999)
- Exposes port 9999
- Default command: `pgpool -n`

## Configuration

Pgpool uses configuration files located in `/usr/local/etc`:
- `pgpool.conf` - Main configuration file
- `pcp.conf` - PCP command configuration
- `pool_hba.conf` - Client authentication rules
- `pool_passwd` - Password file for authentication

### Running with Default Configuration

```bash
docker run -d \
  --name pgpool \
  -p 9999:9999 \
  cagriekin/pgpool:4.7.0
```

### Running with Custom Configuration Files

Mount your configuration files as volumes:

```bash
docker run -d \
  --name pgpool \
  -p 9999:9999 \
  -v /path/to/pgpool.conf:/usr/local/etc/pgpool.conf:ro \
  -v /path/to/pcp.conf:/usr/local/etc/pcp.conf:ro \
  -v /path/to/pool_hba.conf:/usr/local/etc/pool_hba.conf:ro \
  cagriekin/pgpool:4.7.0
```

### Running with Custom Command-line Arguments

Override the default command to pass custom arguments:

```bash
docker run -d \
  --name pgpool \
  -p 9999:9999 \
  -v /path/to/config:/etc/pgpool:ro \
  cagriekin/pgpool:4.7.0 \
  pgpool -n -f /etc/pgpool/pgpool.conf -d
```

Common pgpool arguments:
- `-n` - Run in foreground mode (required for Docker)
- `-f CONFIG_FILE` - Specify pgpool.conf path
- `-F PCP_FILE` - Specify pcp.conf path
- `-a HBA_FILE` - Specify pool_hba.conf path
- `-d` - Enable debug mode

### Docker Compose Example

```yaml
version: '3.8'

services:
  pgpool:
    image: cagriekin/pgpool:4.7.0
    ports:
      - "9999:9999"
    volumes:
      - ./pgpool.conf:/usr/local/etc/pgpool.conf:ro
      - ./pcp.conf:/usr/local/etc/pcp.conf:ro
      - ./pool_hba.conf:/usr/local/etc/pool_hba.conf:ro
    restart: unless-stopped
```

### Creating a Custom Image with Configuration

```dockerfile
FROM cagriekin/pgpool:4.7.0

USER root
COPY pgpool.conf /usr/local/etc/pgpool.conf
COPY pcp.conf /usr/local/etc/pcp.conf
COPY pool_hba.conf /usr/local/etc/pool_hba.conf
RUN chown pgpool:pgpool /usr/local/etc/pgpool.conf \
                        /usr/local/etc/pcp.conf \
                        /usr/local/etc/pool_hba.conf

USER pgpool
```

### Configuration Resources

For detailed configuration options, refer to the official pgpool-II documentation:
- [pgpool.conf parameters](https://www.pgpool.net/docs/latest/en/html/runtime-config.html)
- [Authentication setup](https://www.pgpool.net/docs/latest/en/html/auth-methods.html)
- [Connection pooling](https://www.pgpool.net/docs/latest/en/html/runtime-config-connection-pooling.html)
