# NPM Package Documentation

This file contains the original npm-focused documentation for mcp-remote. For the current npm package, please visit the [upstream repository](https://github.com/geelen/mcp-remote).

## NPM Usage

All the most popular MCP clients (Claude Desktop, Cursor & Windsurf) use the following config format:

```json
{
  "mcpServers": {
    "remote-example": {
      "command": "npx",
      "args": ["mcp-remote", "https://remote.mcp.server/sse"]
    }
  }
}
```

### Custom Headers

To bypass authentication, or to emit custom headers on all requests to your remote server, pass `--header` CLI arguments:

```json
{
  "mcpServers": {
    "remote-example": {
      "command": "npx",
      "args": ["mcp-remote", "https://remote.mcp.server/sse", "--header", "Authorization: Bearer ${AUTH_TOKEN}"],
      "env": {
        "AUTH_TOKEN": "..."
      }
    }
  }
}
```

**Note:** Cursor and Claude Desktop (Windows) have a bug where spaces inside `args` aren't escaped when it invokes `npx`, which ends up mangling these values. You can work around it using:

```jsonc
{
  // rest of config...
  "args": [
    "mcp-remote",
    "https://remote.mcp.server/sse",
    "--header",
    "Authorization:${AUTH_HEADER}" // note no spaces around ':'
  ],
  "env": {
    "AUTH_HEADER": "Bearer <auth-token>" // spaces OK in env vars
  }
},
```

### NPM Flags

- If `npx` is producing errors, consider adding `-y` as the first argument to auto-accept the installation of the `mcp-remote` package.

```json
      "command": "npx",
      "args": [
        "-y"
        "mcp-remote",
        "https://remote.mcp.server/sse"
      ]
```

- To force `npx` to always check for an updated version of `mcp-remote`, add the `@latest` flag:

```json
      "args": [
        "mcp-remote@latest",
        "https://remote.mcp.server/sse"
      ]
```

### All Command Line Options

- Port configuration: Add port number after server URL (default: 3334)
- Host configuration: `--host` flag (default: localhost)
- Allow HTTP: `--allow-http` flag
- Debug mode: `--debug` flag
- Transport strategy: `--transport` flag (http-first, sse-first, http-only, sse-only)
- Static OAuth metadata: `--static-oauth-client-metadata` flag
- Static OAuth client info: `--static-oauth-client-info` flag

### Client Mode

Run the following on the command line (not from an MCP server):

```shell
npx -p mcp-remote@latest mcp-remote-client https://remote.mcp.server/sse
```

This will run through the entire authorization flow and attempt to list the tools & resources at the remote URL.
