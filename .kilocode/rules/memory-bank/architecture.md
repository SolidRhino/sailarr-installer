**System Architecture:**

The Sailarr Installer deploys a multi-container Docker stack orchestrated via Docker Compose. The architecture is designed for a seamless, automated media server experience, streaming content from Real-Debrid.

**Core Components & Data Flow:**

1.  **Request & Management:**
    *   **Overseerr**: The entry point for media requests. It communicates with Radarr and Sonarr.
    *   **Radarr & Sonarr**: Manage movie and TV show libraries, respectively. They receive requests from Overseerr and use Prowlarr to search for content.
    *   **Prowlarr**: Manages and queries indexers (like Zilean and Torrentio) on behalf of Radarr and Sonarr.

2.  **Content Acquisition & Streaming:**
    *   **Zilean & Zilean-Postgres**: Zilean acts as a custom indexer that scrapes Debrid Media Manager, providing a cached list of available torrents. It uses PostgreSQL as its database.
    *   **Decypharr**: A lightweight download client that takes torrent files found by the *Arrs, adds them to Real-Debrid, and creates symlinks to the mounted Real-Debrid files.
    *   **Zurg**: Exposes the user's Real-Debrid cloud storage as a WebDAV server.
    *   **Rclone**: Mounts the Zurg WebDAV server as a local filesystem folder (`/data/realdebrid-zurg`), making cloud files appear as local files to the rest of the stack.

3.  **Media Serving & Monitoring:**
    *   **Plex**: The primary media server that scans the local media folders (which contain symlinks to the Rclone mount) and streams content to clients.
    *   **Autoscan**: Monitors for changes in the media folders and triggers immediate library scans in Plex.
    *   **Tautulli**: Monitors Plex for viewing statistics.
    *   **Homarr & Dashdot**: Provide user-facing dashboards for service management and system monitoring.
    *   **Watchtower**: Automatically updates all running containers to their latest versions.
    *   **Traefik**: (Optional) Acts as a reverse proxy, providing HTTPS access and clean URLs for all services.

**Key Implementation Paths:**

*   **Configuration:** All service configurations are stored in `${ROOT_DIR}/config/`.
*   **Media Data:** Media files are accessed through a unified `${ROOT_DIR}/data/` volume, which is mounted into Plex, Radarr, Sonarr, and Decypharr. The actual media files reside on Real-Debrid and are accessed via the Rclone mount.
*   **Networking:** Services communicate over a custom Docker network (`mediacenter`), with each service assigned a static IP address for stable internal communication. Traefik handles external routing if enabled.

This architecture is designed to be highly automated, with minimal user intervention required after the initial setup.