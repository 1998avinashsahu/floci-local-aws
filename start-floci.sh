#!/bin/bash
# Start Floci local AWS emulator

CONTAINER_NAME="floci"
IMAGE="floci/floci:latest"
PORT=4566

if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "Floci is already running on http://localhost:${PORT}"
  exit 0
fi

if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "Restarting existing Floci container..."
  docker start ${CONTAINER_NAME}
else
  echo "Pulling and starting Floci..."
  docker run -d --name ${CONTAINER_NAME} \
    -p ${PORT}:4566 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    ${IMAGE}
fi

echo ""
echo "Floci running at http://localhost:${PORT}"
echo ""
echo "Load AWS env vars with:"
echo "  source $(dirname "$0")/aws-env.sh"
