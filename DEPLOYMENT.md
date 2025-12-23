# Quick Deployment Guide

## 🚀 Deploy to Lightsail in 5 Minutes

### Step 1: Upload to Server

```bash
# On your local machine, upload files to server
scp -r g:/cloud_docker/* ubuntu@YOUR_SERVER_IP:/opt/cloud_docker/
```

Or use SFTP/FileZilla to upload the entire `cloud_docker` folder to `/opt/cloud_docker/`

### Step 2: SSH into Server

```bash
ssh ubuntu@YOUR_SERVER_IP
cd /opt/cloud_docker
```

### Step 3: Configure Environment

```bash
# Copy environment template
cp .env.example .env

# Edit configuration
nano .env
```

**Required changes:**
1. Change `SSL_EMAIL=your-email@example.com` to your actual email
2. Generate encryption key and replace `N8N_ENCRYPTION_KEY`:
   ```bash
   openssl rand -base64 32
   ```
   Copy the output and paste it in `.env`

Save and exit (Ctrl+X, then Y, then Enter)

### Step 4: Run Setup

```bash
# Make scripts executable
chmod +x setup.sh troubleshoot.sh update.sh

# Run setup
sudo ./setup.sh
```

The setup will:
- ✅ Install Docker & Docker Compose
- ✅ Generate SSL certificates
- ✅ Start all services

### Step 5: Access Your Services

After 2-3 minutes:
- **n8n**: https://n8n.bytenex.io
- **Receevi**: https://wa.bytenex.io

---

## ⚙️ Cloudflare Settings (IMPORTANT!)

Make sure these settings are configured in Cloudflare:

1. **DNS Records** (already done ✓):
   - `n8n` → Your Server IP (Orange cloud)
   - `wa` → Your Server IP (Orange cloud)

2. **SSL/TLS Settings**:
   - Go to SSL/TLS → Overview
   - Set encryption mode to **"Full"** or **"Full (strict)"**
   - Enable "Always Use HTTPS"

---

## 📋 Daily Commands

```bash
# View logs
docker compose logs -f

# Restart services
docker compose restart

# Check status
docker compose ps

# Update to latest versions
./update.sh

# Troubleshoot issues
./troubleshoot.sh
```

---

## 🔒 Security Checklist

- ✅ SSL certificates (auto-renewed)
- ✅ HTTPS redirect
- ✅ Security headers
- ✅ Isolated Docker network
- ✅ Health checks
- ✅ Cloudflare proxy protection

---

## 🆘 Troubleshooting

### Services not accessible?
```bash
# Check if containers are running
docker compose ps

# Check logs
docker compose logs -f

# Restart
docker compose restart
```

### SSL certificate issues?
```bash
# Check certificates
sudo ls -la certbot/conf/live/

# Regenerate
sudo ./setup.sh
```

### Port issues?
```bash
# Check if ports are open
sudo netstat -tulpn | grep -E ':(80|443)'

# Or use ss
sudo ss -tulpn | grep -E ':(80|443)'
```

---

## 📊 Backup & Restore

### Backup
```bash
# Backup all data
docker run --rm \
  -v cloud_docker_n8n_data:/n8n \
  -v cloud_docker_receevi_data:/receevi \
  -v $(pwd):/backup \
  ubuntu tar czf /backup/backup-$(date +%Y%m%d).tar.gz /n8n /receevi
```

### Restore
```bash
# Restore from backup
docker run --rm \
  -v cloud_docker_n8n_data:/n8n \
  -v cloud_docker_receevi_data:/receevi \
  -v $(pwd):/backup \
  ubuntu tar xzf /backup/backup-YYYYMMDD.tar.gz -C /
```

---

## 🎯 Next Steps

1. **Configure n8n**: Visit https://n8n.bytenex.io and create your admin account
2. **Setup Receevi**: Visit https://wa.bytenex.io and scan QR code for WhatsApp
3. **Create workflows**: Connect n8n with Receevi for automation

---

**Need help?** Run `./troubleshoot.sh` to diagnose issues.
