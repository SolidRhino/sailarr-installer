#!/bin/bash
# MediaCenter Stack - Stop Services
# Usage: ./down.sh [service_name]

./compose.sh down "$@"