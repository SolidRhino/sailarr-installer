#!/bin/bash
# MediaCenter Stack - Start Services
# Usage: ./up.sh [service_name]

./compose.sh up -d "$@"