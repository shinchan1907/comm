# Pre-Flight Checklist

Complete this checklist BEFORE running the setup script.

## ☁️ Cloudflare Configuration

- [ ] Domain `bytenex.io` is added to Cloudflare
- [ ] DNS Record: `n8n.bytenex.io` → Your Server IP (Orange Cloud ☁️)
- [ ] DNS Record: `wa.bytenex.io` → Your Server IP (Orange Cloud ☁️)
- [ ] SSL/TLS Mode: Set to **"Full"** or **"Full (strict)"**
- [ ] Always Use HTTPS: **Enabled**
- [ ] Automatic HTTPS Rewrites: **Enabled**

## 🖥️ Server Configuration

- [ ] Ubuntu server is running (Lightsail instance)
- [ ] You have SSH access to the server
- [ ] Server IP: `___________________`
- [ ] Port 80 is open (HTTP)
- [ ] Port 443 is open (HTTPS)
- [ ] At least 2GB RAM available
- [ ] At least 10GB disk space available

## 📁 Files Uploaded

- [ ] All files uploaded to `/opt/cloud_docker/` on server
- [ ] Files include:
  - [ ] `docker-compose.yml`
  - [ ] `.env.example`
  - [ ] `setup.sh`
  - [ ] `nginx/conf.d/n8n.conf`
  - [ ] `nginx/conf.d/receevi.conf`

## ⚙️ Configuration

- [ ] Copied `.env.example` to `.env`
- [ ] Set `SSL_EMAIL` to your email: `___________________`
- [ ] Generated `N8N_ENCRYPTION_KEY` using: `openssl rand -base64 32`
- [ ] Pasted encryption key in `.env` file
- [ ] Verified domain is `bytenex.io` in `.env`

## 🔐 Security

- [ ] Strong encryption key generated (32+ characters)
- [ ] Email for SSL is valid and accessible
- [ ] Server firewall allows ports 80 and 443
- [ ] SSH key authentication enabled (recommended)

## 🧪 Pre-Deployment Tests

Run these commands on your server:

```bash
# Test DNS resolution
nslookup n8n.bytenex.io
nslookup wa.bytenex.io

# Check if ports are available
sudo netstat -tulpn | grep -E ':(80|443)'
# (Should show nothing if ports are free)

# Verify you can reach the internet
ping -c 3 google.com

# Check disk space
df -h

# Check memory
free -h
```

## ✅ Ready to Deploy?

If all items are checked, you're ready to run:

```bash
sudo ./setup.sh
```

## 📋 Post-Deployment Verification

After running setup, verify:

- [ ] All containers are running: `docker compose ps`
- [ ] n8n is accessible: `https://n8n.bytenex.io`
- [ ] Receevi is accessible: `https://wa.bytenex.io`
- [ ] SSL certificates are valid (green padlock in browser)
- [ ] No errors in logs: `docker compose logs`

## 🎯 First Steps After Deployment

1. **Setup n8n**:
   - Visit `https://n8n.bytenex.io`
   - Create admin account
   - Secure with strong password

2. **Setup Receevi**:
   - Visit `https://wa.bytenex.io`
   - Scan QR code with WhatsApp
   - Verify connection

3. **Create Backup**:
   ```bash
   docker run --rm \
     -v cloud_docker_n8n_data:/n8n \
     -v cloud_docker_receevi_data:/receevi \
     -v $(pwd):/backup \
     ubuntu tar czf /backup/initial-backup.tar.gz /n8n /receevi
   ```

## 🆘 If Something Goes Wrong

1. Check logs: `docker compose logs -f`
2. Run troubleshoot: `./troubleshoot.sh`
3. Restart services: `docker compose restart`
4. Check this checklist again for missed steps

---

**Date Completed**: ___________________

**Deployed By**: ___________________

**Server IP**: ___________________

**Notes**: 
___________________________________________
___________________________________________
___________________________________________
