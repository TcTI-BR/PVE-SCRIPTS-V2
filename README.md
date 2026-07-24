# 🖥️ PVE-SCRIPTS-V2 — Proxmox Management Suite

Suite completa de scripts Bash para automação e gerenciamento interativo de ambientes **Proxmox VE** e **Proxmox Backup Server** via terminal.

---

## ✨ Visão Geral

Interface de menu interativa com navegação por tecla única, organizada em módulos independentes. Inclui sistema de auto-atualização via GitHub, integração nativa com Telegram para alertas e gerenciamento, monitoramento térmico com proteção de hardware e muito mais.

---

## 🚀 Instalação

```bash
mkdir -p /TcTI/SCRIPTS/PROXMOX && cd /TcTI/SCRIPTS/PROXMOX \
  && curl -sL -o main.sh https://raw.githubusercontent.com/TcTI-BR/PVE-SCRIPTS-V2/main/main.sh \
  && chmod +x main.sh && ./main.sh
```

O script principal baixa e verifica automaticamente todos os módulos na primeira execução.

### Forçar atualização completa

```bash
rm /TcTI/SCRIPTS/PROXMOX/.local_version && ./main.sh
```

---

## 📁 Estrutura do Projeto

```
PVE-SCRIPTS-V2/
├── main.sh                                    # Script principal, auto-updater e loader de módulos
├── temp/
│   └── pve_temp_monitor.py                    # Backend Python de monitoramento térmico
├── functions/
│   ├── pve/                                   # Módulos Proxmox Virtual Environment
│   │   ├── menu_pve.sh                        # Menu principal PVE
│   │   ├── menu_update.sh                     # Atualizações de pacotes
│   │   ├── menu_upgrade.sh                    # Upgrade de versões do Proxmox VE
│   │   ├── menu_disco.sh                      # Gerenciamento de discos
│   │   ├── menu_bkp.sh                        # Configurações de backup (NFS/CIFS/Local)
│   │   ├── menu_vm_operations.sh              # Operações em VMs (migrar, desligar, etc.)
│   │   ├── menu_watch_dog.sh                  # Watchdog de VMs (Auto-restart via Ping)
│   │   ├── menu_ceph.sh                       # Gerenciamento Ceph (cluster storage)
│   │   ├── menu_ia.sh                         # Assistente de IA (OpenAI / Gemini)
│   │   ├── menu_instala_script.sh             # Auto-inicialização no login do shell
│   │   ├── menu_instala_aplicativos.sh        # Hub de instalação de aplicativos
│   │   ├── menu_instala_tactical_rmm.sh       # Instalação/Remoção do TacticalRMM
│   │   ├── menu_instala_cloudflared.sh        # Instalação/Remoção do Cloudflare Tunnel
│   │   ├── menu_instala_zabbix.sh             # Instalação/Remoção do Zabbix Agent
│   │   ├── live_migration.sh                  # Migração ao vivo de VMs entre nodes
│   │   ├── destranca_desliga.sh               # Destravar e forçar desligamento de VMs
│   │   ├── funcao_instalar_na_inicializacao.sh # Helper de auto-start
│   │   └── vm_config_checker.sh               # Verificação de configuração de VMs
│   ├── pbs/                                   # Módulos Proxmox Backup Server
│   │   ├── menu_pbs.sh                        # Menu principal PBS
│   │   ├── menu_update_pbs.sh                 # Atualizações PBS
│   │   ├── menu_upgrade_pbs.sh                # Upgrade PBS
│   │   └── menu_disco_pbs.sh                  # Gerenciamento de discos PBS
│   └── extras/                                # Ferramentas Gerais e Diagnósticos
│       ├── menu_extras.sh                     # Menu raiz de Extras (Menu 3)
│       ├── menu_extras_disco.sh               # Speed test, Badblocks, SMART
│       ├── menu_extras_email.sh               # Configuração Postfix / SMTP / aliases
│       ├── menu_extras_rede.sh                # Interfaces, DNS e Hosts
│       ├── menu_extras_sistema.sh             # Sistema, Temperatura, SWAP, Watchdog
│       ├── menu_extras_comandos.sh            # Cheat-sheet Linux / PVE / caminhos
│       ├── menu_extras_gerenciamento.sh       # Central de Mensageria (Telegram/WhatsApp)
│       ├── menu_extras_ia.sh                  # Gerenciamento de chaves de IA
│       ├── menu_telegram.sh                   # Bot de Gerenciamento + Bot de Notificações
│       ├── disk_badblocks.sh                  # Helper badblocks
│       ├── disk_smart.sh                      # Helper SMART info
│       └── disk_speed_test.sh                 # Helper speed test (fio/dd)
└── README.md
```

