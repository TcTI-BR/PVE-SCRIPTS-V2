# 🖥️ PVE-SCRIPTS-V2 — Proxmox Management Suite

[🇧🇷 Português](README_pt.md) | [🇪🇸 Español](README_es.md) | [🇨🇳 中文](README_zh.md) | [🇺🇸 English](README.md)

Suite completa de scripts Bash para la automatización y gestión interactiva de entornos **Proxmox VE** y **Proxmox Backup Server** mediante la terminal.

---

## ✨ Visión General

Interfaz de menú interactiva con navegación de una sola tecla, organizada en módulos independientes. Incluye sistema de actualización automática vía GitHub, integración nativa con Telegram para alertas y gestión, monitorización térmica con protección de hardware, y mucho más.

---

## 🚀 Instalación

```bash
mkdir -p /TcTI/SCRIPTS/PROXMOX && cd /TcTI/SCRIPTS/PROXMOX \
  && curl -sL -o main.sh https://raw.githubusercontent.com/TcTI-BR/PVE-SCRIPTS-V2/main/main.sh \
  && chmod +x main.sh && ./main.sh
```

El script principal descarga y verifica automáticamente todos los módulos en la primera ejecución.

### Forzar actualización completa

```bash
rm /TcTI/SCRIPTS/PROXMOX/.local_version && ./main.sh
```

---

## 🗂️ Menús y Funcionalidades

### Menú 1 — Proxmox Virtual Environment (PVE)

| Opción | Descripción |
|-------|-----------|
| 1 | Actualización de Paquetes del Sistema (Update / Upgrade) |
| 2 | Gestión de Discos (formatear, montar, fstab) |
| 3 | Respaldo / Backup (NFS, CIFS, directorio local, programación) |
| 4 | Migración en Vivo de VMs entre nodos |
| 5 | Instalar Aplicaciones (TacticalRMM, Cloudflared, Zabbix) |
| 6 | Operaciones en VMs (Desbloquear, Apagar, Revisar Config) |
| 7 | Asistente de IA (OpenAI GPT-4o / Gemini 2.5) |

### Menú 2 — Proxmox Backup Server (PBS)

| Opción | Descripción |
|-------|-----------|
| 1 | Actualización y Upgrade de PBS |
| 2 | Gestión de Discos PBS |

### Menú 3 — Herramientas Generales (Extras)

| Opción | Sub-menú |
|-------|----------|
| 1 | 🖴 Herramientas y Diagnósticos de Disco |
| 2 | 📧 Configuración de Notificaciones por Correo (Postfix/SMTP) |
| 3 | 🌐 Configuraciones de Red (interfaces, DNS, hosts) |
| 4 | ⚙️ Ajustes del Sistema, Host y Watchdog |
| 5 | 📋 Comandos e Información Útil (cheat-sheet) |
| 6 | 🤖 Gestión de Claves de API de IA |
| 7 | 📡 Centro de Gestión y Notificaciones (Telegram) |

---

## 🔥 Monitorización Térmica y Protección de Hardware

Disponible en: **Menú 3 → 4 → 1**

Sistema completo de monitorización de temperatura con apagado de emergencia escalonado.

### Funcionalidades
- **Lectura Inteligente de Sensores** con cascada de respaldo automático (IPMI -> lm-sensors -> Sysfs).
- **Filtro Inteligente** — ignora automáticamente chips de red PCI que operan a 55–65°C para evitar falsas alarmas.
- **Modo Objetivo Configurable** (`ambient` o `cpu`).
- **Alarmas Escalonadas por Telegram** (Advertencia, Crítico 1, Crítico 2).
- **Programación automática** e instalación de dependencias requeridas.

---

## 📡 Centro de Mensajería de Telegram

Disponible en: **Menú 3 → 7**

1. **Bot de Gestión**: Bot conversacional para ejecutar comandos directamente desde Telegram.
2. **Bot de Notificaciones**: Bot pasivo para recibir alertas automáticas del sistema y temperatura.

---

## 🤖 Asistente de IA Integrado

Disponible en **Menú PVE → 7** y claves en **Menú 3 → 6**

Modelos soportados:
- Gemini 2.5 Flash / Pro
- OpenAI GPT-4o / mini

---

## 🔄 Sistema de Actualización Automática

El script verifica actualizaciones en GitHub en cada ejecución, garantizando siempre la última versión. Se puede desactivar para entornos corporativos desde el Menú 3.

---

## 🔒 Seguridad
- Requiere privilegios **root**.
- Validación de entradas y doble confirmación para operaciones destructivas.
- Credenciales de Telegram almacenadas de manera segura (`600`).

---

Desarrollado por [TcTI-BR](https://github.com/TcTI-BR)
