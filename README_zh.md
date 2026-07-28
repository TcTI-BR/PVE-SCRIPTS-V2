# 🖥️ PVE-SCRIPTS-V2 — Proxmox Management Suite

[🇧🇷 Português](README_pt.md) | [🇪🇸 Español](README_es.md) | [🇨🇳 中文](README_zh.md) | [🇺🇸 English](README.md)

基于 Bash 脚本的完整套件，用于通过终端自动化和交互式管理 **Proxmox VE** 及 **Proxmox Backup Server** 环境。

---

## ✨ 概览

采用单键导航的交互式菜单界面，模块化设计。包含 GitHub 自动更新系统、原生的 Telegram 警报和管理集成、带有硬件保护的温度监控等众多功能。

---

## 🚀 安装指南

```bash
mkdir -p /TcTI/SCRIPTS/PROXMOX && cd /TcTI/SCRIPTS/PROXMOX \
  && curl -sL -o main.sh https://raw.githubusercontent.com/TcTI-BR/PVE-SCRIPTS-V2/main/main.sh \
  && chmod +x main.sh && ./main.sh
```

主脚本将在首次运行时自动下载并验证所有模块。

### 强制完整更新

```bash
rm /TcTI/SCRIPTS/PROXMOX/.local_version && ./main.sh
```

---

## 🗂️ 菜单和功能

### 菜单 1 — Proxmox 虚拟化环境 (PVE)

| 选项 | 描述 |
|-------|-----------|
| 1 | 系统软件包更新和升级 (Update / Upgrade) |
| 2 | 磁盘管理 (格式化、挂载、fstab) |
| 3 | 备份配置 (NFS, CIFS, 本地目录, 计划任务) |
| 4 | 节点间虚拟机 (VM) 实时迁移 |
| 5 | 安装应用程序 (TacticalRMM, Cloudflared, Zabbix) |
| 6 | 虚拟机操作 (解锁、关机、检查配置) |
| 7 | AI 助手 (OpenAI GPT-4o / Gemini 2.5) |

### 菜单 2 — Proxmox 备份服务器 (PBS)

| 选项 | 描述 |
|-------|-----------|
| 1 | PBS 更新和升级 |
| 2 | PBS 磁盘管理 |

### 菜单 3 — 通用工具 (附加组件)

| 选项 | 子菜单 |
|-------|----------|
| 1 | 🖴 磁盘工具和诊断 |
| 2 | 📧 电子邮件通知配置 (Postfix/SMTP) |
| 3 | 🌐 网络配置 (接口、DNS、hosts) |
| 4 | ⚙️ 系统、主机和看门狗设置 |
| 5 | 📋 常用命令和信息 (速查表) |
| 6 | 🤖 AI API 密钥管理 |
| 7 | 📡 集中管理和通知 (Telegram) |

---

## 🔥 温度监控与硬件保护

可通过：**菜单 3 → 4 → 1** 访问

完整的温度监控系统，具备分级紧急关机功能。

### 功能特点
- **智能传感器读取**：具备自动降级级联 (IPMI -> lm-sensors -> Sysfs)。
- **智能传感器过滤**：自动忽略正常工作温度为 55–65°C 的 PCI 网卡芯片以防止误报。
- **可配置的目标模式** (`ambient` 环境 或 `cpu` 处理器)。
- **分级 Telegram 警报** (警告、严重级别 1、严重级别 2)。
- **自动配置计划任务**并安装依赖。

---

## 📡 Telegram 消息中心

可通过：**菜单 3 → 7** 访问

1. **管理机器人**：允许技术人员通过 Telegram 直接执行命令的对话机器人。
2. **通知机器人**：被动接收系统警报和温度警告的独立机器人。

---

## 🤖 集成 AI 助手

可通过 **PVE 菜单 → 7** 以及 **菜单 3 → 6** (密钥管理) 访问

支持的模型：
- Gemini 2.5 Flash / Pro
- OpenAI GPT-4o / mini

---

## 🔄 自动更新系统

默认情况下，`main.sh` 会在每次执行时检查 GitHub 上的更新，确保您使用的是最新版本。对于企业环境，可以在菜单 3 中禁用此功能。

---

## 🔒 安全性
- 所有脚本都需要 **root** 权限。
- 对破坏性操作进行用户输入验证和二次确认。
- Telegram 凭据以高安全级别 (`600`) 存储。

---

由 [TcTI-BR](https://github.com/TcTI-BR) 开发
