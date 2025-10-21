# Sailarr Installer

Fully automated installation script for creating your own media server powered by Real-Debrid and the *Arr stack. One command setup with comprehensive configuration options.

## What is This?

This installer deploys a complete media automation stack that streams content from Real-Debrid through Plex, using the *Arr applications (Radarr, Sonarr, Prowlarr) to manage your library. The installer handles everything automatically based on your preferences.

**Key Features:**
- **Fully Interactive Setup** - Configure exactly what you need
- **Zero Manual Configuration** - All services automatically configured and connected
- **TRaSH Guide Quality Profiles** - Industry-standard quality settings via Recyclarr
- **Health Monitoring** - Automatic container restarts if issues are detected
- **Decypharr Integration** - Lightweight Real-Debrid download client with symlink support
- **Optional Traefik Integration** - Reverse proxy with HTTPS support
- **Authentication** - Optional password protection for all services

## Requirements

- **Server:** Ubuntu 20.04+ or Debian 11+ (8GB RAM minimum, 16GB recommended)
- **Real-Debrid:** Active subscription with [API token](https://real-debrid.com/apitoken)
- **Docker & Docker Compose:** Must be installed before running the installer
- **Storage:** 20GB+ available disk space (minimal, 50GB+ recommended)
- **Domain (optional):** Required only if using Traefik with HTTPS

## Quick Start

```bash
# Clone the repository
git clone https://github.com/JaviPege/sailarr-installer.git
cd sailarr-installer

# Run the installer
./setup.sh
```

The installer is fully interactive and will guide you through all configuration options.

**📖 For detailed installation instructions, see [INSTALLATION.md](INSTALLATION.md)** - This guide explains each configuration option, what happens during installation, and how to troubleshoot common issues.

## What Gets Installed

The stack includes these services, configured based on your selections:

### Core Services (Always Installed)

- **[Plex](https://www.plex.tv/)** - Media streaming server
- **[Radarr](https://radarr.video/)** - Movie management and automation
- **[Sonarr](https://sonarr.tv/)** - TV series management and automation
- **[Prowlarr](https://prowlarr.com/)** - Indexer management for all *Arrs
- **[Zurg](https://github.com/debridmediamanager/zurg-testing)** - Real-Debrid WebDAV server
- **[Rclone](https://github.com/rclone/rclone)** - Mounts Zurg as local filesystem
- **[Zilean](https://github.com/iPromKnight/zilean)** - Debrid Media Manager indexer
- **[PostgreSQL](https://www.postgresql.org/)** - Database for Zilean
- **[Overseerr](https://overseerr.dev/)** - Media request management
- **[Autoscan](https://github.com/saltydk/autoscan)** - Automatic Plex library updates

### Download Client

- **[Decypharr](https://github.com/enty8080/Decypharr)** - Lightweight and fast, handles Real-Debrid integration

**Note:** RDTClient is available in the compose files as legacy support but is not configured by the installer.

### Optional Services

- **[Traefik](https://traefik.io/)** - Reverse proxy with automatic HTTPS (optional)
- **[Traefik Socket Proxy](https://github.com/Tecnativa/docker-socket-proxy)** - Security layer for Traefik
- **[Watchtower](https://containrrr.dev/watchtower/)** - Automatic container updates (optional)
- **[Tautulli](https://tautulli.com/)** - Plex monitoring and statistics (optional)
- **[Homarr](https://homarr.dev/)** - Dashboard for all services (optional)
- **[Dashdot](https://github.com/MauriceNino/dashdot)** - Server monitoring dashboard (optional)
- **[Pinchflat](https://github.com/kieraneglin/pinchflat)** - YouTube downloader for Plex (optional)
- **[Plex-Trakt-Sync](https://github.com/Taxel/PlexTraktSync)** - Sync Plex with Trakt.tv (optional)

## Installation Options

During installation, you'll configure:

### 1. Basic Configuration
- **Installation Directory** - Where to install (default: `/mediacenter`)
- **Timezone** - Server timezone (default: `Europe/Madrid`)
- **Real-Debrid API Token** - Your Real-Debrid authentication
- **Plex Claim Token** - Link Plex to your account (optional)

Download client is automatically set to Decypharr.

### 2. Authentication
- **Enable/Disable** - Password protect all services
- **Username & Password** - If authentication enabled

### 3. Traefik (Reverse Proxy)
- **Enable/Disable** - Use Traefik for routing
- **Domain/Hostname** - Your domain name if enabled

### 4. Automatic Configuration
- **Auto-configure services** - Let installer set up all connections
- **Install health monitoring** - Auto-restart containers on mount failures
- **Add cron jobs** - Scheduled health checks

## Accessing Services

After installation, access your services at different URLs depending on your configuration:

### Without Traefik (Direct Access)

- **Plex:** `http://SERVER_IP:32400/web`
- **Radarr:** `http://SERVER_IP:7878`
- **Sonarr:** `http://SERVER_IP:8989`
- **Prowlarr:** `http://SERVER_IP:9696`
- **Overseerr:** `http://SERVER_IP:5055`
- **Zilean:** `http://SERVER_IP:8181`
- **Decypharr:** `http://SERVER_IP:8283`
- **Tautulli:** `http://SERVER_IP:8181` (if installed)
- **Homarr:** `http://SERVER_IP:7575` (if installed)
- **Dashdot:** `http://SERVER_IP:3001` (if installed)
- **Pinchflat:** `http://SERVER_IP:8945` (if installed)

Replace `SERVER_IP` with your actual server IP address or hostname.

### With Traefik Enabled

Services are accessible via subdomains of your configured domain:

- **Plex:** `https://plex.YOUR_DOMAIN`
- **Radarr:** `https://radarr.YOUR_DOMAIN`
- **Sonarr:** `https://sonarr.YOUR_DOMAIN`
- **Prowlarr:** `https://prowlarr.YOUR_DOMAIN`
- **Overseerr:** `https://overseerr.YOUR_DOMAIN`
- **Zilean:** `https://zilean.YOUR_DOMAIN`
- **Decypharr:** `https://decypharr.YOUR_DOMAIN`
- **Tautulli:** `https://tautulli.YOUR_DOMAIN` (if installed)
- **Homarr:** `https://homarr.YOUR_DOMAIN` (if installed)
- **Dashdot:** `https://dashdot.YOUR_DOMAIN` (if installed)
- **Pinchflat:** `https://pinchflat.YOUR_DOMAIN` (if installed)
- **Traefik Dashboard:** `https://traefik.YOUR_DOMAIN`

Replace `YOUR_DOMAIN` with your configured domain name.

**Note:** If authentication is enabled, you'll be prompted for username/password when accessing any service.

## How It Works

The workflow is completely automated:

1. **Request** content through Overseerr
2. **Search** - Radarr/Sonarr search indexers via Prowlarr
3. **Find** - Zilean provides cached torrents from Debrid Media Manager
4. **Add** - Decypharr adds torrent to Real-Debrid
5. **Mount** - Zurg exposes Real-Debrid library via WebDAV
6. **Access** - Rclone mounts Zurg as local filesystem
7. **Link** - Decypharr creates symlinks to mounted files
8. **Import** - Radarr/Sonarr import the symlinks
9. **Scan** - Autoscan triggers Plex library refresh
10. **Stream** - Watch instantly through Plex

No actual downloading to local storage - everything streams from Real-Debrid.

## What the Installer Does

### 1. Configuration Collection
- Asks all necessary questions
- Validates input
- Creates `.env.install` with your settings
- Shows configuration summary for confirmation

### 2. System Preparation
- Creates installation directory
- Sets up user and group permissions
- Creates required subdirectories
- Generates all configuration files

### 3. Service Deployment
- Generates Docker Compose configuration
- Pulls required Docker images
- Starts containers in correct order
- Waits for services to become healthy

### 4. Automatic Configuration
If enabled, the installer:
- Extracts API keys from services
- Configures Prowlarr with Zilean indexer
- Connects Radarr/Sonarr to Prowlarr
- Sets up Decypharr as download client in Radarr/Sonarr
- Configures Real-Debrid settings in Decypharr
- Sets root folders for media
- Removes default quality profiles
- Creates TRaSH Guide quality profiles via Recyclarr

### 5. Health Monitoring
If enabled:
- Installs health check scripts
- Creates cron jobs for automatic monitoring
- Sets up logging

## Quality Profiles

Three TRaSH Guide profiles are automatically created:

- **Recyclarr-1080p** - HD content, upgrades to Remux-1080p
- **Recyclarr-2160p** - 4K content, upgrades to Remux-2160p
- **Recyclarr-Any** - Any quality, upgrades to best available

To manually update profiles after installation:

```bash
cd /YOUR_INSTALL_DIR
./recyclarr-sync.sh
```

## Directory Structure

```
/YOUR_INSTALL_DIR/
├── config/              # Application configurations
│   ├── plex-config/
│   ├── radarr-config/
│   ├── sonarr-config/
│   ├── prowlarr-config/
│   ├── overseerr-config/
│   ├── zilean-config/
│   ├── zurg-config/
│   ├── autoscan-config/
│   ├── decypharr-config/  (if selected)
│   ├── rdtclient-config/  (if selected)
│   ├── traefik-config/    (if enabled)
│   ├── tautulli-config/   (if installed)
│   ├── homarr-config/     (if installed)
│   └── ...
├── data/               # Media and downloads
│   ├── media/
│   │   ├── movies/    # Radarr movies
│   │   └── tv/        # Sonarr TV shows
│   ├── torrents/      # Download client symlinks
│   └── realdebrid-zurg/ # Rclone mount point
├── logs/              # Health check logs (if enabled)
├── docker/            # Docker Compose files
├── setup.sh           # Installation script
├── recyclarr.yml      # TRaSH Guide configuration
├── recyclarr-sync.sh  # Manual profile update script
├── arrs-mount-healthcheck.sh    (if installed)
└── plex-mount-healthcheck.sh    (if installed)
```

## Troubleshooting

### Check Service Status
```bash
docker ps -a
```

### View Container Logs
```bash
docker logs <container_name>

# Examples:
docker logs plex
docker logs radarr
docker logs zurg
```

### Restart All Services
```bash
cd /YOUR_INSTALL_DIR/docker
docker compose restart
```

### Check Mount Health
```bash
tail -f /YOUR_INSTALL_DIR/logs/plex-mount-healthcheck.log
tail -f /YOUR_INSTALL_DIR/logs/arrs-mount-healthcheck.log
```

### Common Issues

**Containers won't start:** Check Docker logs and verify Real-Debrid API token is valid

**No search results:** Wait for Zilean to populate its database (1-2 hours initially)

**Files not appearing:** Check mount health logs and verify rclone container is healthy

**Permission errors:** Verify directory ownership matches configured UIDs/GIDs

**Traefik 404 errors:** Ensure DNS is pointing to your server and containers are healthy

## Maintenance

### Update Containers

```bash
cd /YOUR_INSTALL_DIR/docker
docker compose pull
docker compose up -d
```

Or enable Watchtower during installation for automatic updates.

### View Logs

```bash
# All containers
cd /YOUR_INSTALL_DIR/docker
docker compose logs -f

# Specific container
docker logs -f <container_name>
```

### Backup Configuration

```bash
# Backup entire config directory
tar -czf mediacenter-backup-$(date +%Y%m%d).tar.gz /YOUR_INSTALL_DIR/config/
```

## Re-running the Installer

If you need to change configuration or reinstall:

```bash
# The installer will detect existing .env.install and ask if you want to reuse it
./setup.sh

# To start fresh, delete the existing configuration:
rm .env.install
./setup.sh
```

## Development

This installer was developed step-by-step with guidance and direction, using [Claude Code](https://claude.com/claude-code) as the development assistant.

## Credits & Acknowledgments

This project builds upon the excellent work of many in the community:

- **[Naralux/mediacenter](https://github.com/Naralux/mediacenter)** - Inspiration and foundation for this automated installer
- **[TRaSH Guides](https://trash-guides.info/)** - Quality profiles, custom formats, and best practices
- **[Savvy Guides / Sailarr's Guide](https://savvyguides.wiki/sailarrsguide/)** - Comprehensive *Arr stack documentation
- **[Servarr Wiki](https://wiki.servarr.com/)** - Official documentation and [Docker Guide](https://wiki.servarr.com/docker-guide)
- **[Recyclarr](https://recyclarr.dev/)** - Automated TRaSH Guide syncing
- **[ElfHosted](https://elfhosted.com/guides/media/stream-from-real-debrid-with-plex-radarr-sonarr-prowlarr/)** - Real-Debrid streaming architecture
- **[Ezarr](https://github.com/Luctia/ezarr)** - Docker *Arr stack approach
- **[Debrid Media Manager](https://github.com/debridmediamanager/debrid-media-manager)** - Torrent caching platform
- **[dreulavelle/Prowlarr-Indexers](https://github.com/dreulavelle/Prowlarr-Indexers)** - Custom Prowlarr indexer definitions

And all the developers of the tools in this stack: Plex, Radarr, Sonarr, Prowlarr, Overseerr, Zurg, Rclone, Zilean, Decypharr, RDTClient, Autoscan, Traefik, Watchtower, Tautulli, Homarr, Dashdot, Pinchflat, and Plex-Trakt-Sync.

## License

MIT License - Use and modify as needed.

## Disclaimer

This tool is for educational purposes. Ensure you comply with your local laws and Real-Debrid's terms of service.
