# 🖥️ PVE-SCRIPTS-V2 — Proxmox Management Suite

[🇧🇷 Português](README_pt.md) | [🇪🇸 Español](README_es.md) | [🇨🇳 中文](README_zh.md) | [🇺🇸 English](README.md)

Complete suite of Bash scripts for automation and interactive management of **Proxmox VE** and **Proxmox Backup Server** environments via terminal.

---

## ✨ Overview

Interactive menu interface with single-key navigation, organized into independent modules. Includes a GitHub auto-update system, native Telegram integration for alerts and management, thermal monitoring with hardware protection, multi-language support (English, Portuguese, Spanish, Chinese), and much more.

---

## 🚀 Installation

```bash
mkdir -p /TcTI/SCRIPTS/PROXMOX && cd /TcTI/SCRIPTS/PROXMOX \
  && curl -sL -o main.sh https://raw.githubusercontent.com/TcTI-BR/PVE-SCRIPTS-V2/main/main.sh \
  && chmod +x main.sh && ./main.sh
```

The main script automatically downloads and verifies all modules on the first run. The system will automatically detect your OS language.

### Force complete update

```bash
rm /TcTI/SCRIPTS/PROXMOX/.local_version && ./main.sh
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
- **Smart Sensor Reading** with automatic fallback cascade (IPMI -> lm-sensors -> Sysfs)
- **Smart Sensor Filter** — automatically ignores PCI network chips (`tg3`, `e1000e`) that naturally run hot
- **Configurable Target Mode** (`ambient` or `cpu`)
- **Staged Telegram Alarms** (Warning, Critical 1, Critical 2)
- **Automated installation** of dependencies and crontab scheduling

---

## 📡 Telegram Messaging Hub

Available in: **Menu 3 → 7**

1. **Management Bot**: Conversational bot for executing commands directly from Telegram.
2. **Notification Bot**: Passive bot for receiving system alerts and temperature warnings.

---

## 🤖 Integrated AI Assistant

Available in **PVE Menu → 7** and keys in **Menu 3 → 6**

Supported models:
- Gemini 2.5 Flash / Pro
- OpenAI GPT-4o / mini

---

## 🔒 Security
- All scripts require **root** privileges
- User input validation on critical operations
- Double confirmation before destructive operations
- Telegram credentials stored with `600` permissions (root only)

---

## 📞 Support
To report bugs or request features, open an **issue** on GitHub with detailed description.

Developed by [TcTI-BR](https://github.com/TcTI-BR)
