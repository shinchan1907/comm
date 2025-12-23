#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  n8n + Receevi Docker Setup${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run as root (use sudo)${NC}"
    exit 1
fi

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}Creating .env file from template...${NC}"
    cp .env.example .env
    echo -e "${RED}IMPORTANT: Please edit .env file with your configuration!${NC}"
    echo -e "${YELLOW}Especially set:${NC}"
    echo "  - SSL_EMAIL (your email for Let's Encrypt)"
    echo "  - N8N_ENCRYPTION_KEY (generate with: openssl rand -base64 32)"
    echo ""
    read -p "Press Enter after you've edited .env file..."
fi

# Load environment variables
source .env

# Update system
echo -e "${GREEN}[1/8] Updating system packages...${NC}"
apt-get update -qq

# Install Docker if not installed
if ! command -v docker &> /dev/null; then
    echo -e "${GREEN}[2/8] Installing Docker...${NC}"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    systemctl enable docker
    systemctl start docker
else
    echo -e "${GREEN}[2/8] Docker already installed${NC}"
fi

# Install Docker Compose if not installed
if ! command -v docker-compose &> /dev/null; then
    echo -e "${GREEN}[3/8] Installing Docker Compose...${NC}"
    apt-get install -y docker-compose-plugin
else
    echo -e "${GREEN}[3/8] Docker Compose already installed${NC}"
fi

# Create necessary directories
echo -e "${GREEN}[4/8] Creating directories...${NC}"
mkdir -p nginx/conf.d nginx/ssl certbot/conf certbot/www

# Set proper permissions
echo -e "${GREEN}[5/8] Setting permissions...${NC}"
chmod -R 755 nginx
chmod -R 755 certbot

# Start services temporarily for certificate generation
echo -e "${GREEN}[6/8] Starting Nginx for certificate generation...${NC}"

# Create temporary nginx config for certificate challenge
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

# Start only nginx and certbot for certificate generation
docker compose up -d nginx

# Wait for nginx to start
sleep 5

# Generate SSL certificates
echo -e "${GREEN}[7/8] Generating SSL certificates...${NC}"
echo -e "${YELLOW}Requesting certificate for n8n.${DOMAIN}...${NC}"
docker compose run --rm certbot certonly --webroot \
    --webroot-path=/var/www/certbot \
    --email ${SSL_EMAIL} \
    --agree-tos \
    --no-eff-email \
    --force-renewal \
    -d n8n.${DOMAIN}

if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to generate certificate for n8n.${DOMAIN}${NC}"
    echo -e "${YELLOW}Please check:${NC}"
    echo "  1. DNS is pointing to this server"
    echo "  2. Port 80 is accessible from internet"
    echo "  3. Domain name is correct in .env file"
    exit 1
fi

echo -e "${YELLOW}Requesting certificate for wa.${DOMAIN}...${NC}"
docker compose run --rm certbot certonly --webroot \
    --webroot-path=/var/www/certbot \
    --email ${SSL_EMAIL} \
    --agree-tos \
    --no-eff-email \
    --force-renewal \
    -d wa.${DOMAIN}

if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to generate certificate for wa.${DOMAIN}${NC}"
    echo -e "${YELLOW}Please check:${NC}"
    echo "  1. DNS is pointing to this server"
    echo "  2. Port 80 is accessible from internet"
    echo "  3. Domain name is correct in .env file"
    exit 1
fi

# Remove temporary config
rm nginx/conf.d/temp.conf

# Reload nginx with proper configs
echo -e "${GREEN}[8/8] Starting all services...${NC}"
docker compose down
docker compose up -d

# Wait for services to start
echo -e "${YELLOW}Waiting for services to start...${NC}"
sleep 10

# Check service status
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Service Status${NC}"
echo -e "${GREEN}========================================${NC}"
docker compose ps

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${GREEN}Your services are now available at:${NC}"
echo -e "  n8n:     ${YELLOW}https://n8n.${DOMAIN}${NC}"
echo -e "  Receevi: ${YELLOW}https://wa.${DOMAIN}${NC}"
echo ""
echo -e "${YELLOW}Useful commands:${NC}"
echo "  View logs:        docker compose logs -f"
echo "  Restart services: docker compose restart"
echo "  Stop services:    docker compose down"
echo "  Update services:  docker compose pull && docker compose up -d"
echo ""
echo -e "${GREEN}SSL certificates will auto-renew every 12 hours.${NC}"
echo ""
