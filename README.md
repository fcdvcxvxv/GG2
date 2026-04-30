# 🚀 Proxmox Installer (Docker + noVNC)

Run **Proxmox VE installer** inside Docker with a web-based GUI (noVNC).

> ⚠️ This project is for **testing / learning only**. Not recommended for production use.

---

# 📦 Features

* 🌐 Web-based VNC (noVNC)
* ⚙️ Install Proxmox VE via browser
* 🧠 Custom RAM / CPU / Disk
* 💾 Persistent storage
* ⚡ KVM acceleration support (if available)

---

# 🧰 Requirements

Before starting, make sure you have:

* Docker installed
* KVM support (`/dev/kvm`)
* At least:

  * 4GB RAM (8GB recommended)
  * 2 CPU cores
  * 50GB free disk

---

# 📥 Step 1 — Clone Repository

```bash
git clone https://github.com/fcdvcxvxv/GG2.git
cd GG2
```

---

# 🏗️ Step 2 — Build Docker Image

```bash
docker build -t proxmox-installer .
```

---

# ▶️ Step 3 — Run Container

```bash
docker run -d \
  --name proxmox8 \
  --privileged \
  --device /dev/kvm \
  -p 6080:6080 \
  -p 8006:8006 \
  -p 5900:5900 \
  -e RAM=8192 \
  -e CPU=4 \
  -e DISK_SIZE=100G \
  -v proxmox-data:/proxmox8 \
  --restart unless-stopped \
  proxmox-installer
```

---

# 🌐 Step 4 — Open Installer

Open in browser:

```
http://localhost:6080
```

You will see the **Proxmox installer screen**.

---

# ⚙️ Step 5 — Install Proxmox

Inside the VNC screen:

1. Click **Install Proxmox VE**
2. Accept license
3. Select disk (`/dev/sda`)
4. Set:

   * Country
   * Timezone
   * Password
   * Email
5. Configure network (DHCP is fine)
6. Start installation

⏳ Wait ~10–20 minutes

---

# 🔄 Step 6 — Reboot After Install

After installation finishes:

* Click **Reboot**
* If it boots installer again:

  * Stop container
  * Remove ISO OR change boot to disk

---

# 🌐 Step 7 — Access Proxmox Panel

Open:

```
https://localhost:8006
```

Login using credentials you set during install.

---

# ⚙️ Environment Variables

| Variable  | Example | Description |
| --------- | ------- | ----------- |
| RAM       | 8192    | RAM in MB   |
| CPU       | 4       | CPU cores   |
| DISK_SIZE | 100G    | Disk size   |

---

# 💡 Example Configs

### 🔹 Low-end VPS

```bash
-e RAM=2048 -e CPU=2 -e DISK_SIZE=50G
```

### 🔹 Medium Setup

```bash
-e RAM=8192 -e CPU=4 -e DISK_SIZE=100G
```

### 🔹 High Performance

```bash
-e RAM=16384 -e CPU=8 -e DISK_SIZE=200G
```

---

# ⚠️ Important Notes

* First boot = installer mode
* After install, system should boot from disk
* Networking is NAT (not bridged)
* Nested virtualization may not work on all VPS

---

# 🛠️ Troubleshooting

### ❌ KVM not working

Check:

```bash
ls /dev/kvm
```

### ❌ Slow performance

* Enable virtualization in BIOS
* Use dedicated server

### ❌ Can't access panel

* Wait a few minutes after install
* Check port `8006`

---

# 📜 License

MIT