---

## 🗂️ Menus e Funcionalidades

### Menu 1 — Proxmox Virtual Environment (PVE)

| Opção | Descrição |
|-------|-----------|
| 1 | Atualização e Upgrade de Pacotes do Sistema |
| 2 | Gerenciamento de Discos (formatar, montar, fstab) |
| 3 | Backup (NFS, CIFS, diretório local, agendamento) |
| 4 | Migração ao Vivo de VMs entre nodes |
| 5 | Instalar Aplicativos (TacticalRMM, Cloudflared, Zabbix) |
| 6 | Operações em VMs (Destravar, Desligar, Verificar Config) |
| 7 | Assistente de IA (OpenAI GPT-4o / Gemini 2.5) |

### Menu 2 — Proxmox Backup Server (PBS)

| Opção | Descrição |
|-------|-----------|
| 1 | Atualização e Upgrade do PBS |
| 2 | Gerenciamento de Discos PBS |

### Menu 3 — Ferramentas Gerais (Extras)

| Opção | Sub-menu |
|-------|----------|
| 1 | 🖴 Ferramentas e Diagnósticos de Disco |
| 2 | 📧 Configuração de Notificações por E-mail (Postfix/SMTP) |
| 3 | 🌐 Configurações de Rede (interfaces, DNS, hosts) |
| 4 | ⚙️ Ajustes de Sistema, Host e Watchdog |
| 5 | 📋 Comandos e Informações Úteis (cheat-sheet) |
| 6 | 🤖 Gerenciamento de Chaves de IA |
| 7 | 📡 Central de Gerenciamento e Notificações (Telegram) |

---

## 🔥 Monitoramento Térmico & Proteção de Hardware

Disponível em: **Menu 3 → 4 → 1**

Sistema completo de monitoramento de temperatura com desligamento escalonado de emergência.

### Funcionalidades

- **Leitura Inteligente de Sensores** com cascata automática de fallback:
  1. `ipmitool sdr` (HPE iLO / Dell iDRAC / IPMI local)
  2. `lm-sensors` (sensores de placa-mãe / CPU)
  3. Kernel Sysfs (`/sys/class/thermal` / `/sys/class/hwmon`)

- **Filtro Inteligente de Sensores** — ignora automaticamente chips de rede PCI (`tg3`, `e1000e`) que operam naturalmente a 55–65°C e causariam falsos alarmes

- **Modo de Alvo Configurável** (`target`):
  - `ambient` — monitora temperatura da sala/ar-condicionado (Front Ambient / Inlet)
  - `cpu` — monitora temperatura dos processadores (Package / Core)

- **Alarmes Escalonados via Telegram**:
  - 🟡 **Warning** (ex: 30°C) — Alerta de sala quente, verificar ar-condicionado
  - ⚠️ **Crítico 1** (ex: 60°C) — Desligamento automático das VMs secundárias
  - 🚨 **Crítico 2** (ex: 80°C) — Desligamento de emergência do host Proxmox VE

- **Agendamento via Crontab do Root** (`crontab -e`), a cada 2 minutos
- **Editor interativo do `config.ini`** diretamente pelo menu Bash
- **Simulações Dry-Run** (65°C e 82°C) sem desligamentos reais
- **Instalação automática** de `lm-sensors` e `ipmitool` ao abrir o menu

### Arquivos

| Arquivo | Localização |
|---------|-------------|
| Script Python | `/TcTI/SCRIPTS/monitoramento-temp/pve_temp_monitor.py` |
| Configurações | `/TcTI/SCRIPTS/monitoramento-temp/config.ini` |
| Logs | `/TcTI/SCRIPTS/monitoramento-temp/pve_temp_monitor.log` |
| Estado | `/TcTI/SCRIPTS/monitoramento-temp/state.json` |

