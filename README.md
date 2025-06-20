# mcp-remote Docker Distribution

This repository provides Docker images for [mcp-remote](https://github.com/geelen/mcp-remote), a tool that connects MCP clients (Claude Desktop, Cursor, Windsurf) that only support local stdio servers to remote MCP servers with OAuth authentication support.

> **Note**: This is a Docker-focused fork. For the npm package and full documentation, please visit the [upstream repository](https://github.com/geelen/mcp-remote).

## Quick Start

### Using Pre-built Images

```bash
# Pull the latest image
docker pull ghcr.io/offendingcommit/mcp-remote:latest

# Run the proxy
docker run -it ghcr.io/offendingcommit/mcp-remote:latest https://your-remote-mcp.server/sse
```

### Building Locally

```bash
# Clone the repository
git clone https://github.com/offendingcommit/mcp-remote.git
cd mcp-remote

# Build the image
docker build -t mcp-remote:latest .

# Run the proxy
docker run -it mcp-remote:latest https://your-remote-mcp.server/sse
```

## MCP Client Configuration

### Claude Desktop

Edit your configuration file:
- macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
- Windows: `%APPDATA%\Claude\claude_desktop_config.json`

```json
{
  "mcpServers": {
    "remote-example": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-v",
        "mcp-auth:/home/mcp/.mcp-auth",
        "ghcr.io/offendingcommit/mcp-remote:latest",
        "https://your-remote-mcp.server/sse"
      ]
    }
  }
}
```

### Cursor

Edit `~/.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "remote-example": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-v",
        "mcp-auth:/home/mcp/.mcp-auth",
        "ghcr.io/offendingcommit/mcp-remote:latest",
        "https://your-remote-mcp.server/sse"
      ]
    }
  }
}
```

### Windsurf

Edit `~/.codeium/windsurf/mcp_config.json`:

```json
{
  "mcpServers": {
    "remote-example": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-v",
        "mcp-auth:/home/mcp/.mcp-auth",
        "ghcr.io/offendingcommit/mcp-remote:latest",
        "https://your-remote-mcp.server/sse"
      ]
    }
  }
}
```

## Docker Features

### Persistent Token Storage

OAuth tokens are stored in a Docker volume for persistence across container runs:

```bash
# Create a named volume
docker volume create mcp-auth

# Use the volume
docker run -it -v mcp-auth:/home/mcp/.mcp-auth ghcr.io/offendingcommit/mcp-remote:latest https://your-server/sse
```

### OAuth Callback Handling

For OAuth authentication flows, you need to handle the callback URL:

#### Option 1: Port Forwarding (Recommended)
```bash
docker run -it -p 3334:3334 ghcr.io/offendingcommit/mcp-remote:latest https://your-server/sse
```

#### Option 2: Host Network Mode (Linux only)
```bash
docker run -it --network host ghcr.io/offendingcommit/mcp-remote:latest https://your-server/sse
```

### Environment Variables

```bash
# Custom headers with environment variables
docker run -it \
  -e AUTH_TOKEN="your-token-here" \
  ghcr.io/offendingcommit/mcp-remote:latest \
  https://your-server/sse \
  --header "Authorization: Bearer ${AUTH_TOKEN}"

# Debug mode
docker run -it \
  -v mcp-auth:/home/mcp/.mcp-auth \
  ghcr.io/offendingcommit/mcp-remote:latest \
  https://your-server/sse \
  --debug
```

### Using Docker Compose

```yaml
version: '3.8'

services:
  mcp-remote:
    image: ghcr.io/offendingcommit/mcp-remote:latest
    container_name: mcp-remote
    volumes:
      - mcp-auth:/home/mcp/.mcp-auth
    environment:
      # AUTH_TOKEN: your-token-here
    ports:
      - "3334:3334"  # For OAuth callback
    command: ["https://your-remote-mcp.server/sse"]
    restart: unless-stopped

volumes:
  mcp-auth:
    driver: local
```

Run with: `docker-compose up`

## Available Images

- `ghcr.io/offendingcommit/mcp-remote:latest` - Latest stable release
- `ghcr.io/offendingcommit/mcp-remote:main` - Latest main branch build
- `ghcr.io/offendingcommit/mcp-remote:v*` - Specific version tags

### Supported Platforms

- `linux/amd64`
- `linux/arm64`

## Command Line Options

All standard mcp-remote options are supported:

```bash
# Custom callback port
docker run -it -p 9696:9696 ghcr.io/offendingcommit/mcp-remote:latest https://server/sse 9696

# Custom callback host
docker run -it ghcr.io/offendingcommit/mcp-remote:latest https://server/sse --host "127.0.0.1"

# Transport strategy
docker run -it ghcr.io/offendingcommit/mcp-remote:latest https://server/sse --transport sse-only

# Allow HTTP (for trusted networks)
docker run -it ghcr.io/offendingcommit/mcp-remote:latest http://internal-server/sse --allow-http
```

## Troubleshooting

### Clear Authentication Cache
```bash
# Remove the volume
docker volume rm mcp-auth

# Or clear specific server data
docker run --rm -v mcp-auth:/home/mcp/.mcp-auth alpine rm -rf /home/mcp/.mcp-auth/*
```

### View Debug Logs
```bash
# Enable debug mode
docker run -it -v mcp-auth:/home/mcp/.mcp-auth ghcr.io/offendingcommit/mcp-remote:latest https://server/sse --debug

# View logs
docker run --rm -v mcp-auth:/home/mcp/.mcp-auth alpine find /home/mcp/.mcp-auth -name "*_debug.log" -exec cat {} \;
```

### VPN/Proxy Issues
```bash
# Mount CA certificates
docker run -it \
  -v /path/to/ca-cert.pem:/certs/ca.pem:ro \
  -e NODE_EXTRA_CA_CERTS=/certs/ca.pem \
  ghcr.io/offendingcommit/mcp-remote:latest \
  https://server/sse
```

## Building and Contributing

This repository focuses on Docker packaging for mcp-remote. For core functionality changes, please contribute to the [upstream repository](https://github.com/geelen/mcp-remote).

### Build Requirements
- Docker
- Docker Buildx (for multi-platform builds)

### Build Commands
```bash
# Build for current platform
docker build -t mcp-remote:local .

# Build for multiple platforms
docker buildx build --platform linux/amd64,linux/arm64 -t mcp-remote:local .
```

## License

MIT - See [LICENSE](LICENSE) file

## Credits

- Original mcp-remote by [@geelen](https://github.com/geelen)
- Docker distribution maintained by [@offendingcommit](https://github.com/offendingcommit)