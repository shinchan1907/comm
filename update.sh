#!/bin/bash

# Update script for n8n + Receevi

echo "========================================="
echo "  Updating n8n + Receevi"
echo "========================================="
echo ""

# Pull latest images
echo "1. Pulling latest Docker images..."
docker compose pull

# Stop services
echo "2. Stopping services..."
docker compose down

# Start services with new images
echo "3. Starting services with updated images..."
docker compose up -d

# Wait for services to start
echo "4. Waiting for services to start..."
sleep 10

# Show status
echo "5. Service status:"
docker compose ps

echo ""
echo "========================================="
echo "  Update Complete!"
echo "========================================="
echo ""
echo "Check logs with: docker compose logs -f"
echo ""
