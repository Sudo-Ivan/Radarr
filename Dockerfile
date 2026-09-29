# syntax=docker/dockerfile:1

FROM node:20.11.1-bookworm-slim@sha256:357deca6eb61149534d32faaf5e4b2e4fa3549c2be610ee1019bf340ea8c51ec AS ui
WORKDIR /build
COPY package.json yarn.lock ./
RUN corepack enable && corepack yarn install --frozen-lockfile
COPY . .
RUN corepack yarn build --env production

FROM mcr.microsoft.com/dotnet/sdk:8.0.421@sha256:fc69dc5e0c9789adaac5c8efce71ead4d016a51318667c4f26ce93574b1b9403 AS backend
ARG TARGETARCH
WORKDIR /build
COPY . .
RUN rid="linux-$( [ "${TARGETARCH}" = "amd64" ] && echo x64 || echo "${TARGETARCH}" )" && \
    dotnet publish src/NzbDrone.Console/Radarr.Console.csproj \
    -c Release \
    -f net8.0 \
    -r "${rid}" \
    --self-contained \
    -p:SolutionDir=/build/src/ \
    -o /app/bin && \
    dotnet publish src/NzbDrone.Mono/Radarr.Mono.csproj \
    -c Release \
    -f net8.0 \
    -r "${rid}" \
    --self-contained \
    -p:SolutionDir=/build/src/ \
    -o /app/bin && \
    mkdir -p /config && chown 1000:1000 /config

FROM mcr.microsoft.com/dotnet/runtime-deps:8.0-jammy-chiseled-extra@sha256:c5e7baf418ea7ffc4afb717f92cd355decd6ee78181a148176f03fc94d792e3d AS runtime
ARG VERSION="local"
ARG REVISION=""
LABEL org.opencontainers.image.title="Radarr" \
      org.opencontainers.image.description="Movie collection manager for Usenet and BitTorrent users. Telemetry stripped fork." \
      org.opencontainers.image.url="https://github.com/Sudo-Ivan/Radarr" \
      org.opencontainers.image.source="https://github.com/Sudo-Ivan/Radarr" \
      org.opencontainers.image.documentation="https://github.com/Sudo-Ivan/Radarr" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.revision="${REVISION}" \
      org.opencontainers.image.vendor="Sudo-Ivan" \
      org.opencontainers.image.licenses="GPL-3.0" \
      org.opencontainers.image.base.name="mcr.microsoft.com/dotnet/runtime-deps:8.0-jammy-chiseled-extra"

ENV XDG_CONFIG_HOME=/config/.config \
    RADARR__BRANCH__NAME=remove-telemetry \
    RADARR__AUTH__REQUIRED=DisabledForLocalAddresses \
    COMPlus_EnableDiagnostics=0

WORKDIR /app/radarr/bin
COPY --from=backend /app/bin/ /app/radarr/bin/
COPY --from=backend --chown=1000:1000 /config /config
COPY --from=ui /build/_output/UI/ /app/radarr/bin/UI/

USER 1000
VOLUME /config
EXPOSE 7878

ENTRYPOINT ["/app/radarr/bin/Radarr", "-nobrowser", "-data=/config"]
