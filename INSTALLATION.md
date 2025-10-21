# Installation Guide

This guide walks you through the complete installation process, explaining each step and configuration option.

## Prerequisites

Before starting the installation, ensure you have:

1. **A server running Ubuntu 20.04+ or Debian 11+**
   - Minimum 8GB RAM (16GB recommended)
   - At least 50GB free disk space
   - Root or sudo access

2. **Docker and Docker Compose installed**
   ```bash
   # Check if Docker is installed
   docker --version
   docker compose version

   # If not installed, follow the official Docker installation guide:
   # https://docs.docker.com/engine/install/
   ```

3. **Real-Debrid account with API token**
   - Sign up at https://real-debrid.com/
   - Get your API token from https://real-debrid.com/apitoken
   - Keep this token ready for the installation

4. **Plex claim token (optional)**
   - Only needed if you want hardware transcoding or remote access
   - Get it from https://www.plex.tv/claim/
   - The token expires after 4 minutes, so get it right before installation

## Installation Steps

### Step 1: Clone the Repository

```bash
git clone https://github.com/JaviPege/sailarr-installer.git
cd sailarr-installer
```

### Step 2: Make the Script Executable

```bash
chmod +x setup.sh
```

### Step 3: Run the Installer

```bash
./setup.sh
```

The installer will now guide you through the configuration process.

## Configuration Questions

The installer will ask you four questions. Here's what each one means and how to answer:

### Question 1: Installation Directory

```
Enter the root directory for the installation (default: /mediacenter):
```

**What it does:** This is where all your configuration files, media, and Docker volumes will be stored.

**Default:** `/mediacenter`

**When to change it:**
- If `/mediacenter` doesn't exist or you don't have permissions
- If you want to use a different mount point (e.g., `/mnt/storage`)
- If you're testing and want to isolate the installation

**Example paths:**
- `/mediacenter` - Standard installation
- `/mnt/storage/mediacenter` - Using external storage
- `/home/username/mediacenter` - User home directory (for testing)

**What gets created:**
```
/mediacenter/
├── config/         # All application configurations
├── data/          # Media files and symlinks
├── logs/          # Health check logs
└── docker/        # Docker Compose files
```

### Question 2: Real-Debrid API Token

```
Enter your Real-Debrid API token (get it from https://real-debrid.com/apitoken):
```

**What it does:** This token authenticates your Real-Debrid account so the download client and Zurg can access your cached torrents.

**How to get it:**
1. Go to https://real-debrid.com/apitoken
2. Log in to your Real-Debrid account
3. Copy the API token shown on the page

**Format:** A long alphanumeric string (e.g., `ABC123XYZ789...`)

**Important:**
- Keep this token secret - it gives full access to your Real-Debrid account
- If you accidentally expose it, regenerate a new token from the Real-Debrid website
- The installer stores it in configuration files that are protected by file permissions

**What uses this token:**
- Zurg: To mount your Real-Debrid library
- Download client (Decypharr/RDTClient): To add torrents to Real-Debrid

### Question 3: Plex Claim Token (Optional)

```
Enter your Plex claim token (optional, get it from https://www.plex.tv/claim/):
Press Enter to skip if you don't want to claim the server now.
```

**What it does:** Claims your Plex server to your Plex account, enabling remote access and hardware transcoding.

**How to get it:**
1. Go to https://www.plex.tv/claim/
2. Log in to your Plex account
3. Copy the claim token shown

**Format:** Starts with `claim-` followed by alphanumeric characters (e.g., `claim-AbCdEfGhIjKlMnOp`)

**Important:**
- The token expires after 4 minutes - get it right before you need to enter it
- If it expires, just get a new one from the same URL

**When to use it:**
- You want to access Plex remotely (outside your local network)
- You want hardware transcoding support
- You want to use Plex features that require authentication

**When to skip it:**
- You only need local network access
- You'll claim the server manually later through the Plex web interface
- You're testing and don't want to connect to your main Plex account

**Can you add it later?** Yes! You can claim the server later by:
1. Going to `http://YOUR_SERVER_IP:32400/web`
2. Logging in with your Plex account
3. Following the setup wizard

### Question 4: Download Client Selection

```
Select download client:
1) Decypharr (recommended - lightweight, fast)
2) RDTClient (feature-rich web UI)
Enter choice (1 or 2):
```

