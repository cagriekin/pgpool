# pgpool-II Docker Image

pgpool-II is a middleware that works between PostgreSQL servers and database clients. It provides connection pooling, replication, load balancing, and limiting exceeding connections.

This image is built from official pgpool-II source releases using a minimal Debian base.

## Quick Start

```bash
docker run -d \
  --name pgpool \
  -p 9999:9999 \
  cagriekin/pgpool:4.7.0
```

## Supported Tags

- `4.7.0`, `4.6.1`, `4.5.4` - Specific pgpool-II versions
- Tags correspond to official pgpool-II release versions

## Image Details

- **Base Image:** dhi.io/debian-base:trixie
- **User:** Non-root user `pgpool` (UID 999)
- **Exposed Port:** 9999
- **Default Command:** `pgpool -n` (foreground mode)

## Configuration

### Using Custom Configuration Files

Mount your configuration files as volumes:

```bash
docker run -d \
  --name pgpool \
  -p 9999:9999 \
  -v $(pwd)/pgpool.conf:/usr/local/etc/pgpool.conf:ro \
  -v $(pwd)/pcp.conf:/usr/local/etc/pcp.conf:ro \
  -v $(pwd)/pool_hba.conf:/usr/local/etc/pool_hba.conf:ro \
  cagriekin/pgpool:4.7.0
```

### Configuration Files

Default configuration directory: `/usr/local/etc`

- `pgpool.conf` - Main configuration
- `pcp.conf` - PCP command configuration
- `pool_hba.conf` - Client authentication
- `pool_passwd` - Password file

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
    environment:
      - TZ=UTC
    restart: unless-stopped

  postgres-primary:
    image: postgres:17
    environment:
      POSTGRES_PASSWORD: example
    volumes:
      - postgres-data:/var/lib/postgresql/data

volumes:
  postgres-data:
```

### Custom Command Arguments

```bash
docker run -d \
  --name pgpool \
  -p 9999:9999 \
  -v $(pwd)/config:/etc/pgpool:ro \
  cagriekin/pgpool:4.7.0 \
  pgpool -n -f /etc/pgpool/pgpool.conf -d
```

## Common Use Cases

### Connection Pooling

Reduce connection overhead by pooling database connections:

```conf
# pgpool.conf
connection_cache = on
num_init_children = 32
max_pool = 4
```

### Load Balancing

Distribute read queries across multiple PostgreSQL servers:

```conf
# pgpool.conf
load_balance_mode = on
backend_hostname0 = 'postgres-primary'
backend_port0 = 5432
backend_weight0 = 1
backend_hostname1 = 'postgres-replica'
backend_port1 = 5432
backend_weight1 = 1
```

### High Availability with Watchdog

Enable automatic failover with watchdog:

```conf
# pgpool.conf
use_watchdog = on
wd_hostname = 'pgpool1'
wd_port = 9000
```

## Environment Variables

The image does not use environment variables for configuration by default. Configure pgpool using configuration files or command-line arguments.

## Volumes

Recommended volumes to mount:

- `/usr/local/etc` - Configuration files
- `/var/log/pgpool` - Log files (if configured)
- `/var/run/pgpool` - PID and socket files

## Health Check Example

```yaml
healthcheck:
  test: ["CMD", "pg_isready", "-h", "localhost", "-p", "9999"]
  interval: 10s
  timeout: 5s
  retries: 5
```

## Documentation

- [pgpool-II Official Documentation](https://www.pgpool.net/docs/latest/en/html/)
- [Configuration Parameters](https://www.pgpool.net/docs/latest/en/html/runtime-config.html)
- [GitHub Repository](https://github.com/pgpool/pgpool2)

## Source

Built from official pgpool-II releases available at:
https://www.pgpool.net/mediawiki/index.php/Downloads

## License

pgpool-II is released under the PostgreSQL License (similar to BSD/MIT).

