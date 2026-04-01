FROM docker.io/iicm/lunatv:dev AS app-donor
FROM golang:1.25-alpine AS builder-bak

RUN apk add --no-cache git gcc musl-dev sqlite-dev
WORKDIR /build
RUN git clone https://github.com/laboratorys/backup2gh.git .
RUN CGO_ENABLED=1 GOOS=linux go build -o backup2gh .

FROM node:20-alpine AS runner
RUN apk add --no-cache git libc6-compat sqlite curl

RUN addgroup -g 1001 -S nodejs && adduser -u 1001 -S nextjs -G nodejs

WORKDIR /app
ENV NODE_ENV=production
ENV HOSTNAME=0.0.0.0
ENV PORT=3000
ENV DOCKER_ENV=true
ENV SQLITE_PATH=/app/data/tv.db

RUN mkdir -p /app/data && chown -R nextjs:nodejs /app/data

COPY --from=app-donor --chown=nextjs:nodejs /app/ ./

COPY --from=builder-bak --chown=10014:10014 /build/backup2gh /app/backup2gh

RUN chmod +x /app/entrypoint.sh /app/backup2gh

COPY --chown=nextjs:nodejs entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

USER nextjs

EXPOSE 3000

ENTRYPOINT ["/app/entrypoint.sh"]