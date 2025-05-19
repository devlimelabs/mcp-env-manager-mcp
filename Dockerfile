FROM node:20-alpine AS builder

# Install pnpm
RUN npm install -g pnpm

WORKDIR /app

# Copy package files and install dependencies
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# Copy source code
COPY . .

# Build the application
RUN pnpm build

# Production stage
FROM node:20-alpine

# Install pnpm
RUN npm install -g pnpm

WORKDIR /app

# Copy package files and install production dependencies only
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile --prod

# Copy built application from builder stage
COPY --from=builder /app/dist ./dist

# Copy .env.example file
COPY .env.example .env.example

# Set environment variables
ENV NODE_ENV=production

# Create directory for storing configuration
RUN mkdir -p /data

# Set volume for persistent data
VOLUME /data

# Set environment variable to use the data directory
ENV MCP_ENV_STORAGE_DIR=/data

# Start the application
CMD ["node", "dist/bin/mcp-env-manager.js"] 
