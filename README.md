# MediaCenter - Automated Setup

Fully automated installation script for creating your own 'infinite' media library, powered by Real-Debrid and the *Arr stack. Inspired by [Naralux/mediacenter](https://github.com/Naralux/mediacenter) with significant enhancements and automation.

**Key Feature: One command installation** - This version includes a comprehensive `setup.sh` script that automates the entire stack deployment, eliminating manual configuration steps.

# Purpose
The purpose of this stack is to create a functioning stack of *Arr powered tools that allow for the streaming of cached torrents via Real-Debrid. All of this using Docker Containers.

This setup favors consumption instead of collection. It is possible to combine it with a library of locally stored files, but that is left for you to configure.

**What makes this version different:**
- Fully automated installation via `setup.sh`
- Automatic API key extraction and service configuration
- TRaSH Guide profiles automatically configured via Recyclarr
- Default quality profiles automatically removed
- Health monitoring with automated container restarts
- Support for both RDTClient and Decypharr download clients

# Requirements
- Active [Real-Debrid](https://real-debrid.com/) subscription and your [API key](https://real-debrid.com/apitoken).
- Docker Engine + Docker Compose.

## My Setup
I'm running this stack on a Ubuntu Server (24.04 LTS) Virtual Machine (8GB RAM, 50GB disk (you don't need 50GB, can be less)) on a Proxmox node. Make sure the IP is static.

I play media exclusively via the Plex App on a Nvidia Shield Pro that Direct Plays almost all types of formats. My Radarr/Sonarr quality profiles are tweaked in such a way that I only grab content that my setup can Direct Play. If your setup requires transcoding search for additional guides online on setting up Plex in Docker with hardware transcoding enabled, this setup does NOT support hardware transcoding as-is.

