# n8n + Receevi Docker Deployment

Simple, reliable, and secure deployment of n8n and Receevi on Ubuntu with Docker, Nginx, and SSL.

## 🚀 Features

- ✅ **n8n** workflow automation at `n8n.bytenex.io`
- ✅ **Receevi** WhatsApp integration at `wa.bytenex.io`
- ✅ **Automatic SSL** certificates via Let's Encrypt
- ✅ **Auto-renewal** of SSL certificates
- ✅ **Nginx reverse proxy** with security headers
- ✅ **Docker Compose** for easy management
- ✅ **Health checks** for all services
- ✅ **Persistent data** volumes

## 📋 Prerequisites

1. **Ubuntu server** (Lightsail instance)
2. **Domain configured** in Cloudflare:
   - `n8n.bytenex.io` → Server IP (Orange cloud ☁️)
   - `wa.bytenex.io` → Server IP (Orange cloud ☁️)
3. **Ports open**: 80 (HTTP) and 443 (HTTPS)

## 🔧 Installation

### Step 1: Upload Files to Server

Upload all files to your server in a directory (e.g., `/opt/cloud_docker`):

```bash
# On your server
mkdir -p /opt/cloud_docker
cd /opt/cloud_docker
```

### Step 2: Configure Environment

```bash
# Copy and edit the environment file
cp .env.example .env
nano .env
```

**Required changes in `.env`:**
- Set `SSL_EMAIL` to your email address
- Generate and set `N8N_ENCRYPTION_KEY`:
  ```bash
  openssl rand -base64 32
  ```

### Step 3: Run Setup

```bash
# Make setup script executable
chmod +x setup.sh

# Run setup (requires sudo)
sudo ./setup.sh
```

The script will:
1. Install Docker and Docker Compose (if needed)
2. Create necessary directories
3. Generate SSL certificates
4. Start all services

## 🌐 Access Your Services

After setup completes:

- **n8n**: https://n8n.bytenex.io
- **Receevi**: https://wa.bytenex.io

## 📊 Management Commands

### View Logs
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f n8n
docker compose logs -f receevi
```

### Restart Services
```bash
# All services
docker compose restart

# Specific service
docker compose restart n8n
```

### Stop Services
```bash
docker compose down
```

### Start Services
```bash
docker compose up -d
```

### Update Services
```bash
docker compose pull
docker compose up -d
```

### Check Status
```bash
docker compose ps
```

## 🔒 Security Features

- **SSL/TLS encryption** with Let's Encrypt
- **Automatic certificate renewal**
- **Security headers** (HSTS, X-Frame-Options, etc.)
- **Isolated Docker network**
- **Health checks** for service monitoring

## 📁 Data Persistence

All data is stored in Docker volumes:
- `n8n_data`: n8n workflows and settings
- `receevi_data`: Receevi configuration
- `receevi_sessions`: WhatsApp session data

### Backup Data
```bash
# Backup n8n data
docker run --rm -v cloud_docker_n8n_data:/data -v $(pwd):/backup ubuntu tar czf /backup/n8n-backup.tar.gz /data

# Backup Receevi data
docker run --rm -v cloud_docker_receevi_data:/data -v $(pwd):/backup ubuntu tar czf /backup/receevi-backup.tar.gz /data
```

### Restore Data
```bash
# Restore n8n data
docker run --rm -v cloud_docker_n8n_data:/data -v $(pwd):/backup ubuntu tar xzf /backup/n8n-backup.tar.gz -C /

# Restore Receevi data
docker run --rm -v cloud_docker_receevi_data:/data -v $(pwd):/backup ubuntu tar xzf /backup/receevi-backup.tar.gz -C /
```

## 🔧 Troubleshooting

### Check if services are running
```bash
docker compose ps
```

### Check logs for errors
```bash
docker compose logs -f
```

### Restart a specific service
```bash
docker compose restart n8n
docker compose restart receevi
```

### Verify SSL certificates
```bash
docker compose exec nginx ls -la /etc/letsencrypt/live/
```

### Test certificate renewal
```bash
docker compose run --rm certbot renew --dry-run
```

### Check Nginx configuration
```bash
docker compose exec nginx nginx -t
```

## 🌐 Cloudflare Settings

**Important**: Make sure your Cloudflare SSL/TLS settings are:
- **SSL/TLS encryption mode**: Full (strict) or Full
- **Always Use HTTPS**: ON
- **Automatic HTTPS Rewrites**: ON

## 📝 Notes

- SSL certificates auto-renew every 12 hours
- Services auto-restart on failure
- All services run on an isolated Docker network
- Nginx acts as a reverse proxy for both services

## 🆘 Support

If you encounter issues:

1. Check service logs: `docker compose logs -f`
2. Verify DNS is pointing to server IP
3. Ensure ports 80 and 443 are open
4. Check Cloudflare SSL settings

## 📄 License

This setup is provided as-is for deployment purposes.
