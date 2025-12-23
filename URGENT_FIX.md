# 🚨 URGENT: Deployment Fix Instructions

## What Happened

Your deployment failed because:
1. ❌ Wrong Docker image for Receevi (`receevi/receevi` doesn't exist)
2. ✅ **I've fixed this** → Changed to `ghcr.io/receevi/receevi:latest`

## 🔥 Quick Fix (Do This Now)

### Step 1: Update Your Files

Since you cloned from GitHub (`comm` repo), you need to:

**OPTION A: If you can push to the GitHub repo**
```bash
# On your local machine (Windows)
# I've already updated the files in g:\cloud_docker
# You need to commit and push them

cd g:\cloud_docker
git add .
git commit -m "Fix: Use correct Receevi image and remove deprecated version"
git push
```

Then on your server:
```bash
cd ~/comm
git pull
```

**OPTION B: Manual update on server (Faster)**
```bash
# On your server
cd ~/comm

# Update docker-compose.yml
nano docker-compose.yml
```

Make these changes:
1. **Line 1-2**: DELETE these lines:
   ```yaml
   version: '3.8'
   
   ```

2. **Line 59** (now line 57): Change from:
   ```yaml
   image: receevi/receevi:latest
   ```
   To:
   ```yaml
   image: ghcr.io/receevi/receevi:latest
   ```

Save and exit (Ctrl+X, Y, Enter)

### Step 2: Run the Fix

```bash
cd ~/comm

# Stop current containers
docker compose down

# Pull correct images
docker compose pull

# Verify .env is configured
cat .env
# Should show your email and encryption key

# Run the fixed setup
sudo ./setup.sh
```

---

## 📋 Before Running Setup Again

### ✅ Critical Checks

1. **DNS Must Be Working**
   ```bash
   nslookup n8n.bytenex.io
   nslookup wa.bytenex.io
   ```
   Both should return your server IP!

2. **Cloudflare SSL Mode**
   - Go to Cloudflare → SSL/TLS
   - Set to **"Full"** (not Flexible)

3. **Ports Are Open**
   ```bash
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   ```

4. **.env File Is Configured**
   ```bash
   cat .env
   ```
   Should show:
   - Your real email (not `your-email@example.com`)
   - Your encryption key (not `CHANGE_THIS_TO_RANDOM_STRING`)

---

## 🎯 Expected Output

When you run `sudo ./setup.sh` again, you should see:

```
[1/8] Updating system packages... ✓
[2/8] Docker already installed ✓
[3/8] Docker Compose already installed ✓
[4/8] Creating directories... ✓
[5/8] Setting permissions... ✓
[6/8] Starting Nginx for certificate generation... ✓
[7/8] Generating SSL certificates...
      Requesting certificate for n8n.bytenex.io... ✓
      Requesting certificate for wa.bytenex.io... ✓
[8/8] Starting all services... ✓
```

Then:
```
Service Status
NAME          IMAGE                              STATUS
certbot       certbot/certbot                    Up
n8n           n8nio/n8n:latest                   Up (healthy)
nginx-proxy   nginx:alpine                       Up
receevi       ghcr.io/receevi/receevi:latest     Up
```

---

## 🆘 If SSL Generation Still Fails

This means DNS isn't pointing correctly. Do this:

### Test DNS from Server
```bash
# Should return your server IP
dig n8n.bytenex.io +short
dig wa.bytenex.io +short
```

### Test DNS from Internet
Go to: https://dnschecker.org
- Enter: `n8n.bytenex.io`
- Should show your server IP globally

### If DNS is wrong:
1. Go to Cloudflare → DNS
2. Verify records:
   - Type: `A`, Name: `n8n`, Content: `YOUR_SERVER_IP`, Proxy: `ON` (🟠)
   - Type: `A`, Name: `wa`, Content: `YOUR_SERVER_IP`, Proxy: `ON` (🟠)
3. Wait 5 minutes
4. Try setup again

---

## 📞 Quick Commands Reference

```bash
# Check what's running
docker compose ps

# View logs
docker compose logs -f

# Restart everything
docker compose restart

# Stop everything
docker compose down

# Start everything
docker compose up -d

# Check SSL certificates
sudo ls -la certbot/conf/live/
```

---

## ✅ Success Checklist

Your deployment is successful when:
- [ ] `docker compose ps` shows all containers "Up"
- [ ] https://n8n.bytenex.io loads (shows n8n setup page)
- [ ] https://wa.bytenex.io loads (shows Receevi)
- [ ] Both have green padlock 🔒 in browser
- [ ] No errors in `docker compose logs`

---

## 🎉 After Successful Deployment

1. **Setup n8n**
   - Go to: https://n8n.bytenex.io
   - Create admin account
   - Set strong password

2. **Setup Receevi**
   - Go to: https://wa.bytenex.io
   - Scan QR code with WhatsApp
   - Verify connection

3. **Create Backup**
   ```bash
   docker run --rm \
     -v comm_n8n_data:/n8n \
     -v comm_receevi_data:/receevi \
     -v $(pwd):/backup \
     ubuntu tar czf /backup/backup-$(date +%Y%m%d).tar.gz /n8n /receevi
   ```

---

## 📝 Files I've Fixed

In `g:\cloud_docker\`:
- ✅ `docker-compose.yml` - Fixed Receevi image, removed version
- ✅ `setup.sh` - Better error handling
- ✅ `fix-deployment.sh` - NEW: Quick fix script
- ✅ `FIX_GUIDE.md` - NEW: Detailed troubleshooting

You need to get these to your server (via git push/pull or manual edit).

---

**TL;DR:**
1. Update `docker-compose.yml` line 59: `ghcr.io/receevi/receevi:latest`
2. Delete lines 1-2 (version field)
3. Run: `sudo ./setup.sh`
4. Access: https://n8n.bytenex.io & https://wa.bytenex.io

Good luck! 🚀
