# base node image
FROM node:18-bullseye-slim AS base

# Install openssl for Prisma
RUN apt-get update && apt-get install -y openssl

ENV NODE_ENV=production

# Install all node_modules, including dev dependencies
FROM base AS deps

RUN mkdir /app
WORKDIR /app

ADD package.json package-lock.json ./
RUN npm install --production=false

# Setup production node_modules
FROM base AS production-deps

RUN mkdir /app
WORKDIR /app

COPY --from=deps /app/node_modules /app/node_modules
ADD package.json package-lock.json ./
RUN npm prune --production

# Build the app
FROM base AS build

RUN mkdir /app
WORKDIR /app

COPY --from=deps /app/node_modules /app/node_modules

ADD prisma .
RUN npx prisma generate

ADD . .
RUN npm run build

# Finally, build the production image with minimal footprint
FROM base

ENV NODE_ENV=production

RUN mkdir /app
WORKDIR /app

COPY --from=production-deps /app/node_modules /app/node_modules
COPY --from=build /app/node_modules/.prisma /app/node_modules/.prisma
COPY --from=build /app/build /app/build
COPY --from=build /app/public /app/public
COPY --from=build /app/package.json /app/package.json
COPY --from=build /app/start.sh /app/start.sh
COPY --from=build /app/prisma /app/prisma

# Make start.sh executable
RUN chmod +x start.sh

ENTRYPOINT [ "./start.sh" ]
