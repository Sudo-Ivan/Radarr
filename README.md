# Radarr

Radarr is a movie collection manager for Usenet and BitTorrent users. It monitors multiple RSS feeds for new movies and interfaces with clients and indexers to grab, sort, and rename them. It can also be configured to automatically upgrade the quality of existing files in the library when a better quality format becomes available.

This is a hard fork of the upstream Radarr project with telemetry and Sentry removed.

## Fork changes

- Sentry error reporting, analytics and piwik tracking removed, including the Redux middleware that captured application state and the anonymous user hash sent on startup
- Self-contained multi-arch Docker image published to ghcr.io, cosign signed and trivy scanned

## Features

- Support for major platforms: Windows, Linux, macOS, Raspberry Pi, etc.
- Automatic quality upgrades when better releases appear
- Automatic failed download handling
- Manual search
- Full integration with SABnzbd, NZBGet, qBittorrent, Deluge, rTorrent, Transmission, uTorrent and other clients
- Full integration with Kodi and Plex notifications and library updates

## Docker

```sh
docker run -d \
  -p 7878:7878 \
  -v radarr-config:/config \
  -v /media:/media \
  ghcr.io/sudo-ivan/radarr:latest
```

Multi-arch image: linux/amd64 and linux/arm64, zstd compressed, non-root, cosign keyless signed.

## Building

```sh
dotnet build src/NzbDrone.Console/Radarr.Console.csproj
yarn install --frozen-lockfile && yarn build --env production
```
