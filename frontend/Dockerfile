FROM node:24-slim AS base

WORKDIR /app

ENV PNPM_HOME="/pnpm"
ENV PNPM_STORE_DIR="/pnpm/store"
ENV PATH="$PNPM_HOME:$PATH"

RUN corepack enable \
  && pnpm config set store-dir /pnpm/store

EXPOSE 5173

FROM base AS dev

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./

CMD ["sh", "-c", "pnpm install --frozen-lockfile && pnpm dev --host 0.0.0.0"]


FROM base AS prod

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./

RUN pnpm install --frozen-lockfile

COPY . .

RUN pnpm build

EXPOSE 4173

CMD ["pnpm", "preview", "--host", "0.0.0.0"]