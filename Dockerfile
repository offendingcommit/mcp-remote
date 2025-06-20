# Build stage
FROM node:22-alpine AS builder

# Install pnpm globally with specific version from package.json
RUN corepack enable && corepack prepare pnpm@10.11.0 --activate

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json pnpm-lock.yaml ./

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy source code
COPY tsconfig.json ./
COPY src ./src

# Build the project
RUN pnpm build

# Runtime stage
FROM node:22-alpine

# Install pnpm for runtime (needed for running the tool)
RUN corepack enable && corepack prepare pnpm@10.11.0 --activate

# Create non-root user
RUN addgroup -g 1001 -S mcp && \
    adduser -S mcp -u 1001

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json pnpm-lock.yaml ./

# Install production dependencies only
RUN pnpm install --prod --frozen-lockfile && \
    pnpm store prune

# Copy built files from builder
COPY --from=builder /app/dist ./dist

# Copy other necessary files
COPY README.md LICENSE ./

# Create directory for auth tokens (will be mounted as volume)
RUN mkdir -p /home/mcp/.mcp-auth && \
    chown -R mcp:mcp /home/mcp/.mcp-auth

# Switch to non-root user
USER mcp

# Set environment variable for config directory
ENV MCP_REMOTE_CONFIG_DIR=/home/mcp/.mcp-auth

# Default to proxy command
ENTRYPOINT ["node", "dist/proxy.js"]

# Default arguments (can be overridden)
CMD []