---

## 📡 Central de Mensageria Telegram

Disponível em: **Menu 3 → 7**

### 1 — 🤖 Gerenciamento via Telegram (Bot Interativo)

Bot conversacional que permite ao técnico gerenciar o servidor Proxmox pelo Telegram:
- Iniciar / Parar / Reiniciar serviço do bot
- Ver status em tempo real no header do menu
- Configuração de token e chat ID com teste imediato

Credenciais: `/TcTI/SCRIPTS/telegram/.env` (base64 JSON)

### 2 — 📣 Notificações via Telegram (Bot Passivo)

Bot separado para receber **alertas automáticos** do sistema:
- Alertas de temperatura (Monitoramento Térmico)
- Notificações de eventos críticos
- Cadastro via menu com token, chat ID e nome do servidor
- Teste de envio de mensagem imediato

Credenciais: `/TcTI/SCRIPTS/telegram/.env_notificacoes`

> **Separação de responsabilidades**: use o Bot de Gerenciamento para comandos e o Bot de Notificações para alertas passivos — cada um com seu próprio token.

---

## 🐕 Watchdog de VMs

Disponível em: **Menu 3 → 4 → 5**

Monitora VMs via ping e reinicia automaticamente caso fiquem offline.

- Adicionar/Remover VMs monitoradas (por ID e IP)
- Agendamento automático a cada 10 minutos via crontab
- Cada VM gera um script individual em `/TcTI/SCRIPTS/WATCHDOG/`

---

## 🤖 Assistente de IA Integrado

Disponível no **Menu PVE → 7** e nas chaves em **Menu 3 → 6**

Modelos suportados:
- **Gemini 2.5 Flash** (padrão, mais rápido)
- **Gemini 2.5 Pro** (mais avançado)
- **OpenAI GPT-4o**
- **OpenAI GPT-4o-mini**

---

## 🔄 Sistema de Auto-Atualização

O `main.sh` verifica automaticamente por atualizações no GitHub a cada execução, comparando via MD5 checksum.

**Indicadores visuais:**
- 🆕 `NOVO` — Arquivo novo instalado localmente
- 🔄 `ATUALIZADO` — Arquivo foi atualizado
- `✓ OK` — Já está na versão mais recente
- `✗ ERRO` — Falha no download

Quando o próprio `main.sh` é atualizado, reinicia automaticamente com contagem regressiva de 5 segundos.

---

## ⚙️ Auto-Inicialização no Login

Disponível em: **Menu PVE → Tweaks / Menu 3 → 4 → 4**

Instala o script em `/etc/profile.d/proxmox-ini.sh` para execução automática ao abrir um novo terminal SSH.

---

## 🔒 Segurança

- Todos os scripts requerem privilégios **root**
- Validação de entradas do usuário em operações críticas
- Confirmação dupla antes de operações destrutivas
- Logs detalhados de todas as operações relevantes
- Credenciais do Telegram armazenadas com permissão `600` (somente root)
- Timeouts configuráveis nas chamadas à API do Telegram para evitar travamentos

---

## 🛠️ Desenvolvimento

### Adicionando um novo módulo

1. Crie `functions/extras/meu_modulo.sh` ou `functions/pve/meu_modulo.sh`
2. Declare a função principal seguindo o padrão de menu do projeto:

```bash
#!/bin/bash

minha_funcao() {
    while true; do
        clear
        echo -e "${COLOR_CYAN}${COLOR_BOLD}"
        echo -e "╔═════════════════════════════════════════════════════════════════════╗"
        echo -e "║                         Título do Módulo                           ║"
        echo -e "╚═════════════════════════════════════════════════════════════════════╝"
        echo -e "${COLOR_RESET}"
        # ... opções de menu ...
        read -rsn1 opt
        case "$opt" in
            1) # ação ;;
            0|"") return 0 ;;
        esac
    done
}
```

3. O `main.sh` carrega automaticamente todos os `.sh` das pastas `functions/pve/`, `functions/pbs/` e `functions/extras/` via source — não é necessário registrar o arquivo manualmente.
4. Referencie a função no menu adequado (`menu_extras.sh`, `menu_pve.sh`, etc.).

