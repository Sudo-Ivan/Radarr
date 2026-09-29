# syntax=docker/dockerfile:1

FROM node:20.11.1-bookworm-slim@sha256:357deca6eb61149534d32faaf5e4b2e4fa3549c2be610ee1019bf340ea8c51ec AS ui
WORKDIR /build
COPY package.json yarn.lock ./
RUN corepack enable && corepack yarn install --frozen-lockfile
COPY . .
RUN corepack yarn build --env production

FROM mcr.microsoft.com/dotnet/sdk:8.0.421@sha256:fc69dc5e0c9789adaac5c8efce71ead4d016a51318667c4f26ce93574b1b9403 AS backend
WORKDIR /build
COPY . .
RUN dotnet publish src/NzbDrone.Console/Radarr.Console.csproj \
    -c Release \
    -f net8.0 \
    -r linux-x64 \
    --self-contained \
    -p:SolutionDir=/build/src/ \
    -o /app/bin && \
    dotnet publish src/NzbDrone.Mono/Radarr.Mono.csproj \
    -c Release \
    -f net8.0 \
    -r linux-x64 \
    --self-contained \
    -p:SolutionDir=/build/src/ \
    -o /app/bin

FROM mcr.microsoft.com/dotnet/runtime-deps:8.0-jammy@sha256:e7a499d02948b4868120f9ff554db2d524063730b64476d294ac4ad63fb07973 AS runtime
LABEL org.opencontainers.image.source="https://github.com/Sudo-Ivan/Radarr" \
      org.opencontainers.image.licenses=GPL-3.0

ENV XDG_CONFIG_HOME=/config/.config \
    RADARR__BRANCH__NAME=remove-telemetry \
    RADARR__AUTH__REQUIRED=DisabledForLocalAddresses \
    COMPlus_EnableDiagnostics=0

RUN mkdir -p /config && chown app:app /config

WORKDIR /app/radarr/bin
COPY --from=backend /app/bin/ /app/radarr/bin/
COPY --from=ui /build/_output/UI/ /app/radarr/bin/UI/

USER app
VOLUME /config
EXPOSE 7878

ENTRYPOINT ["/app/radarr/bin/Radarr", "-nobrowser", "-data=/config"]
