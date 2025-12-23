#!/bin/bash
# Quick one-liner fix - paste this entire block into your server terminal

cd ~/comm && \
docker compose down && \
sed -i '1,2d' docker-compose.yml && \
sed -i 's|image: receevi/receevi:latest|image: ghcr.io/receevi/receevi:latest|g' docker-compose.yml && \
docker compose pull && \
echo "Files fixed! Now run: sudo ./setup.sh"
