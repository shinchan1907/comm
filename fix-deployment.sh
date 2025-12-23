#!/bin/bash

# Quick Fix Script - Run this on your server to fix the deployment

echo "========================================="
echo "  Fixing Deployment Issues"
echo "========================================="
echo ""

# Stop any running containers
echo "1. Stopping existing containers..."
docker compose down 2>/dev/null

# Clean up
echo "2. Cleaning up..."
rm -f nginx/conf.d/temp.conf 2>/dev/null

# Pull the correct images
echo "3. Pulling correct Docker images..."
docker compose pull

# Check if .env exists
if [ ! -f .env ]; then
    echo "ERROR: .env file not found!"
    echo "Please create .env from .env.example and configure it."
    exit 1
fi

# Load environment
source .env

# Verify required variables
if [ -z "$SSL_EMAIL" ] || [ "$SSL_EMAIL" = "your-email@example.com" ]; then
    echo "ERROR: Please set SSL_EMAIL in .env file"
    exit 1
fi

if [ -z "$N8N_ENCRYPTION_KEY" ] || [ "$N8N_ENCRYPTION_KEY" = "CHANGE_THIS_TO_RANDOM_STRING" ]; then
    echo "ERROR: Please set N8N_ENCRYPTION_KEY in .env file"
    echo "Generate one with: openssl rand -base64 32"
    exit 1
fi

# Create temporary nginx config for SSL challenge
echo "4. Creating temporary nginx config..."
mkdir -p nginx/conf.d
cat > nginx/conf.d/temp.conf << 'EOF'
server {
    listen 80;
    server_name n8n.bytenex.io wa.bytenex.io;
    
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
    
    location / {
        return 200 'OK';
        add_header Content-Type text/plain;
    }
}
EOF

# Start only nginx for certificate generation
echo "5. Starting nginx for certificate challenge..."
docker compose up -d nginx
sleep 5

# Generate SSL certificates
echo "6. Generating SSL certificates..."
echo "   Requesting certificate for n8n.${DOMAIN}..."
docker compose run --rm certbot certonly --webroot \
    --webroot-path=/var/www/certbot \
    --email ${SSL_EMAIL} \
    --agree-tos \
    --no-eff-email \
    --force-renewal \
    -d n8n.${DOMAIN}

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to generate certificate for n8n.${DOMAIN}"
    echo "Please check:"
    echo "  1. DNS n8n.${DOMAIN} points to this server IP"
    echo "  2. Port 80 is open and accessible"
    echo "  3. Cloudflare proxy is enabled (orange cloud)"
    docker compose down
    exit 1
fi

echo "   Requesting certificate for wa.${DOMAIN}..."
docker compose run --rm certbot certonly --webroot \
    --webroot-path=/var/www/certbot \
    --email ${SSL_EMAIL} \
    --agree-tos \
    --no-eff-email \
    --force-renewal \
    -d wa.${DOMAIN}

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to generate certificate for wa.${DOMAIN}"
    echo "Please check:"
    echo "  1. DNS wa.${DOMAIN} points to this server IP"
    echo "  2. Port 80 is open and accessible"
    echo "  3. Cloudflare proxy is enabled (orange cloud)"
    docker compose down
    exit 1
fi

# Remove temporary config
echo "7. Removing temporary config..."
rm nginx/conf.d/temp.conf

# Start all services
echo "8. Starting all services..."
docker compose down
docker compose up -d

# Wait for services
echo "9. Waiting for services to start..."
sleep 10

# Check status
echo ""
echo "========================================="
echo "  Service Status"
echo "========================================="
docker compose ps

echo ""
echo "========================================="
echo "  Deployment Fixed!"
echo "========================================="
echo ""
echo "Your services should now be available at:"
echo "  n8n:     https://n8n.${DOMAIN}"
echo "  Receevi: https://wa.${DOMAIN}"
echo ""
echo "Check logs with: docker compose logs -f"
echo ""
