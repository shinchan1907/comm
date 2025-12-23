# 🔧 DEPLOYMENT FIX GUIDE

## Issues Found

From your deployment attempt, I identified these issues:

1. ❌ **Wrong Receevi Docker image** - `receevi/receevi` doesn't exist
   - ✅ **Fixed**: Changed to `ghcr.io/receevi/receevi:latest`

2. ❌ **Obsolete docker-compose version field** - Causing warnings
   - ✅ **Fixed**: Removed deprecated `version: '3.8'`

3. ⚠️ **SSL certificate generation incomplete** - Services didn't start

## 🚀 Quick Fix (Run on Your Server)

You have **TWO OPTIONS**:

---

### **OPTION 1: Use the Fix Script (Recommended)**

```bash
# On your server (in ~/comm directory)
cd ~/comm

# Pull the latest files from your repo
git pull

# Make the fix script executable
chmod +x fix-deployment.sh

# Run the fix
sudo ./fix-deployment.sh
```

This will:
- Stop existing containers
- Pull correct images
- Generate SSL certificates properly
- Start all services

---

### **OPTION 2: Manual Fix**

```bash
# On your server (in ~/comm directory)
cd ~/comm

# Pull latest changes
git pull

# Stop and remove existing containers
docker compose down

# Pull the correct images
docker compose pull

# Verify .env is configured
cat .env

# Create temporary nginx config for SSL
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

# Start nginx only
docker compose up -d nginx
sleep 5

# Generate SSL for n8n
docker compose run --rm certbot certonly --webroot \
    --webroot-path=/var/www/certbot \
    --email YOUR_EMAIL@example.com \
    --agree-tos \
    --no-eff-email \
    --force-renewal \
    -d n8n.bytenex.io

# Generate SSL for Receevi
docker compose run --rm certbot certonly --webroot \
    --webroot-path=/var/www/certbot \
    --email YOUR_EMAIL@example.com \
    --agree-tos \
    --no-eff-email \
    --force-renewal \
    -d wa.bytenex.io

# Remove temp config
rm nginx/conf.d/temp.conf

# Start all services
docker compose down
docker compose up -d
```

---

## 📋 Pre-Flight Checklist

Before running the fix, verify:

### ✅ DNS Configuration (CRITICAL!)

Check that your DNS is properly configured:

```bash
# On your server, test DNS resolution
nslookup n8n.bytenex.io
nslookup wa.bytenex.io
```

Both should return your server's IP address.

### ✅ Cloudflare Settings

1. Go to Cloudflare Dashboard → DNS
2. Verify both records exist:
   - `n8n` → Your Server IP (🟠 Proxied - Orange Cloud)
   - `wa` → Your Server IP (🟠 Proxied - Orange Cloud)

3. Go to SSL/TLS → Overview
   - Set to **"Full"** (not "Flexible", not "Full (strict)" yet)

### ✅ Firewall/Ports

```bash
# Check if ports are open
sudo ufw status

# If firewall is active, allow ports
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

### ✅ Environment File

```bash
# Verify .env is configured
cat .env

# Should show:
# - SSL_EMAIL with your real email
# - N8N_ENCRYPTION_KEY with the key you generated
```

---

## 🔍 Troubleshooting SSL Certificate Issues

If SSL generation fails, it's usually because:

### Issue 1: DNS Not Propagated
```bash
# Test from your server
dig n8n.bytenex.io
dig wa.bytenex.io

# Should show your server IP
```

**Solution**: Wait 5-10 minutes for DNS to propagate

### Issue 2: Port 80 Not Accessible
```bash
# Test if nginx is listening
sudo netstat -tulpn | grep :80

# Test from outside (use your phone or another computer)
curl http://YOUR_SERVER_IP
```

**Solution**: Check firewall and Lightsail networking settings

### Issue 3: Cloudflare SSL Mode Wrong
- Go to Cloudflare → SSL/TLS → Overview
- Change to **"Full"** mode (not Flexible)

### Issue 4: Rate Limiting
Let's Encrypt has rate limits. If you've tried many times:

**Solution**: Wait 1 hour, or use staging certificates for testing:

```bash
# Add --staging flag for testing
docker compose run --rm certbot certonly --webroot \
    --webroot-path=/var/www/certbot \
    --email YOUR_EMAIL \
    --agree-tos \
    --no-eff-email \
    --staging \
    -d n8n.bytenex.io
```

---

## ✅ Verification Steps

After running the fix:

### 1. Check Container Status
```bash
docker compose ps
```

All containers should show "Up" status:
- ✅ nginx-proxy
- ✅ n8n
- ✅ receevi
- ✅ certbot

### 2. Check Logs
```bash
# Check for errors
docker compose logs

# Check specific service
docker compose logs n8n
docker compose logs receevi
docker compose logs nginx
```

### 3. Verify SSL Certificates
```bash
# List generated certificates
sudo ls -la certbot/conf/live/

# Should show:
# - n8n.bytenex.io/
# - wa.bytenex.io/
```

### 4. Test Access
```bash
# Test from server
curl -I https://n8n.bytenex.io
curl -I https://wa.bytenex.io

# Should return 200 OK or redirect
```

### 5. Browser Test
- Open: https://n8n.bytenex.io (should show n8n setup)
- Open: https://wa.bytenex.io (should show Receevi)
- Both should have 🔒 green padlock

---

## 🎯 Expected Results

After successful fix:

```bash
docker compose ps
```

Should show:
```
NAME          IMAGE                              STATUS
certbot       certbot/certbot                    Up
n8n           n8nio/n8n:latest                   Up (healthy)
nginx-proxy   nginx:alpine                       Up
receevi       ghcr.io/receevi/receevi:latest     Up (healthy)
```

---

## 🆘 Still Having Issues?

### Get Detailed Diagnostics
```bash
# Run troubleshoot script
./troubleshoot.sh

# Check nginx config
docker compose exec nginx nginx -t

# Check certificate details
docker compose run --rm certbot certificates
```

### Common Fixes

**Containers keep restarting?**
```bash
docker compose logs -f [container-name]
# Look for error messages
```

**Nginx config error?**
```bash
# Test nginx config
docker compose exec nginx nginx -t

# If error, check the conf files
cat nginx/conf.d/n8n.conf
cat nginx/conf.d/receevi.conf
```

**Can't pull Receevi image?**
```bash
# Try pulling manually
docker pull ghcr.io/receevi/receevi:latest

# If it fails, check GitHub Container Registry status
```

---

## 📝 Summary of Changes Made

1. **docker-compose.yml**:
   - Removed `version: '3.8'` (deprecated)
   - Changed `receevi/receevi:latest` → `ghcr.io/receevi/receevi:latest`

2. **setup.sh**:
   - Added better error handling for SSL generation
   - Added `--force-renewal` flag

3. **New file: fix-deployment.sh**:
   - Quick fix script to resolve current issues

---

## 🚀 Next Steps After Fix

1. ✅ Verify all services are running
2. 🔐 Setup n8n admin account at https://n8n.bytenex.io
3. 📱 Connect WhatsApp in Receevi at https://wa.bytenex.io
4. 💾 Create initial backup
5. 🎉 Start building workflows!

---

**Need immediate help?** Run these commands and share the output:

```bash
docker compose ps
docker compose logs --tail=50
ls -la certbot/conf/live/
cat .env
```
