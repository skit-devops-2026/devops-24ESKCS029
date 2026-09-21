# syntax=docker/dockerfile:1

# Stage 1: Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm install --legacy-peer-deps

# Copy application source code
COPY . .

# Set build target environment for standalone Node server
ENV NITRO_PRESET=node-server
ENV NODE_ENV=production

# Compile production build
RUN npm run build

# Stage 2: Production runner stage
FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000
ENV HOST=0.0.0.0

# Copy package manifests for scripts and metadata
COPY package*.json ./

# Copy built application output from builder
COPY --from=builder /app/.output ./.output

# Expose HTTP port
EXPOSE 3000

# Run as non-root user
USER node

# Container healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/ || exit 1

# Launch the production server
CMD ["npm", "start"]
