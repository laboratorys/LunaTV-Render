FROM docker.io/iicm/lunatv:dev AS app-donor
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

RUN curl -L "https://github.com/laboratorys/backup2gh/releases/latest/download/backup2gh-linux-amd64.tar.gz" -o backup2gh.tar.gz \
    && tar -xzf backup2gh.tar.gz \
    && rm backup2gh.tar.gz \
    && chmod +x /app/backup2gh \
    && chown nextjs:nodejs /app/backup2gh \
    && apk del curl

COPY --chown=nextjs:nodejs entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

USER nextjs

EXPOSE 3000

ENTRYPOINT ["/app/entrypoint.sh"]