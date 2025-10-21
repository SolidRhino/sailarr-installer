#!/bin/bash
# MediaCenter Stack - Restart Services
# Usage: ./restart.sh [service_name]

./compose.sh restart "$@"