**What it does:** The download client manages torrents with Real-Debrid and creates symlinks for Radarr/Sonarr.

#### Option 1: Decypharr (Recommended)

**Pros:**
- Lightweight and fast
- Lower resource usage
- Simpler configuration
- Works great with Real-Debrid

**Cons:**
- Minimal web interface
- Fewer advanced features

**Best for:**
- Most users
- Limited system resources
- Simple setups
- When you just want it to work

**Web UI:** `http://YOUR_SERVER_IP:8181`

#### Option 2: RDTClient

**Pros:**
- Full-featured web interface
- Advanced torrent management
- Detailed statistics and logs
- More configuration options

**Cons:**
- Higher resource usage
- More complex to configure manually
- Overkill for most use cases

**Best for:**
- Power users
- Those who want detailed control
- Monitoring torrent status closely
- Managing multiple download categories

**Web UI:** `http://YOUR_SERVER_IP:6500`

**Which should you choose?**
- **First time user?** Choose Decypharr (option 1)
- **Want simple and reliable?** Choose Decypharr (option 1)
- **Need advanced features?** Choose RDTClient (option 2)

**Can you change it later?** Yes, but you'll need to:
1. Stop the stack: `docker compose down`
2. Edit your configuration
3. Restart: `docker compose up -d`
4. Reconfigure Radarr/Sonarr download client settings

## Installation Process

After answering all questions, the installer will:

### 1. Create Directory Structure (10-15 seconds)
- Creates `/mediacenter` and subdirectories
- Sets up proper ownership and permissions
- Creates user groups

### 2. Generate Configuration Files (5 seconds)
- Creates Docker Compose files
- Generates environment files
- Configures Zurg with your Real-Debrid token
- Sets up rclone configuration

### 3. Deploy Docker Containers (2-5 minutes)
- Pulls Docker images (this can take a while on first run)
- Starts all containers
- Waits for each service to become healthy

**Services started:**
- Zurg (Real-Debrid WebDAV)
- Rclone (Mount manager)
- Plex Media Server
- Radarr (Movies)
- Sonarr (TV Shows)
- Prowlarr (Indexers)
- Zilean (DMM Indexer)
- Decypharr or RDTClient (Download client)
- Overseerr (Request management)
- Autoscan (Library updates)

### 4. Extract API Keys (30 seconds)
- Waits for services to generate API keys
- Automatically extracts keys from configuration files
- Stores them for automatic configuration

### 5. Configure Services (1-2 minutes)

#### Prowlarr Configuration
- Adds Zilean indexer
- Configures connection to `http://zilean:8181`
- Sets up API key authentication

#### Radarr Configuration
- Adds Prowlarr as indexer source
- Configures download client (Decypharr or RDTClient)
- Sets root folder to `/data/media/movies`
- Configures Real-Debrid settings

#### Sonarr Configuration
- Adds Prowlarr as indexer source
- Configures download client (Decypharr or RDTClient)
- Sets root folder to `/data/media/tv`
- Configures Real-Debrid settings

#### Download Client Configuration
- Sets up Real-Debrid API token
- Configures symlink paths
- Sets minimum file size filters
- Enables instant availability mode

### 6. Quality Profiles (30 seconds)
- Removes all default quality profiles
- Runs Recyclarr to create TRaSH Guide profiles:
  - **Recyclarr-1080p**: HD content up to Remux-1080p
  - **Recyclarr-2160p**: 4K content up to Remux-2160p
  - **Recyclarr-Any**: Any quality, prefers best

### 7. Health Monitoring Setup (5 seconds)
- Installs cron jobs for mount health checks
- Plex: Every 35 minutes
- Arrs: Every 30 minutes
- Creates log files in `/mediacenter/logs/`

## Post-Installation

### Verify Installation

Check that all containers are running:

```bash
docker ps
```

You should see all services with status "Up" and "healthy".

### Access Your Services

- **Plex:** http://YOUR_SERVER_IP:32400/web
- **Radarr:** http://YOUR_SERVER_IP:7878
- **Sonarr:** http://YOUR_SERVER_IP:8989
- **Prowlarr:** http://YOUR_SERVER_IP:9696
- **Overseerr:** http://YOUR_SERVER_IP:5055
- **Decypharr:** http://YOUR_SERVER_IP:8181 (if selected)
- **RDTClient:** http://YOUR_SERVER_IP:6500 (if selected)

