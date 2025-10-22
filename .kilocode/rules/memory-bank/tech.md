**Technologies Used:**

*   **Core Technologies:** Docker and Docker Compose are central to the project, orchestrating the entire suite of services. The installer itself is a Bash script (`setup.sh`).
*   **Primary Services:** The media stack is built on a collection of open-source applications, including Plex, Radarr, Sonarr, Prowlarr, Zurg, Rclone, and Decypharr.
*   **Database:** PostgreSQL is used as the database for the Zilean indexer.
*   **Reverse Proxy:** Traefik is used for reverse proxying and handling HTTPS.
*   **Development and Automation:** The installation script uses `curl` for API calls and `jq` for parsing JSON responses during the auto-configuration phase. It also interacts with the system using `useradd`, `groupadd`, and `crontab` for setting up users, groups, and scheduled tasks.