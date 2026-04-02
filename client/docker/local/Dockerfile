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

COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./

RUN \
  if [ -f yarn.lock ]; then yarn --frozen-lockfile; \
  elif [ -f package-lock.json ]; then npm ci; \
  elif [ -f pnpm-lock.yaml ]; then corepack enable pnpm && pnpm i; \
  else echo "Lockfile not found." && exit 1; \
  fi


# -------------------------------
# Stage 2: Build app
# -------------------------------
FROM base AS builder

WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

RUN npm run build


# -------------------------------
# Stage 3: Production runtime
# -------------------------------
FROM base AS runner

WORKDIR /app

ENV NODE_ENV=production

# Create user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001 -G nodejs

# Copy built app
COPY --from=builder /app ./

# Fix permissions
RUN chown -R nextjs:nodejs /app

USER nextjs

EXPOSE 3000

# ✅ Production start (IMPORTANT)
CMD ["npm", "start"]