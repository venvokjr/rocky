# Codenerg Autoscript VPN

> **Version:** `0.2.0-beta` — see [CHANGELOG.md](CHANGELOG.md)  
> **Status:** Commercial Software (Berbayar) — Sold Exclusively as Source Code (Hanya Dijual Versi Source Code)  
> **Target OS:** Rocky Linux 9 (x86_64)  
> **Repository:** [github.com/codenerg/autoscript](https://github.com/venvokjr/roky)

---

## 📢 Commercial License & Notice (Berbayar)

**Codenerg Autoscript VPN** adalah perangkat lunak komersial (berbayar) dan **hanya dijual dalam bentuk versi Source Code**. 

- 🔒 **Tidak Gratis**: Tidak ada versi gratis atau versi open-source publik.
- 📦 **Versi Source Code**: Pembeli mendapatkan akses penuh ke seluruh source code (Shell Script, Go API server, & modul sistem) untuk kemudahan custom dan self-hosting.
- 🚫 **Dilarang Menjual Kembali**: Dilarang mendistribusikan ulang, menjual kembali, atau membagikan source code tanpa izin tertulis dari **Codenerg**.

---

## 🚀 Fitur Utama

- **Multi-Protocol VPN & Tunneling**:
  - **SSH**: OpenSSH + Dropbear + SSH-over-WebSocket (`GO-TUNNEL PRO`)
  - **Xray-core**: VLESS, VMESS, & Trojan via WebSocket (TLS & non-TLS)
  - **OpenVPN**: TCP (Port 1194) dengan auto-generated & verified certificates
- **Front-end & Multipath Routing**:
  - **HAProxy + Nginx**: Single-port TLS (443) & HTTP (80) multiplexing
  - Path-based & WebSocket handshake inspection (VMESS & SSH-WS share root path `/`)
- **Database & Account Management**:
  - SQLite backend (`/etc/xray/xray.db`) dalam mode WAL dengan *soft-delete* & audit log
  - Per-account quota & IP limit enforcement secara otomatis
  - Live login monitor untuk SSH, VLESS, VMESS, & Trojan
- **Security & System Hardening**:
  - Strict Firewall allowlist & hardened systemd services
  - Response header guard (`return 444`) untuk menyembunyikan server dari ISP/port scanner
  - Backup & restore terenkripsi dengan notifikasi Telegram (Rich HTML format)
- **Auto-tuning Resource**:
  - Deteksi RAM/CPU otomatis untuk tuning Nginx, HAProxy, TCP buffer, file descriptors, dan Swap (optimal dari VPS 1 GB RAM hingga dedicated server)
- **UI Terminal Dynamic**:
  - Tampilan menu ASCII yang rapi dan responsif pada mobile terminal (Termux / PuTTY)

---

## ⚡ Auto-Tuning Matrix

Installer secara otomatis mendeteksi spesifikasi server dan menerapkan optimasi berikut:

| RAM Tier | Nginx Conn/Worker | HAProxy Maxconn | TCP Buffers | Swap Size | Swappiness |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **≤ 1 GB** | 4,096 | 8,192 | 16 MB | 2 GB | 60 |
| **≤ 2 GB** | 16,384 | 32,768 | 32 MB | 2 GB | 15 |
| **≤ 4 GB** | 65,535 | 100,000 | 64 MB | 4 GB | 15 |
| **> 4 GB** | 131,072 | 200,000 | 128 MB | 4 GB | 15 |

---

## 🔌 Pemetaan Port (Port Mapping)

| Layanan | Port | Keterangan |
| :--- | :---: | :--- |
| **OpenSSH** | `22`, `3303` | SSH Management |
| **Dropbear** | `109` | Direct SSH |
| **HTTP** | `80` | HAProxy → Nginx |
| **HTTPS / TLS** | `443` | HAProxy → Nginx → Xray / SSH-WS |
| **BadVPN / UDPGW** | `7300/udp` | Handled by SSH-WS |
| **OpenVPN** | `1194/tcp` | OpenVPN Profile |

*Port Internal (Internal Only / Localhost `127.0.0.1`):*  
Xray API (`10085`), Nginx (`81`/`444`), SSH-WS Proxy (`8888`), SSH-WS API (`8081`), RESTful API Server (`9000`).

---

## 📋 Persyaratan System

- **OS**: Rocky Linux 9 (x86_64)
- **Akses**: Root privileges
- **Domain**: Subdomain / Domain yang sudah diarahkan (A record) ke IP Server

---

## 📥 Panduan Instalasi (Source Code Installation)

Jalankan perintah berikut pada terminal server Rocky Linux 9 Anda:

```shell
dnf install epel-release -y ; dnf update -y ; dnf install wget curl openssl screen -y ; mkdir -p /run/screen ; chmod 777 /run/screen ; wget -q https://raw.githubusercontent.com/venvokjr/rocky/main/install.sh ; chmod +x install.sh ; screen -S autoscript ./install.sh ; if [ $? -ne 0 ]; then rm -f install.sh; fi
```

> 💡 **Tips:** Jika sesi SSH Anda terputus saat instalasi, buka kembali terminal dan jalankan:
> ```shell
> screen -r autoscript
> ```

---

## 🎛️ Pengelolaan Sistem (Management Menu)

Buka menu utama manajemen dengan menjalankan perintah:

```shell
menu
```

### Struktur Menu Utama

```text
Main Menu (Codenerg Autoscript)
├── 1) SSH / OpenVPN     (Create, Trial, Delete, Renew, List, Config, Recovery, Check Login)
├── 2) VLESS             (Create, Trial, Delete, Renew, List, Config, Recovery, Quota, IP Limit)
├── 3) VMESS             (Create, Trial, Delete, Renew, List, Config, Recovery, Quota, IP Limit)
├── 4) TROJAN            (Create, Trial, Delete, Renew, List, Config, Recovery, Quota, IP Limit)
├── 5) Auto Bulk Create  (Pembuatan akun massal secara otomatis)
├── 6) Account Cleaner   (Pembersihan akun kadaluarsa)
├── 7) User Checker      (Pemeriksaan pengguna aktif semua protokol)
├── 8) API Menu          (Pengaturan & Manajemen Token API)
├── 9) System Menu       (Domain/SSL, DNS, Speedtest, Status Service, Telegram Setup)
└── 10) Backup / Restore (Pencadangan & Pemulihan data terenkripsi)
```

Perintah cepat CLI yang didukung langsung: `add-ssh`, `add-vless`, `add-vmess`, `add-trojan`, `cek-user`, `status`, `set-telegram`, `backup`, `restore`, `uninstall`.

---

## 🔀 Alur Routing Permintaan (Request Routing)

Sistem menggunakan alur multiplexing canggih pada port `443` dan `80`:

| Path Permintaan | Ditujukan Ke | Keterangan |
| :--- | :--- | :--- |
| `/vless` | Xray VLESS inbound (`127.0.0.1:1`) | VLESS WebSocket |
| `/trojan` | Xray Trojan inbound (`127.0.0.1:2`) | Trojan WebSocket |
| `/ssh` | SSH-WS Proxy (`127.0.0.1:8888`) | SSH Payload WebSocket |
| `/` *(dengan header `Sec-WebSocket-Key`)* | Xray VMESS inbound (`127.0.0.1:3`) | VMESS WebSocket Multipath |
| `/` *(tanpa header WebSocket)* | SSH-WS Proxy (`127.0.0.1:8888`) | Default SSH Payload |

---

## 📁 Struktur Project Source Code

```text
autoscript/
├── install.sh              # Main Installer (Rocky Linux 9)
├── install-api.sh          # Standalone API Installer
├── uninstall.sh            # Complete Uninstaller Script
├── LICENSE                 # Commercial Source Code License Agreement
├── README.md               # Dokumentasi Utama Projek
├── FIX-GUIDE.md            # Panduan Hardening ISP Scanner
├── CHANGELOG.md            # Catatan Perubahan Versi
├── docs/
│   └── API.md              # Dokumentasi RESTful Web API Reference
├── files/                  # Source Code RESTful API Server (Go)
└── scripts/
    ├── lib/                # Shared Libraries (common, db, xraycfg, account)
    ├── menu/               # Script Modul Menu Interactive
    ├── ssh/                # Modul Manajemen SSH / OpenVPN
    ├── vless/              # Modul Manajemen VLESS
    ├── vmess/              # Modul Manajemen VMESS
    ├── trojan/             # Modul Manajemen Trojan
    ├── system/             # Backup, Restore, Status, Migration, Telegram
    └── api/                # Command Handlers untuk REST API
```

---

## 📡 RESTful API Reference

Sistem dilengkapi dengan Web API handler JSON untuk integrasi dengan panel eksternal atau bot otomatisasi. Untuk dokumentasi lengkap endpoint API, silakan baca [docs/API.md](docs/API.md).

---

## 🗑️ Uninstall System

Untuk menghapus seluruh instalasi autoscript dari VPS:

```shell
uninstall
```

Script akan menghapus seluruh konfigurasi, service systemd, database SQLite, user SSH yang dibuat, serta mengembalikan aturan firewall dengan aman tanpa mengunci port SSH utama (`22`).

---

## 📜 Lisensi & Syarat Pembelian

Copyright (c) 2025-2026 **Codenerg**. All Rights Reserved.  
Perangkat lunak ini dilindungi oleh lisensi komersial **Source Code Only License**. Lihat file [LICENSE](LICENSE) untuk informasi lebih detail.
