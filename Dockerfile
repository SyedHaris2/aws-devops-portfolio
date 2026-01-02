# --- Stage 1: Builder ---
FROM node:20-alpine AS builder

WORKDIR /app

# Copy only package files first (better caching)
COPY package*.json ./
RUN npm install

# Now copy only required project files
COPY app.js ./
COPY views ./views


# --- Stage 2: Production ---
FROM node:20-alpine

WORKDIR /app

# Copy node_modules from builder
COPY --from=builder /app/node_modules ./node_modules

# Copy actual app files
COPY --from=builder /app/app.js ./
COPY --from=builder /app/views ./views

# Run as non-root
USER node

EXPOSE 8000

CMD ["node", "app.js"]
