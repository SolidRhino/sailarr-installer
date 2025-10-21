#!/bin/bash
# MediaCenter Stack - Docker Compose Wrapper
# Handles profile management and environment files
# Usage: ./compose.sh <command> [arguments...]

# Load TRAEFIK_ENABLED from .env.local if it exists
TRAEFIK_ENABLED=false
if [ -f .env.local ]; then
    source .env.local
fi

# Build profile arguments
PROFILE_ARGS=""
if [ "$TRAEFIK_ENABLED" = true ]; then
    PROFILE_ARGS="--profile traefik"
fi

# Execute docker compose with all arguments
docker compose --env-file .env.defaults --env-file .env.local $PROFILE_ARGS "$@"