# Stack
- [Zurg](https://github.com/debridmediamanager/zurg-testing)
- [Rclone](https://github.com/rclone/rclone)
- [RDTClient](https://github.com/rogerfar/rdt-client)
- [Overseerr](https://overseerr.dev/)
- [Radarr](https://radarr.video/)
- [Sonarr](https://sonarr.tv/)
- [Recyclarr](https://recyclarr.dev/)
- [Prowlarr](https://prowlarr.com/)
- [Zilean](https://github.com/iPromKnight/zilean)
- [Plex](https://www.plex.tv/)
- [Autoscan](https://github.com/saltydk/autoscan)

Read the dedicated tool pages linked above to learn more about their function and configuration.

In a nutshell:
- Zurg + Rclone mount your Real-Debrid library into your filesystem.
- Request movies/series using Overseerr.
- Hand the request over to Radarr/Sonarr.
- Radarr/Sonarr instruct Prowlarr to search torrent indexers.
- Zilean serves as an indexer that scrapes [Debrid Media Manager](https://github.com/debridmediamanager/debrid-media-manager).
- Prowlarr returns found results to Radarr/Sonarr and pick a candidate.
- Radarr/Sonarr hands the torrent over to the RDTClient Download Client.
- RDTClient:
    - Adds the torrent to your Real-Debrid account.
    - Checks if the file is available on your filesystem (which is mounted by Rclone, remember).
    - Creates symlinks to Radarr/Sonarr's `completed` directory.
- Radarr/Sonarr continues processing as if the file exists locally and moves it to the media folder.
- Autoscan is triggered by Radarr/Sonarr and pushes a library refresh to Plex.
- Plex reads the file symlinks in the media folder. The symlinks resolve to the file in the Rclone mounted filesystem.

Visual representation (credits to ElfHosted):

![Visualized flow. Credits to ElfHosted.](./images/flow-visualization.png)

# Quick Start (Automated Setup)

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/mediacenter.git
cd mediacenter

# Make the script executable
chmod +x setup.sh

# Run the installation script
sudo ./setup.sh
```

The script will interactively guide you through:
1. Setting installation directory (default: `/mediacenter`)
2. Entering your Real-Debrid API token
3. Configuring Plex claim token (optional)
4. Choosing download client (RDTClient or Decypharr)

## What the Automated Setup Does

The `setup.sh` script performs a **fully automated installation**:

1. **System Preparation**
   - Installs Docker and Docker Compose if needed
   - Creates required directories with proper permissions (775/664, umask 002)
   - Configures users and groups (follows Servarr Wiki best practices)

2. **Service Deployment**
   - Deploys all containers via Docker Compose
   - Waits for services to become healthy
   - Automatically extracts API keys from each service

3. **Automatic Configuration**
   - **Prowlarr**: Configures Zilean indexer automatically
   - **Sonarr/Radarr**: Connects to Prowlarr and configures download client
   - **Decypharr/RDTClient**: Configures Real-Debrid integration
   - **Quality Profiles**: Removes all default profiles and creates TRaSH Guide profiles via Recyclarr
   - **Root Folders**: Configures `/data/media/movies` and `/data/media/tv`

4. **Health Monitoring**
   - Sets up cron jobs to monitor mount health every 30-35 minutes
   - Automatically restarts containers if mounts fail
   - Logs all health checks to `/mediacenter/logs/`

**No manual configuration required!** Everything is set up and ready to use after the script completes.

## Updating Quality Profiles

To manually update quality profiles after installation:

```bash
cd /mediacenter
./recyclarr-sync.sh
```

# Manual Setup (Original Method)
__The most important thing is to get the permissions (775/664, umask 002) right. If files don't show up inside containers, it is most likely a permissions problem. If you decide to run everything as one user, use 755/644 umask 022 and tweak the necessary files as needed__

__The filesystem is designed to allow for [hardlinking](https://trash-guides.info/Hardlinks/Hardlinks-and-Instant-Moves/), as per the [Servarr Wiki recommendation](https://wiki.servarr.com/docker-guide#consistent-and-well-planned-paths).__

__If you are new to the *Arr stack, you must read the [Servarr Wiki](https://wiki.servarr.com/)!__

1. Add your Plex Claim Token to `.env` and tweak IDs to your liking.
    - Every container runs as its own user. All users are part of the same group. This is best practice.
2. Add your Real-Debrid API Token to `zurg.yml`.
3. Take a look at the `setup.sh` script and run it using `./setup.sh`.
    - `sudo chmod +x setup.sh` if it is not executable.
4. Reboot (virtual) machine.
5. The first time you run the stack `Zilean` is going to need some time to fill its database.
    - *(You can of course use your preferred indexer instead and remove Zilean from the stack.)*
    - Configure `Zilean` by editing/creating `${ROOT_DIR}/config/zilean-config/settings.json`. See [wiki](https://ipromknight.github.io/zilean/configuration.html) for guidance.
6. Run `docker compose up -d`.
    - If you decided to keep Zilean and have enabled its IMDB Matching functionality, this first run can take VERY long (>1.5 DAYS!).
7. Setup RDTClient:
    - Settings -> General:
        - Maximum parallel downloads = `100`
        - Maximum unpack processes = `100`
        - Categories: `radarr,sonarr`
    - Settings -> Download Client:
        - Download Client = `Symlink Downloader`
        - Download path = `/data/symlinks`
        - Mapped path = `/data/symlinks`
        - Rclone mount path = `/data/realdebrid-zurg/torrents/*`
    - Settings -> Provider:
        - Provider = `RealDebrid`
        - API Key = `*Your API Key*`
    - Settings -> qBittorrent / *darr:
        - Post Torrent Download Action = `Download all files to host`
        - Post Download Action = `No Action`
        - Only download available files on debrid provider = `checked`
        - Minimum file size to download = `50`
        - *(Unsure if these settings should also be set on the Provider and GUI Defaults setting pages, but it doesn't hurt to do so)*
8. Setup Radarr:
    - Consult the Servarr Wiki for guidance if needed.
    - Just follow the [TRaSH-Guides](https://trash-guides.info/Radarr/) for sensible defaults when setting up Quality Profiles, or see [Recyclarr Profile](#recyclarr-profile).
    - Set your Root Folder to `/data/media/movies`.
    - Take note of your API key under Settings -> General -> API Key.
9. Setup Sonarr:
    - Consult the Servarr Wiki for guidance if needed.
    - Just follow the [TRaSH-Guides](https://trash-guides.info/Sonarr/) for sensible defaults when setting up Quality Profiles, or see [Recyclarr Profile](#recyclarr-profile).
    - Set your Root Folder to `/data/media/tv`.
    - Take note of your API key under Settings -> General -> API Key.
10. Setup Overseerr.
11. Setup Prowlarr (no need to setup a Download Client).
    - Consult the Servarr Wiki for guidance if needed.
    - If you want to use Torrentio:
        - Grab the files from [here](https://github.com/dreulavelle/Prowlarr-Indexers/tree/main/Custom) and place them inside `${ROOT_DIR}/config/prowlarr-config/Definitions/Custom/`.
    - For Zilean, see the instructions [here](https://ipromknight.github.io/zilean/torznab-indexer.html#setting-up-as-torznab-indexer-for-prowlarr).
    - Configure indexers.
12. Setup Autoscan.
    - Place the file `./autoscan/config.yml` in `${ROOT_DIR}/config/autoscan-config`.
    - Tweak the config if necessary.
    - Follow the instructions on the [GitHub repo](https://github.com/saltydk/autoscan?tab=readme-ov-file#the--arrs) to connect Radarr/Sonarr to Autoscan.
13. Setup Plex.
    - Configure movie library to point to `/data/media/movies`.
    - Configure tv library to point to `/data/media/tv`.

## Recyclarr Profile
Included in this repo is a `recyclarr.yml` file that will sync two quality profiles to Radarr and Sonarr. One for 1080p and one for 2160p. Out of the box these profiles will accept every type of quality for each resolution. E.g. the 1080p profile will accept everything from `HDTV-1080p` all the way up to `REMUX-1080p`, but prefers the highest quality.

Tweak the profiles to your needs (like changing the `until_score`) or create your own from scratch. Consult the [Recyclarr website](https://recyclarr.dev/) for guidance.

Place the file `./recyclarr/recyclarr.yaml` in `${ROOT_DIR}/config/recyclarr-config/`. If docker compose is already running, run the following command: `docker compose exec recyclarr recyclarr sync` and monitor the output.

# Development

This automated setup was developed step-by-step with guidance and direction, using [Claude Code](https://claude.com/claude-code) as the development assistant.

# Interesting Reads + Credits
- **[Naralux/mediacenter](https://github.com/Naralux/mediacenter)** - Original repository that this automated setup is based on
- **[TRaSH Guides](https://trash-guides.info/)** - Quality profiles, custom formats, and naming conventions
- **[Savvy Guides / Sailarr's Guide](https://savvyguides.wiki/sailarrsguide/)** - Comprehensive guide for *Arr stack setup
- **[Servarr Wiki](https://wiki.servarr.com/)** - Official documentation, especially the [Docker Guide](https://wiki.servarr.com/docker-guide)
- **[Recyclarr](https://recyclarr.dev/)** - Automated TRaSH Guide syncing tool
- All the authors of the tools used in the stack
- [ElfHosted's article](https://elfhosted.com/guides/media/stream-from-real-debrid-with-plex-radarr-sonarr-prowlarr/) for the initial inspiration
- [Ezarr](https://github.com/Luctia/ezarr) - Foundation for the approach
- [Debrid Media Manager](https://github.com/debridmediamanager/debrid-media-manager) - Introduction to Debrid services
- [dreulavelle/Prowlarr-Indexers](https://github.com/dreulavelle/Prowlarr-Indexers) - Prowlarr torrentio configurations
