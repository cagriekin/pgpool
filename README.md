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
