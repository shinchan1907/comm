#!/bin/bash

# Troubleshooting script for n8n + Receevi deployment

echo "========================================="
echo "  Troubleshooting n8n + Receevi Setup"
echo "========================================="
echo ""

# Check Docker
echo "1. Checking Docker..."
if command -v docker &> /dev/null; then
    echo "   ✓ Docker is installed"
    docker --version
else
    echo "   ✗ Docker is NOT installed"
fi
echo ""

# Check Docker Compose
echo "2. Checking Docker Compose..."
if command -v docker-compose &> /dev/null || docker compose version &> /dev/null; then
    echo "   ✓ Docker Compose is installed"
    docker compose version 2>/dev/null || docker-compose --version
else
    echo "   ✗ Docker Compose is NOT installed"
fi
echo ""

# Check if services are running
echo "3. Checking running containers..."
docker compose ps
echo ""

# Check ports
echo "4. Checking open ports..."
if command -v netstat &> /dev/null; then
    netstat -tulpn | grep -E ':(80|443) '
elif command -v ss &> /dev/null; then
    ss -tulpn | grep -E ':(80|443) '
else
    echo "   Install net-tools to check ports"
fi
echo ""

# Check SSL certificates
echo "5. Checking SSL certificates..."
if [ -d "certbot/conf/live" ]; then
    ls -la certbot/conf/live/
else
    echo "   ✗ No SSL certificates found"
fi
echo ""

# Check logs for errors
echo "6. Recent errors in logs..."
echo "   --- n8n logs ---"
docker compose logs --tail=20 n8n 2>/dev/null | grep -i error || echo "   No errors found"
echo ""
echo "   --- Receevi logs ---"
docker compose logs --tail=20 receevi 2>/dev/null | grep -i error || echo "   No errors found"
echo ""
echo "   --- Nginx logs ---"
docker compose logs --tail=20 nginx 2>/dev/null | grep -i error || echo "   No errors found"
echo ""

# Check DNS resolution
echo "7. Checking DNS resolution..."
if [ -f .env ]; then
    source .env
    echo "   Testing n8n.${DOMAIN}..."
    nslookup n8n.${DOMAIN} 2>/dev/null || host n8n.${DOMAIN} 2>/dev/null || echo "   DNS lookup failed"
    echo "   Testing wa.${DOMAIN}..."
    nslookup wa.${DOMAIN} 2>/dev/null || host wa.${DOMAIN} 2>/dev/null || echo "   DNS lookup failed"
else
    echo "   .env file not found"
fi
echo ""

# Check disk space
echo "8. Checking disk space..."
df -h | grep -E '(Filesystem|/$)'
echo ""

# Check Docker volumes
echo "9. Checking Docker volumes..."
docker volume ls | grep cloud_docker
echo ""

echo "========================================="
echo "  Troubleshooting Complete"
echo "========================================="
echo ""
echo "Common fixes:"
echo "  - Restart services: docker compose restart"
echo "  - View full logs: docker compose logs -f"
echo "  - Regenerate SSL: sudo ./setup.sh"
echo ""
