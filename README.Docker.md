# Docker Usage for mcp-remote

This document describes how to build and run mcp-remote using Docker.

## Building the Image

```bash
# Build the Docker image
docker build -t mcp-remote:latest .

# Or using docker-compose
docker-compose build
```

## Running the Container

### Basic Usage

```bash
# Run with a remote server URL
docker run -it mcp-remote:latest https://remote.mcp.server/sse

# With custom headers
docker run -it \
  -e AUTH_TOKEN="your-token-here" \
  mcp-remote:latest \
  https://remote.mcp.server/sse \
  --header "Authorization: Bearer ${AUTH_TOKEN}"

# With debug logging
docker run -it \
  -v mcp-auth:/home/mcp/.mcp-auth \
  mcp-remote:latest \
  https://remote.mcp.server/sse \
  --debug
```

### Using Docker Compose

```bash
# Run with docker-compose
docker-compose run mcp-remote https://remote.mcp.server/sse

# Run client mode for testing
docker-compose run mcp-remote node dist/client.js https://remote.mcp.server/sse
```

### OAuth Authentication

For OAuth flows, you'll need to handle the callback URL. Options:

1. **Host Network Mode** (Linux only):

```bash
docker run -it --network host mcp-remote:latest https://remote.mcp.server/sse
```

2. **Port Forwarding**:

```bash
docker run -it -p 3334:3334 mcp-remote:latest https://remote.mcp.server/sse
```

3. **Custom Callback Host**:

```bash
docker run -it \
  -p 3334:3334 \
  mcp-remote:latest \
  https://remote.mcp.server/sse \
  --host "localhost"
```

### Persistent Token Storage

To persist OAuth tokens between container runs:

```bash
# Create a named volume
docker volume create mcp-auth

# Run with volume mounted
docker run -it \
  -v mcp-auth:/home/mcp/.mcp-auth \
  mcp-remote:latest \
  https://remote.mcp.server/sse
```

### Integration with MCP Clients

To use the Docker container with Claude Desktop, Cursor, or Windsurf:

```json
{
  "mcpServers": {
    "remote-example": {
      "command": "docker",
      "args": ["run", "-i", "--rm", "-v", "mcp-auth:/home/mcp/.mcp-auth", "mcp-remote:latest", "https://remote.mcp.server/sse"]
    }
  }
}
```

## Environment Variables

- `MCP_REMOTE_CONFIG_DIR`: Directory for storing auth tokens (default: `/home/mcp/.mcp-auth`)
- `NODE_EXTRA_CA_CERTS`: Path to CA certificate file for VPN/proxy environments

## Troubleshooting

### OAuth Callback Issues

If the OAuth callback fails:

1. Ensure the port is properly exposed
2. Check that the callback URL matches what the OAuth provider expects
3. Consider using host network mode on Linux

### Permission Issues

The container runs as a non-root user (uid: 1001). Ensure mounted volumes have appropriate permissions.

### Debug Logs

Enable debug logging with the `--debug` flag. Logs will be stored in the mounted volume at `/home/mcp/.mcp-auth/{server_hash}_debug.log`.
