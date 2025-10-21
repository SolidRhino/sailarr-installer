# Sailarr Installer

Fully automated installation script for creating your own media server powered by Real-Debrid and the *Arr stack. One command setup with zero manual configuration required.

## What is This?

This installer deploys a complete media automation stack that streams content from Real-Debrid through Plex, using the *Arr applications (Radarr, Sonarr, Prowlarr) to manage your library. Everything is configured automatically - just run the script and start watching.

**Key Features:**
- **One Command Installation** - Complete setup in minutes
- **Zero Manual Configuration** - All services automatically configured and connected
- **TRaSH Guide Quality Profiles** - Industry-standard quality settings via Recyclarr
- **Health Monitoring** - Automatic container restarts if issues are detected
- **Flexible Download Clients** - Choose between RDTClient or Decypharr

## Requirements

- **Server:** Ubuntu 20.04+ or Debian 11+ (8GB RAM minimum, 16GB recommended)
- **Real-Debrid:** Active subscription with [API token](https://real-debrid.com/apitoken)
- **Docker:** Will be installed automatically if not present
- **Storage:** 50GB+ available disk space

## Quick Start

```bash
# Clone the repository
git clone https://github.com/JaviPege/sailarr-installer.git
cd sailarr-installer

# Run the installer
sudo ./setup.sh
```

The installer will ask you four questions:
1. Installation directory (default: `/mediacenter`)
2. Real-Debrid API token
3. Plex claim token (optional - for hardware access)
4. Download client preference (RDTClient or Decypharr)

Then it handles everything else automatically.

## What Gets Installed

The stack includes these services, all automatically configured:

- **[Plex](https://www.plex.tv/)** - Media streaming server
- **[Radarr](https://radarr.video/)** - Movie management
- **[Sonarr](https://sonarr.tv/)** - TV series management
- **[Prowlarr](https://prowlarr.com/)** - Indexer management
- **[Decypharr](https://github.com/enty8080/Decypharr)** or **[RDTClient](https://github.com/rogerfar/rdt-client)** - Download client with symlink support
- **[Zurg](https://github.com/debridmediamanager/zurg-testing)** - Real-Debrid WebDAV server
- **[Rclone](https://github.com/rclone/rclone)** - Mounts Zurg as local filesystem
- **[Zilean](https://github.com/iPromKnight/zilean)** - Debrid Media Manager indexer
- **[Overseerr](https://overseerr.dev/)** - Media request management
- **[Autoscan](https://github.com/saltydk/autoscan)** - Plex library updates

## How It Works

The workflow is completely automated:

1. Request content through Overseerr
2. Radarr/Sonarr search indexers via Prowlarr
3. Zilean provides cached torrents from Debrid Media Manager
4. Download client adds torrent to Real-Debrid
5. Zurg exposes Real-Debrid library via WebDAV
6. Rclone mounts Zurg as local filesystem
7. Download client creates symlinks to mounted files
8. Radarr/Sonarr import the symlinks
9. Autoscan triggers Plex library refresh
10. Stream instantly through Plex

No actual downloading to local storage - everything streams from Real-Debrid.

## What the Installer Does

### 1. System Preparation
- Installs Docker and Docker Compose if needed
- Creates directory structure with correct permissions
- Configures users and groups per Servarr Wiki best practices
- Sets up file permissions (775/664, umask 002) for proper hardlinking

### 2. Service Deployment
- Deploys all containers via Docker Compose
- Waits for each service to become healthy
- Automatically extracts API keys from configuration files

### 3. Automatic Configuration
- **Prowlarr:** Adds Zilean indexer with correct settings
- **Radarr/Sonarr:** Connects to Prowlarr, configures download client, sets root folders
- **Download Client:** Configures Real-Debrid integration and symlink paths
- **Quality Profiles:** Removes defaults, creates TRaSH Guide profiles (1080p, 2160p, Any)
- **Recyclarr:** Syncs custom formats and naming conventions

### 4. Health Monitoring
- Installs cron jobs to check mount health every 30-35 minutes
- Automatically restarts containers if mounts fail
- Logs health checks to `/mediacenter/logs/`

## Accessing Services

After installation completes, access your services at:

- **Plex:** `http://YOUR_SERVER_IP:32400/web`
- **Radarr:** `http://YOUR_SERVER_IP:7878`
- **Sonarr:** `http://YOUR_SERVER_IP:8989`
- **Prowlarr:** `http://YOUR_SERVER_IP:9696`
- **Overseerr:** `http://YOUR_SERVER_IP:5055`

All inter-service connections are already configured.

## Quality Profiles

Three TRaSH Guide profiles are automatically created:

- **Recyclarr-1080p** - Accepts HD content, upgrades to Remux-1080p
- **Recyclarr-2160p** - Accepts 4K content, upgrades to Remux-2160p
- **Recyclarr-Any** - Accepts any quality, upgrades to best available

To manually update profiles after installation:

```bash
cd /mediacenter
./recyclarr-sync.sh
```

## Directory Structure

```
/mediacenter/
├── config/              # Application configurations
│   ├── plex-config/
│   ├── radarr-config/
│   ├── sonarr-config/
│   └── ...
├── data/               # Media and downloads
│   ├── media/
│   │   ├── movies/    # Radarr movies
│   │   └── tv/        # Sonarr TV shows
│   ├── torrents/      # Download client symlinks
│   └── realdebrid-zurg/ # Rclone mount point
├── logs/              # Health check logs
└── docker/            # Docker Compose files
```

## Troubleshooting

### Check Service Status
```bash
docker ps -a
```

### View Container Logs
```bash
docker logs <container_name>
```

### Restart All Services
```bash
cd /mediacenter/docker
docker compose restart
```

### Check Mount Health
```bash
tail -f /mediacenter/logs/plex-mount-healthcheck.log
tail -f /mediacenter/logs/arrs-mount-healthcheck.log
```

### Common Issues

**Containers won't start:** Check Docker logs and verify Real-Debrid API token is valid

**No search results:** Wait for Zilean to populate its database (can take 1-2 hours initially)

**Files not appearing:** Check mount health logs and verify rclone container is healthy

**Permission errors:** Verify directory ownership matches configured UIDs/GIDs

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

And all the developers of the tools in this stack: Plex, Radarr, Sonarr, Prowlarr, Overseerr, Zurg, Rclone, Zilean, Decypharr, RDTClient, and Autoscan.

## License

MIT License - Use and modify as needed.

## Disclaimer

This tool is for educational purposes. Ensure you comply with your local laws and Real-Debrid's terms of service.
