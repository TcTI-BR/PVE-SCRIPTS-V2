# 🖥️ PVE-SCRIPTS-V2 — Proxmox Management Suite

[🇧🇷 Português](README_pt.md) | [🇪🇸 Español](README_es.md) | [🇨🇳 中文](README_zh.md) | [🇺🇸 English](README.md)

Complete suite of Bash scripts for automation and interactive management of **Proxmox VE** and **Proxmox Backup Server** environments via terminal.

---

## ✨ Overview

Interactive menu interface with single-key navigation, organized into independent modules. Includes an automatic GitHub update system, native Telegram integration for alerts and management, thermal monitoring with hardware protection, and much more.

---

## 🚀 Installation

```bash
mkdir -p /TcTI/SCRIPTS/PROXMOX && cd /TcTI/SCRIPTS/PROXMOX \
  && curl -sL -o main.sh https://raw.githubusercontent.com/TcTI-BR/PVE-SCRIPTS-V2/main/main.sh \
  && chmod +x main.sh && ./main.sh
```

The main script automatically downloads and verifies all modules on the first run.

### Force complete update

```bash
rm /TcTI/SCRIPTS/PROXMOX/.local_version && ./main.sh
```

---

## 📁 Project Structure

```
PVE-SCRIPTS-V2/
├── main.sh                                    # Main script, auto-updater and module loader
├── temp/
│   └── pve_temp_monitor.py                    # Thermal monitoring Python backend
├── functions/
│   ├── pve/                                   # Proxmox Virtual Environment Modules
│   │   ├── menu_pve.sh                        # Main PVE Menu
│   │   ├── menu_update.sh                     # Package Updates
│   │   ├── menu_upgrade.sh                    # Proxmox VE Version Upgrades
│   │   ├── menu_disco.sh                      # Disk Management
│   │   ├── menu_bkp.sh                        # Backup Configurations (NFS/CIFS/Local)
│   │   ├── menu_vm_operations.sh              # VM Operations (migrate, shutdown, etc.)
│   │   ├── menu_migracao_vhd.sh               # Disk Migration (VHD, VHDX, VMDK, VDI)
│   │   ├── menu_watch_dog.sh                  # VM Watchdog (Auto-restart via Ping)
│   │   ├── menu_ceph.sh                       # Ceph Management (cluster storage)
│   │   ├── menu_ia.sh                         # AI Assistant (OpenAI / Gemini)
│   │   ├── menu_instala_script.sh             # Shell login auto-start
│   │   ├── menu_instala_aplicativos.sh        # Applications Installation Hub
│   │   ├── menu_instala_tactical_rmm.sh       # TacticalRMM Install/Remove
│   │   ├── menu_instala_cloudflared.sh        # Cloudflare Tunnel Install/Remove
│   │   ├── menu_instala_zabbix.sh             # Zabbix Agent Install/Remove
│   │   ├── live_migration.sh                  # Live VM migration between nodes
│   │   ├── destranca_desliga.sh               # Unlock and force shutdown VMs
│   │   ├── funcao_instalar_na_inicializacao.sh # Auto-start helper
│   │   └── vm_config_checker.sh               # VM configuration checker
│   ├── pbs/                                   # Proxmox Backup Server Modules
│   │   ├── menu_pbs.sh                        # Main PBS Menu
│   │   ├── menu_update_pbs.sh                 # PBS Updates
│   │   ├── menu_upgrade_pbs.sh                # PBS Upgrade
│   │   └── menu_disco_pbs.sh                  # PBS Disk Management
│   └── extras/                                # General Tools and Diagnostics
│       ├── menu_extras.sh                     # Root Extras Menu (Menu 3)
│       ├── menu_extras_disco.sh               # Speed test, Badblocks, SMART
│       ├── menu_extras_email.sh               # Postfix / SMTP / aliases config
│       ├── menu_extras_rede.sh                # Interfaces, DNS and Hosts
│       ├── menu_extras_sistema.sh             # System, Temperature, SWAP, Watchdog
│       ├── menu_extras_comandos.sh            # Linux / PVE cheat-sheet
│       ├── menu_extras_gerenciamento.sh       # Messaging Center (Telegram/WhatsApp)
│       ├── menu_extras_ia.sh                  # AI Keys Management
│       ├── menu_telegram.sh                   # Management Bot + Notification Bot
│       ├── disk_badblocks.sh                  # badblocks helper
│       ├── disk_smart.sh                      # SMART info helper
│       └── disk_speed_test.sh                 # speed test helper (fio/dd)
└── README.md
```

---

## 🗂️ Menus and Features

### Menu 1 — Proxmox Virtual Environment (PVE)

| Option | Description |
|-------|-----------|
| 1 | System Packages Update and Upgrade |
| 2 | Disk Management (format, mount, fstab) |
| 3 | Backup (NFS, CIFS, local directory, scheduling) |
| 4 | Live VM Migration between nodes |
| 5 | Install Applications (TacticalRMM, Cloudflared, Zabbix) |
| 6 | VM Operations (Unlock, Shutdown, Check Config) |
| 7 | AI Assistant (OpenAI GPT-4o / Gemini 2.5) |

### Menu 2 — Proxmox Backup Server (PBS)

| Option | Description |
|-------|-----------|
| 1 | PBS Update and Upgrade |
| 2 | PBS Disk Management |

### Menu 3 — General Tools (Extras)

