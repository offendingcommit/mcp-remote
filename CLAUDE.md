# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Build & Development

```bash
pnpm build          # Compile TypeScript to JavaScript (tsup)
pnpm build:watch    # Watch mode for development
pnpm check          # Run prettier check + TypeScript type checking
pnpm lint-fix       # Auto-fix formatting with prettier
```

### Running the Proxy

```bash
# After building, run the proxy
node dist/proxy.js <remote-server-url> [port] [options]

# Test client mode
node dist/client.js <remote-server-url> [options]
```

### Docker

```bash
# Build Docker image
docker build -t mcp-remote:latest .

# Run with Docker
docker run -it mcp-remote:latest https://remote.mcp.server/sse

# Run with docker-compose
docker-compose run mcp-remote https://remote.mcp.server/sse

# Run with persistent token storage
docker run -it -v mcp-auth:/home/mcp/.mcp-auth mcp-remote:latest https://remote.mcp.server/sse
```

## Architecture Overview

This project acts as a bidirectional proxy between:

- **Local stdio transport** (used by Claude Desktop, Cursor, Windsurf)
- **Remote HTTP/SSE transport** with OAuth 2.0 authentication

### Key Components

1. **proxy.ts**: Main entry point that handles stdio ↔ remote communication

   - Reads from stdin, writes to stdout
   - Implements transport strategy pattern (http-first, sse-first, http-only, sse-only)
   - Manages OAuth authentication flow when needed

2. **client.ts**: Standalone test client for debugging remote connections

   - Useful for testing OAuth flows outside of MCP clients
   - Run with `npx -p mcp-remote@latest mcp-remote-client <url>`

3. **lib/coordination.ts**: OAuth flow orchestration

   - Spins up temporary Express server for OAuth callbacks
   - Handles authorization code exchange
   - Manages browser opening for auth

4. **lib/mcp-auth-config.ts**: Token persistence and management

   - Stores OAuth tokens in `~/.mcp-auth/`
   - Automatic token refresh
   - Debug logging to `~/.mcp-auth/{server_hash}_debug.log` when --debug flag is used

5. **lib/utils.ts**: Core transport and connection logic
   - Implements reconnection with exponential backoff
   - Handles both HTTP and SSE transports
   - Message proxying between transports

### OAuth Flow

1. If server requires auth, proxy intercepts auth error
2. Spins up local Express server on configurable port (default: 3334)
3. Opens browser for user authorization
4. Receives callback with authorization code
5. Exchanges code for tokens
6. Stores tokens locally for reuse
7. Automatically refreshes tokens when expired

### Transport Strategies

- Default behavior: Try HTTP first, fall back to SSE
- Configurable via `--transport` flag
- Handles connection failures and retries gracefully

## Important Notes

- No test suite exists - testing is manual via the client command
- Uses pnpm package manager (v10.11.0)
- TypeScript strict mode enabled
- ES modules output only
- Prettier formatting with 140 char lines, single quotes, no semicolons
- OAuth tokens stored in `~/.mcp-auth/` (or `$MCP_REMOTE_CONFIG_DIR`)
- Debug logs available with `--debug` flag for troubleshooting auth issues