### Paleta de Cores e Símbolos

```bash
COLOR_RESET="\\033[0m"   COLOR_BOLD="\\033[1m"
COLOR_GREEN="\\033[1;32m" COLOR_CYAN="\\033[1;36m"
COLOR_YELLOW="\\033[1;33m" COLOR_RED="\\033[1;31m"
COLOR_WHITE="\\033[1;37m" COLOR_GRAY="\\033[1;90m"
COLOR_BLUE="\\033[1;34m"  COLOR_MAGENTA="\\033[1;35m"

SYMBOL_CHECK="✓"   SYMBOL_ERROR="✗"
SYMBOL_ARROW="➜"   SYMBOL_LOADING="🔄"
SYMBOL_INFO="ℹ"    SYMBOL_NEW="🆕"
```

---

## 🐛 Solução de Problemas

### Script não atualiza
```bash
rm /TcTI/SCRIPTS/PROXMOX/.local_version && ./main.sh
```

### Temperatura mostrando valor errado (59°C de placa de rede)
Acesse **Menu 3 → 4 → 1 → 4 → Opção 5** e altere o **Foco do Alvo**:
- `ambient` — temperatura da sala (Front Ambient / Inlet ~20–28°C)
- `cpu` — temperatura dos processadores (~40–50°C)

### Bot Telegram não responde / trava
O script usa `timeout=10` nas chamadas à API. Se persistir, reinicie o serviço:
- **Menu 3 → 7 → 1 → Reiniciar Serviço**

### Watchdog não abre (volta ao menu sem fazer nada)
Certifique-se de que o arquivo `functions/pve/menu_watch_dog.sh` está sendo carregado corretamente. A função correta se chama `watch_dog` (sem prefixo `menu_`).

### Erro de permissão
```bash
cd /TcTI/SCRIPTS/PROXMOX && find . -name "*.sh" -exec chmod +x {} \;
```

### Dependências ausentes
```bash
apt update && apt install -y curl python3 lm-sensors ipmitool
```

---

## 📦 Changelog

### v2.3 (Atual)
- ✅ **Monitoramento Térmico & Proteção de Hardware** com cascata de sensores (IPMI → lm-sensors → Sysfs)
- ✅ **Filtro Inteligente de Sensores** (ignora chips de rede PCI com temperatura alta natural)
- ✅ **Bot de Notificações Telegram** separado do Bot de Gerenciamento
- ✅ Central de Mensageria unificada em **Menu 3 → 7**
- ✅ Assistente de IA com modelos atualizados (Gemini 2.5 Flash/Pro, GPT-4o/mini)
- ✅ Editor interativo do `config.ini` pelo menu Bash

### v2.2
- ✅ Migração do Telegram para **Menu 3 (Extras)**
- ✅ Integração do Zabbix Agent
- ✅ Menu Ceph para gerenciamento de cluster storage
- ✅ VM Config Checker

### v2.1
- ✅ Reestruturação do Menu 3 (Extras) com 7 categorias
- ✅ Chave de IA movida para Menu 3
- ✅ Configurações de Rede movidas para Menu 3

### v2.0
- ✅ Refatoração completa da estrutura modular
- ✅ Interface modernizada com cores e Unicode
- ✅ Sistema de auto-atualização via GitHub com MD5 checksum
- ✅ TacticalRMM e Cloudflare Tunnel
- ✅ Migração ao vivo de VMs

### v1.0
- Versão inicial com funcionalidades básicas PVE/PBS

---

## ⚠️ Avisos

- Sempre teste em ambiente **não-produção** primeiro
- Faça **backup** antes de modificações críticas
- Operações de desligamento de host (Crítico 2) são **irreversíveis** — configure os limites com cuidado
- O uso é de inteira responsabilidade do usuário

---

## 📞 Suporte

Para reportar bugs ou solicitar features:
- Abra uma **issue** no GitHub com descrição detalhada
- Inclua logs, mensagens de erro e versão do Proxmox

---

Desenvolvido por [TcTI-BR](https://github.com/TcTI-BR)
