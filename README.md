# 🎯 IP Hunter Pro

**Auto IP Switcher untuk OpenWrt dengan ADB ke Android**

[![Version](https://img.shields.io/badge/version-2.0-blue)](https://github.com/arewedaks/luci-iphunter-droid)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![OpenWrt](https://img.shields.io/badge/OpenWrt-18.06+-orange)](https://openwrt.org/)
[![Shell](https://img.shields.io/badge/Shell-sh-brightgreen)](https://www.shellcheck.net/)

```
 ___ _  _ ___ _  _____ _  ___ ___    _  _  ___ ___ ___ ___ _  _ ___ ___ ___ ___ ___ ___
/ __| || | __| |/ / _ | |/ __| __|  | || |/ __| __| __| _ \| || | __| __| __| __| __| __|
| (__| __ | _|| '<  __/| | (_ | _|   | __ | (_ | _|| _||   /| __ | _|| _|| _|| _|| _|| _|
\___|_||_|___|_|\_\___|_|\___|___|   |_||_|\___|___|___|_|_\|_||_|___|___|___|___|___|___|
```

---

## 📋 Daftar Isi

- [Deskripsi](#deskripsi)
- [Fitur](#fitur)
- [Persyaratan](#persyaratan)
- [Instalasi](#instalasi)
- [Penggunaan](#penggunaan)
- [File Struktur](#file-struktur)
- [Konfigurasi](#konfigurasi)
- [Troubleshooting](#troubleshooting)
- [FAQ](#faq)

---

## 🎯 Deskripsi

**IP Hunter Pro** adalah tools auto IP switcher yang berjalan di **OpenWrt Router** dan terhubung ke **Android Device** melalui **ADB (Android Debug Bridge)**. Tools ini secara otomatis mencari dan mengganti IP publik ketika koneksi tidak stabil atau mati.

### Alur Kerja

```
┌─────────────────────────────────────────────────────────────────┐
│                     IP HUNTER WORKFLOW                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. SCAN IP        → Cek IP publik saat ini                    │
│         ↓                                                       │
│  2. CHECK RANGE    → Apakah IP sesuai range target?             │
│         ↓                 ↓                                     │
│  3. MATCH ❌       → Jika tidak, trigger airplane mode          │
│     MATCH ✅       → Jika iya, test koneksi                     │
│         ↓                                                       │
│  4. TEST KONEKSI   → Ping ke Google/GCP endpoints              │
│         ↓                                                       │
│  5. MONITORING     → Jika online, monitor terus                 │
│         ↓                                                       │
│  6. LOST CONNECTION → Jika offline, switch IP                   │
│         ↓                                                       │
│  7. AIRPLANE MODE  → Toggle airplane mode → IP baru             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## ✨ Fitur

| Fitur | Deskripsi |
|-------|-----------|
| 🎯 **Auto IP Hunt** | Scanning otomatis IP publik target |
| ✈️ **Airplane Mode** | Reset radio via ADB untuk dapetin IP baru |
| 🌐 **Connection Check** | Multiple endpoint check (Google, Cloudflare) |
| 📊 **Live Dashboard** | Web UI real-time monitoring |
| ⏱️ **Auto Retry** | Retry 5x sebelum switch IP |
| 💾 **Configurable** | Custom IP range sesuai kebutuhan |
| 🔄 **Service Control** | Start/Stop/Restart via init script |
| 📝 **Logging** | Real-time log dengan timestamp |

---

## 📦 Persyaratan

### Hardware
- **Router:** OpenWrt based router
- **Android Device:** HP/laptop dengan ADB server
- **Koneksi:** SSH ke router + ADB ke Android

### Software
- OpenWrt 18.06+
- curl
- adb (di Android device)
- LuCI (untuk Web UI)

### Android Requirements
- USB Debugging enabled
- ADB server running di port 5037
- Rooted (untuk beberapa fitur airplane mode)

---

## 🚀 Instalasi

### ⚡ Quick Install (One-Line)

```bash
# Ganti arewedaks dengan username GitHub kamu
curl -sL https://raw.githubusercontent.com/arewedaks/luci-iphunter-droid/main/install.sh | sh -s -- --github arewedaks/luci-iphunter-droid
```

**Contoh:**
```bash
curl -sL https://raw.githubusercontent.com/arewedaks/luci-iphunter-droid/main/install.sh | sh -s -- --github arewedaks/luci-iphunter-droid
```

#### Atau dengan clone manual:

```bash
# Clone repository
git clone https://github.com/arewedaks/luci-iphunter-droid.git
cd luci-iphunter-droid

# Install
chmod +x install.sh && ./install.sh
```

### Cara 1: Manual Install

```bash
# 1. Clone/Download file ke router
# 2. Set permissions
chmod +x install.sh
chmod +x iphunter
chmod +x iphunter-core
chmod +x iphunter-ctl

# 3. Run installer
./install.sh

# 4. Atau manual copy
cp iphunter /etc/init.d/iphunter
cp iphunter-core /etc/init.d/iphunter-core
cp iphunter.lua /usr/lib/lua/luci/controller/iphunter.lua
cp iphunter_view.htm /usr/lib/lua/luci/view/iphunter_view.htm
cp iphunter-ctl /usr/bin/iphunter-ctl

# 5. Set permissions & enable
chmod +x /etc/init.d/iphunter
chmod +x /etc/init.d/iphunter-core
chmod +x /usr/bin/iphunter-ctl
/etc/init.d/iphunter enable
```

### Cara 2: Via SCP

```bash
# Dari komputer lokal
scp iphunter iphunter-core iphunter-ctl iphunter.lua iphunter_view.htm root@192.168.1.1:/tmp/

# SSH ke router
ssh root@192.168.1.1

# Install
cd /tmp
chmod +x install.sh && ./install.sh
```

### Cara 3: Via LuCI Upload

1. Upload semua file ke `/tmp`
2. SSH ke router
3. Jalankan `install.sh`

---

## 📖 Penggunaan

### Command Line

```bash
# Start service
/etc/init.d/iphunter start

# Stop service
/etc/init.d/iphunter stop

# Restart service
/etc/init.d/iphunter restart

# Check status
/etc/init.d/iphunter status

# Enable auto-start
/etc/init.d/iphunter enable

# Disable auto-start
/etc/init.d/iphunter disable

# View log
iphunter-ctl log

# Stop via script
iphunter-ctl stop

# Start via script
iphunter-ctl start
```

### Web Interface

1. Buka browser: `http://<router-ip>/cgi-bin/luci/admin/status/iphunter`
2. Atur IP range target
3. Klik START untuk mulai hunting
4. Monitor via console real-time

### Set IP Range

```
Format: <min>-<max> [spasi] <min>-<max>

Contoh:
- 0-9 130-159     → Octet2 0-9 atau 130-159
- 0-20 100-159    → Octet2 0-20 atau 100-159
- 10-15 50-80     → Octet2 10-15 atau 50-80
```

---

## 📁 File Struktur

```
iphunter-project/
├── iphunter           # Init script (OpenWrt procd)
├── iphunter-core      # Main monitoring script
├── iphunter-ctl       # Control utility script
├── iphunter.lua       # LuCI controller (Web API)
├── iphunter_view.htm  # Web UI (HTML/CSS/JS)
├── install.sh         # Installer script
└── README.md          # Dokumentasi
```

### Deskripsi File

| File | Fungsi | Lokasi |
|------|--------|--------|
| `iphunter` | Init script service | `/etc/init.d/iphunter` |
| `iphunter-core` | Core monitoring logic | `/etc/init.d/iphunter-core` |
| `iphunter-ctl` | CLI control tool | `/usr/bin/iphunter-ctl` |
| `iphunter.lua` | LuCI API controller | `/usr/lib/lua/luci/controller/` |
| `iphunter_view.htm` | Web UI template | `/usr/lib/lua/luci/view/` |
| `ip_hunter.log` | Log file | `/tmp/ip_hunter.log` |
| `ip_hunter_range.conf` | IP range config | `/tmp/ip_hunter_range.conf` |

---

## ⚙️ Konfigurasi

### Konfigurasi IP Range

```bash
# Via CLI
echo "0-9 130-159" > /tmp/ip_hunter_range.conf

# Via Web UI
# Masukkan di kolom "IP Range" → SAVE
```

### Konfigurasi Script (iphunter-core)

Edit file `iphunter-core` untuk ubah:

```bash
# Log file
LOG_FILE="/tmp/ip_hunter.log"

# Config file
CONFIG_FILE="/tmp/ip_hunter_range.conf"

# Default range
DEFAULT_RANGE="0-9 130-159"

# Check endpoints (comma separated)
ENDPOINTS="http://www.gstatic.com/generate_204 http://connectivitycheck.gstatic.com/generate_204 http://cp.cloudflare.com/"

# Required online (majority vote)
REQUIRED_ONLINE=2

# Sleep sebelum trigger
sleep 15  # Line 121
```

### ADB Configuration

Pastikan ADB server berjalan di Android:

```bash
# Di Android device (termux/adb server)
adb start-server

# Cek apakah device connected
adb devices

# Test command
adb shell "ip addr"
```

---

## 🔧 Troubleshooting

### Service tidak start

```bash
# Cek apakah procd installed
opkg list-installed | grep procd

# Cek log error
logread | grep iphunter

# Cek apakah file executable
ls -la /etc/init.d/iphunter*
```

### ADB connection failed

```bash
# Test ADB connection
adb connect <android-ip>:5037
adb shell "echo OK"

# Cek ADB server
adb devices

# Restart ADB server
adb kill-server
adb start-server
```

### Web UI tidak muncul

```bash
# Cek file exists
ls -la /usr/lib/lua/luci/controller/iphunter.lua
ls -la /usr/lib/lua/luci/view/iphunter_view.htm

# Clear LuCI cache
rm -rf /tmp/luci-*

# Restart uhttpd
/etc/init.d/uhttpd restart
```

### IP tidak switching

```bash
# Cek log
cat /tmp/ip_hunter.log

# Cek IP range config
cat /tmp/ip_hunter_range.conf

# Test manual trigger
adb shell "cmd connectivity airplane-mode enable"
sleep 3
adb shell "cmd connectivity airplane-mode disable"
```

---

## ❓ FAQ

### Q: Perbedaan iphunter dan iphunter-core?

**A:**
- `iphunter` = Init script untuk OpenWrt service manager (procd)
- `iphunter-core` = Main script yang jalankan logic monitoring

### Q: Kenapa butuh Android?

**A:** Script menggunakan ADB untuk:
1. Baca IP publik dari Android
2. Toggle airplane mode di Android (reset radio)
3. Tidak perlu router flash/modify

### Q: Bagaimana cara setup ADB?

**A:**
```bash
# Di Android (Termux/SSH)
pkg install adb
adb start-server

# Di Router
# Pastikan bisa reach Android IP
ping <android-ip>

# Connect
adb connect <android-ip>:5037
```

### Q: Berapa lama rata-rata dapat IP baru?

**A:** Bergantung carrier, biasanya:
- Toggle airplane: 5-15 detik
- Total waktu: 10-30 detik

### Q: Apakah aman digunakan?

**A:** Ya, tool ini:
- Read-only terhadap router config
- Log-only (tidak modify sistem)
- Manual control tersedia (start/stop)
- Auto-stop saat service dihentikan

### Q: Bagaimana monitoring?

**A:**
```bash
# Real-time log
tail -f /tmp/ip_hunter.log

# Web UI
http://<router-ip>/cgi-bin/luci/admin/status/iphunter

# Stats
iphunter-ctl status
```

---

## 📜 Changelog

### v2.0 (2026)
- Hybrid airplane mode trigger (Android 11+ & legacy)
- Multiple connectivity check endpoints
- Major vote system untuk reliability
- Improved auto-retry logic
- Modern dark UI theme

### v1.0 (2025)
- Initial release
- Basic IP scanning
- Single endpoint check

---

## 📄 License

MIT License - Bebas digunakan, dimodifikasi, dan didistribusikan.

---

## 🙏 Credits

- OpenWrt Project
- LuCI Web Framework
- Android Debug Bridge (ADB)

---

**Made with ❤️ for automation enthusiasts**

```
   ╔═══════════════════════════════╗
   ║     🎯 IP HUNTER PRO v2.0    ║
   ║   Auto IP Switcher for       ║
   ║   OpenWrt + Android ADB      ║
   ╚═══════════════════════════════╝
```