| Option | Sub-menu |
|-------|----------|
| 1 | 🖴 Disk Tools and Diagnostics |
| 2 | 📧 Email Notification Config (Postfix/SMTP) |
| 3 | 🌐 Network Configs (interfaces, DNS, hosts) |
| 4 | ⚙️ System, Host and Watchdog Tweaks |
| 5 | 📋 Useful Commands and Information (cheat-sheet) |
| 6 | 🤖 AI API Keys Management |
| 7 | 📡 Central Management and Notifications (Telegram) |

---

## 🔥 Thermal Monitoring & Hardware Protection

Available in: **Menu 3 → 4 → 1**

Complete temperature monitoring system with staged emergency shutdown.

### Features

- **Smart Sensor Reading** with automatic fallback cascade:
  1. `ipmitool sdr` (HPE iLO / Dell iDRAC / Local IPMI)
  2. `lm-sensors` (motherboard / CPU sensors)
  3. Kernel Sysfs (`/sys/class/thermal` / `/sys/class/hwmon`)

- **Smart Sensor Filter** — automatically ignores PCI network chips (`tg3`, `e1000e`) that naturally run at 55–65°C to avoid false alarms.

- **Configurable Target Mode** (`target`):
  - `ambient` — monitors room/AC temperature (Front Ambient / Inlet)
  - `cpu` — monitors processor temperatures (Package / Core)

- **Staged Telegram Alarms**:
  - 🟡 **Warning** (e.g., 30°C) — Hot room alert, check AC
  - ⚠️ **Critical 1** (e.g., 60°C) — Automatic shutdown of secondary VMs
  - 🚨 **Critical 2** (e.g., 80°C) — Emergency shutdown of Proxmox VE host

- **Root Crontab Scheduling** (`crontab -e`), every 2 minutes
- **Interactive `config.ini` editor** directly via Bash menu
- **Dry-Run Simulations** (65°C and 82°C) without real shutdowns
- **Automatic installation** of `lm-sensors` and `ipmitool` when opening the menu

---

## 📡 Telegram Messaging Hub

Available in: **Menu 3 → 7**

### 1 — 🤖 Telegram Management (Interactive Bot)

Conversational bot allowing technicians to manage the Proxmox server via Telegram:
- Start / Stop / Restart bot service
- Real-time status in menu header
- Token and Chat ID configuration with immediate testing

### 2 — 📣 Telegram Notifications (Passive Bot)

Separate bot for receiving **automatic alerts** from the system:
- Temperature alerts (Thermal Monitoring)
- Critical events notifications
- Setup via menu with token, chat ID and server name
- Immediate message delivery test

> **Separation of concerns**: Use the Management Bot for commands and the Notification Bot for passive alerts — each with its own token.

---

## 🐕 VM Watchdog

Available in: **Menu 3 → 4 → 5**

Monitors VMs via ping and automatically restarts them if they go offline.

- Add/Remove monitored VMs (by ID and IP)
- Automatic scheduling every 10 minutes via crontab
- Each VM generates an individual script in `/TcTI/SCRIPTS/WATCHDOG/`

---

## 🤖 Integrated AI Assistant

Available in **PVE Menu → 7** and keys in **Menu 3 → 6**

Supported models:
- **Gemini 2.5 Flash** (default, fastest)
- **Gemini 2.5 Pro** (more advanced)
- **OpenAI GPT-4o**
- **OpenAI GPT-4o-mini**

---

## 🔄 Auto-Update System

By default, `main.sh` checks for updates on GitHub at every execution.

### Enable / Disable Automatic Updates
For corporate environments requiring fixed versions due to security policies:
- Go to: **Menu 3 (Extras) → 7 (Management Hub) → 3 ➜ Auto-Update Configuration**
- **Option 1:** Disable Auto-Update (blocks downloads on startup)
- **Option 2:** Enable Auto-Update (restores default behavior)

**Visual indicators:**
- 🆕 `NEW` — New file installed locally
- 🔄 `UPDATED` — File has been updated
- `✓ OK` — Already on the latest version
- `✗ ERROR` — Download failed

When `main.sh` itself is updated, it automatically restarts with a 5-second countdown.

---

## ⚙️ Auto-Start on Login

Available in: **PVE Menu → Tweaks / Menu 3 → 4 → 4**

Installs the script to `/etc/profile.d/proxmox-ini.sh` for automatic execution when opening a new SSH terminal.

---

## 🔒 Security

- All scripts require **root** privileges
- User input validation on critical operations
- Double confirmation before destructive operations
- Detailed logs of all relevant operations
- Telegram credentials stored with `600` permissions (root only)
- Configurable timeouts in Telegram API calls to prevent hangs

---

## 🐛 Troubleshooting

### Script not updating
```bash
rm /TcTI/SCRIPTS/PROXMOX/.local_version && ./main.sh
```

### Wrong temperature value (e.g., 59°C from network card)
Go to **Menu 3 → 4 → 1 → 4 → Option 5** and change the **Target Focus**:
- `ambient` — room temperature (Front Ambient / Inlet ~20–28°C)
- `cpu` — processor temperature (~40–50°C)

### Missing dependencies
```bash
apt update && apt install -y curl python3 lm-sensors ipmitool
```

---

## ⚠️ Warnings

- Always test in a **non-production** environment first
- Create a **backup** before critical modifications
- Host shutdown operations (Critical 2) are **irreversible** — configure limits carefully
- Use at your own risk

---

## 📞 Support

To report bugs or request features:
- Open an **issue** on GitHub with detailed description
- Include logs, error messages and Proxmox version

---

Developed by [TcTI-BR](https://github.com/TcTI-BR)