### Initial Setup Tasks

1. **Overseerr Setup:**
   - Open Overseerr
   - Connect to your Plex server
   - Configure Radarr and Sonarr connections
   - Set up user access

2. **Plex Library Setup:**
   - Add movie library: `/data/media/movies`
   - Add TV library: `/data/media/tv`
   - Configure metadata preferences

3. **Wait for Zilean:**
   - Zilean needs to populate its database
   - Initial population: 1-2 hours
   - Full database: Can take up to 24 hours
   - Check progress: `docker logs zilean`

### First Request

1. Open Overseerr
2. Search for a movie or TV show
3. Click "Request"
4. Wait a few minutes
5. Check Radarr/Sonarr for activity
6. Once imported, it will appear in Plex

## Troubleshooting

### No Services Accessible

**Check if containers are running:**
```bash
docker ps -a
```

**Check container logs:**
```bash
docker logs <container_name>
```

### Real-Debrid Connection Failed

**Verify your API token:**
1. Check `/mediacenter/config/zurg-config/config.yml`
2. Verify the token matches your Real-Debrid account
3. Test the token at https://api.real-debrid.com/rest/1.0/user (in browser)

### Plex Not Accessible

**If you used a claim token:**
- Make sure it didn't expire (4-minute limit)
- Try accessing locally first: http://localhost:32400/web

**If you skipped the claim token:**
- Access via http://YOUR_SERVER_IP:32400/web
- Sign in and claim the server manually

### No Search Results in Radarr/Sonarr

**Wait for Zilean to populate:**
```bash
docker logs zilean | grep -i "scraping\|complete"
```

**Check Prowlarr connection:**
1. Open Prowlarr
2. Go to Indexers
3. Test the Zilean indexer
4. Check sync status with Radarr/Sonarr

### Symlinks Not Created

**Check download client logs:**
```bash
docker logs decypharr
# or
docker logs rdtclient
```

**Verify mount is working:**
```bash
docker exec rclone ls /data/realdebrid-zurg/
```

**Check health logs:**
```bash
tail -f /mediacenter/logs/arrs-mount-healthcheck.log
```

### Permission Errors

**Check directory ownership:**
```bash
ls -la /mediacenter/
```

**Fix permissions if needed:**
```bash
sudo chown -R 1000:mediacenter /mediacenter/config
sudo chown -R 1000:mediacenter /mediacenter/data
```

## Advanced Configuration

### Update Quality Profiles

After installation, you can update quality profiles:

```bash
cd /mediacenter
./recyclarr-sync.sh
```

### Add More Indexers

1. Open Prowlarr
2. Go to Settings > Indexers
3. Add your preferred indexers
4. Sync to Radarr/Sonarr

### Customize Quality Settings

Edit `/mediacenter/recyclarr.yml` and run:
```bash
./recyclarr-sync.sh
```

### Enable Traefik (Reverse Proxy)

If you want HTTPS and domain names:

1. Edit `/mediacenter/docker/.env`
2. Set `TRAEFIK_ENABLED=true`
3. Configure domain names
4. Restart: `docker compose up -d`

## Maintenance

### Update Containers

```bash
cd /mediacenter/docker
docker compose pull
docker compose up -d
```

### View Logs

```bash
# All containers
docker compose logs -f

# Specific container
docker logs -f <container_name>

# Health checks
tail -f /mediacenter/logs/*.log
```

### Restart Services

```bash
# All services
cd /mediacenter/docker
docker compose restart

# Specific service
docker restart <container_name>
```

### Backup Configuration

```bash
# Backup config directory
tar -czf mediacenter-backup-$(date +%Y%m%d).tar.gz /mediacenter/config/
```

## Getting Help

If you encounter issues:

1. Check container logs: `docker logs <container_name>`
2. Verify all containers are healthy: `docker ps`
3. Check health monitoring logs: `tail -f /mediacenter/logs/*.log`
4. Review the Troubleshooting section above
5. Consult the service-specific documentation (Radarr, Sonarr, etc.)

## Next Steps

Once installation is complete:

1. Configure Overseerr for content requests
2. Set up Plex libraries and metadata
3. Customize quality profiles in Recyclarr
4. Add additional indexers in Prowlarr
5. Configure notifications in Radarr/Sonarr
6. Set up remote access (optional)
7. Start requesting content and enjoy!
