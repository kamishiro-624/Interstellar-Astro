FROM node:bookworm-slim AS builder
ENV NODE_ENV=production

WORKDIR /app

RUN npm install -g pnpm

COPY ["package.json", "pnpm-lock.yaml*", "./"]

RUN pnpm config set dangerouslyAllowAllBuilds true && pnpm install

COPY . .

RUN pnpm exec astro build

FROM node:bookworm-slim AS runner
ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=8080
ENV FIRST=false

WORKDIR /app

RUN npm install -g pnpm

COPY ["package.json", "pnpm-lock.yaml*", "./"]
RUN pnpm config set dangerouslyAllowAllBuilds true && pnpm install --prod=false

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/index.ts ./index.ts
COPY --from=builder /app/config.ts ./config.ts
COPY --from=builder /app/src ./src
COPY --from=builder /app/astro.config.ts ./astro.config.ts
COPY --from=builder /app/tsconfig.json ./tsconfig.json

EXPOSE 8080

CMD ["node", "--import", "tsx", "index.ts"]