# -------------------------------
# Base Image
# -------------------------------
FROM docker.io/node:20.11-alpine3.18 AS base


# -------------------------------
# Stage 1: Install dependencies
# -------------------------------
FROM base AS deps

WORKDIR /app

RUN apk add --no-cache libc6-compat

# Copy dependency files
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./

# Install dependencies
RUN \
  if [ -f yarn.lock ]; then yarn --frozen-lockfile; \
  elif [ -f package-lock.json ]; then npm ci; \
  elif [ -f pnpm-lock.yaml ]; then corepack enable pnpm && pnpm install --frozen-lockfile; \
  else echo "Lockfile not found." && exit 1; \
  fi


# -------------------------------
# Stage 2: Build Next.js app
# -------------------------------
FROM base AS builder

WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Ensure production build
ENV NODE_ENV=production

# Build Next.js app (creates .next/BUILD_ID)
RUN npm run build


# -------------------------------
# Stage 3: Production runtime
# -------------------------------
FROM base AS runner

WORKDIR /app

ENV NODE_ENV=production

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001 -G nodejs

# Copy only required files (IMPORTANT FIX)
COPY --from=builder /app/package.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/next.config.js ./next.config.js

# (Optional but safe)
# COPY --from=builder /app/.env.production ./.env.production

# Fix permissions
RUN chown -R nextjs:nodejs /app

# Switch user
USER nextjs

# Expose port
EXPOSE 3000

# Start app
CMD ["npm", "start"]