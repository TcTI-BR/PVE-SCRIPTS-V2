# Proxmox Management Scripts

Suite completa de scripts bash para automação e gerenciamento de ambientes Proxmox VE e Proxmox Backup Server.

## Visão Geral

Este projeto oferece uma interface interativa via terminal para gerenciar operações comuns em servidores Proxmox, incluindo atualizações de sistema, configurações de rede, gestão de discos, backups, instalação de aplicações e muito mais.

## Características

- Interface de menu interativa com navegação simplificada
- Suporte completo para Proxmox VE e Proxmox Backup Server
- Sistema de auto-atualização via GitHub
- Instalação automática na inicialização do shell
- Código modular e organizado por funcionalidade
- Visual moderno com cores e símbolos Unicode

## Requisitos

- Proxmox VE 7.x ou superior / Proxmox Backup Server 2.x ou superior
- Sistema operacional Debian-based
- Acesso root
- Conexão com internet (para atualizações e instalação de pacotes)

## Instalação

```bash
# Cria diretório, baixa e executa o script principal
mkdir -p /TcTI/SCRIPTS/PROXMOX && cd /TcTI/SCRIPTS/PROXMOX && curl -sL -o main.sh https://raw.githubusercontent.com/TcTI-BR/PVE-SCRIPTS-V2/main/main.sh && chmod +x main.sh && ./main.sh
```

O script principal irá baixar automaticamente todos os módulos necessários na primeira execução.

### Instalação automática na inicialização

O script oferece opção para carregar automaticamente ao abrir o terminal:
- Acesse: `Menu Proxmox VE > Tweaks > Instala script automaticamente`
- Após instalado, o script será executado automaticamente em novos logins

## Estrutura do Projeto

```
PVE-SCRIPTS-V2/
├── main.sh                          # Script principal e gerenciador de atualizações
├── functions/
│   ├── pve/                         # Funções específicas do Proxmox VE
│   │   ├── menu_pve.sh              # Menu principal PVE
│   │   ├── menu_update.sh           # Atualizações e instalações
│   │   ├── menu_upgrade.sh          # Upgrade de versões
│   │   ├── menu_disco.sh            # Gerenciamento de discos
│   │   ├── menu_bkp.sh              # Configurações de backup
│   │   ├── menu_email.sh            # Configurações de e-mail/SMTP
│   │   ├── menu_vm_operations.sh    # Operações em VMs
│   │   ├── menu_tweaks.sh           # Otimizações e ajustes
│   │   ├── menu_lan.sh              # Configurações de rede
│   │   ├── menu_commands.sh         # Comandos úteis
│   │   ├── menu_instala_script.sh   # Instalação automática
│   │   ├── menu_instala_x.sh        # Instalação de interface gráfica
│   │   ├── menu_watch_dog.sh        # Configuração de watchdog
│   │   ├── menu_instala_aplicativos.sh        # Menu de aplicações
│   │   ├── menu_instala_tactical_rmm.sh       # TacticalRMM
│   │   ├── menu_instala_cloudflared.sh        # Cloudflare Tunnel
│   │   ├── live_migration.sh        # Migração ao vivo de VMs
│   │   └── destranca_desliga.sh     # Destravar e desligar VMs
│   └── pbs/                         # Funções específicas do Proxmox Backup Server
│       ├── menu_pbs.sh              # Menu principal PBS
│       ├── menu_update_pbs.sh       # Atualizações PBS
│       ├── menu_upgrade_pbs.sh      # Upgrade PBS
│       ├── menu_disco_pbs.sh        # Discos PBS
│       ├── menu_email_pbs.sh        # E-mail PBS
│       ├── menu_lan_pbs.sh          # Rede PBS
│       └── menu_tweaks_pbs.sh       # Tweaks PBS
└── README.md
```

## Funcionalidades

### Proxmox VE

#### 1. Atualização, Instalação e Upgrade
- Atualização de pacotes do sistema
- Upgrade entre versões do Proxmox
- Instalação de aplicativos terceiros

#### 2. Gerenciamento de Discos
- Formatação de discos adicionais
- Montagem automática via fstab
- Configuração de permissões
- Suporte para ext4, xfs, btrfs

#### 3. Backup e Recuperação
- Configuração de destinos de backup
- Agendamento automático
- Backup para NFS, CIFS, Diretórios locais
- Verificação de integridade

#### 4. Configuração de E-mail/SMTP
- Configuração de servidor SMTP
- Testes de envio
- Notificações de sistema
- Suporte para autenticação SSL/TLS

#### 5. Operações em VMs
- **Live Migration**: Migração de VMs entre nodes sem downtime
  - Seleção de VM de origem
  - Escolha de node de destino
  - Verificação de recursos
  - Migração com rollback automático em caso de falha
  
- **Destrava e Desliga**: Liberação de VMs travadas
  - Identifica VMs com lock
  - Remove locks com segurança
  - Desligamento forçado quando necessário

#### 6. Tweaks e Otimizações
- Configuração de kernel parameters
- Otimização de I/O
- Ajustes de memória
- Habilitação de recursos avançados
- IOMMU e PCI passthrough
- Instalação automática do script

#### 7. Configurações de Rede
- Configuração de interfaces
- Bridges e bonds
- VLAN tagging
- Configuração de firewall
- Port forwarding

#### 8. Comandos Úteis
- Limpeza de cache
- Verificação de logs
- Status de serviços
- Informações do sistema
- Monitoramento de recursos

#### 9. Interface Gráfica (X Server)
- Instalação de ambiente gráfico
- XFCE4 desktop environment
- VNC server
- Remote desktop

#### 10. Watchdog
- Configuração de watchdog timer
- Reinicialização automática em caso de travamento
- Monitoramento de saúde do sistema

### Aplicações de Terceiros

#### TacticalRMM
Agente de monitoramento e gerenciamento remoto.

**Funcionalidades:**
- Instalação guiada com validação de parâmetros
- Configuração de Mesh Agent e API
- Suporte para diferentes tipos de agente (workstation/server)
- Desinstalação segura
- Validação de URLs e credenciais

**Parâmetros necessários:**
- Mesh URL (endpoint do MeshCentral)
- API URL (endpoint da API TacticalRMM)
- Client ID (identificador do cliente)
- Site ID (identificador do site)
- Auth Key (chave de autenticação)
- Agent Type (workstation ou server)

#### Cloudflare Tunnel
Túnel reverso seguro para expor serviços sem abrir portas no firewall.

**Funcionalidades:**
- Instalação do cloudflared daemon
- Configuração de túnel com token
- Auto-start no boot
- Monitoramento de status
- Desinstalação completa

**Status em tempo real:**
- Estado da instalação
- Versão instalada
- Status do serviço (ativo/inativo)
- Configuração do túnel

### Proxmox Backup Server

#### 1. Atualizações
- Atualização de pacotes PBS
- Patches de segurança
- Upgrade do sistema

#### 2. Gerenciamento de Discos
- Configuração de datastores
- Formatação de discos para backup
- Montagem e permissões

#### 3. Configuração de E-mail
- Notificações de backup
- Alertas de sistema
- Relatórios automáticos

#### 4. Rede
- Configuração de interfaces
- Acesso remoto
- Sincronização entre servidores

#### 5. Tweaks
- Otimizações de performance
- Configurações de retenção
- Prune automático
- Auto-start do script

## Sistema de Auto-Atualização

O script verifica automaticamente por atualizações no GitHub a cada execução.

**Características:**
- Comparação via MD5 checksum
- Bypass de cache com timestamps
- Indicadores visuais de status:
  - 🆕 NOVO - Arquivo não existia localmente
  - 🔄 ATUALIZADO - Arquivo foi modificado
  - ✓ OK - Arquivo está atualizado
  - ✗ ERRO - Falha no download
  
**Reinício automático:**
Quando o `main.sh` é atualizado, o script reinicia automaticamente após contagem regressiva de 5 segundos.

## Auto-Inicialização

O sistema pode ser configurado para executar automaticamente ao abrir o terminal.

**Como funciona:**
- Cria script em `/etc/profile.d/tcti-proxmox-auto.sh`
- Baixa versão mais recente do `main.sh` a cada login
- Backup automático em caso de falha
- Rollback para versão anterior se download falhar

**Instalação:**
```bash
# Via menu interativo
Menu PVE > Tweaks > Instala script automaticamente > Opção 1

# Manual
bash functions/pve/menu_instala_script.sh
```

**Desinstalação:**
```bash
# Via menu
Menu PVE > Tweaks > Instala script automaticamente > Opção 2

# Manual
rm /etc/profile.d/tcti-proxmox-auto.sh
```

## Migração ao Vivo (Live Migration)

Permite mover VMs entre nodes do cluster sem interrupção de serviço.

**Pré-requisitos:**
- Cluster Proxmox configurado
- Storage compartilhado ou replicado
- Rede de migração configurada
- Recursos suficientes no node destino

**Processo:**
1. Lista VMs disponíveis no node atual
2. Solicita ID da VM a migrar
3. Valida existência e estado da VM
4. Lista nodes disponíveis no cluster
5. Solicita node de destino
6. Verifica recursos no destino
7. Executa migração com `qm migrate`
8. Confirma sucesso da operação

**Segurança:**
- Validação de parâmetros em cada etapa
- Verificação de status antes de migrar
- Rollback automático em falhas
- Logs detalhados de operação

## Desenvolvimento

### Adicionando Novas Funcionalidades

1. Crie um novo arquivo em `functions/pve/` ou `functions/pbs/`
2. Implemente a função seguindo o padrão:

```bash
#!/bin/bash

# Descrição da funcionalidade

minha_funcao() {
    clear
    # Cores e símbolos
    COLOR_CYAN="\033[1;36m"
    COLOR_RESET="\033[0m"
    # ... outras cores
    
    # Header do menu
    echo -e "${COLOR_CYAN}${COLOR_BOLD}"
    echo -e "╔═════════════════════════════════════════════════════════════════════╗"
    echo -e "║                    Título da Funcionalidade                         ║"
    echo -e "╚═════════════════════════════════════════════════════════════════════╝"
    echo -e "${COLOR_RESET}"
    
    # Lógica da função
    # ...
}
```

3. Adicione o arquivo em `main.sh` no array `REQUIRED_FILES`
4. Chame a função no menu apropriado

### Padrões de Código

- Use 4 espaços para indentação
- Prefixe funções auxiliares com o nome do módulo
- Valide todas as entradas do usuário
- Forneça feedback visual para operações longas
- Implemente tratamento de erros
- Adicione confirmações para operações destrutivas

### Cores e Símbolos

```bash
# Cores
COLOR_RESET="\033[0m"
COLOR_BOLD="\033[1m"
COLOR_GREEN="\033[1;32m"
COLOR_BLUE="\033[1;34m"
COLOR_CYAN="\033[1;36m"
COLOR_YELLOW="\033[1;33m"
COLOR_RED="\033[1;31m"
COLOR_MAGENTA="\033[1;35m"
COLOR_WHITE="\033[1;37m"
COLOR_GRAY="\033[1;90m"

# Símbolos
SYMBOL_CHECK="✓"
SYMBOL_ERROR="✗"
SYMBOL_LOADING="🔄"
SYMBOL_INFO="ℹ"
SYMBOL_ARROW="➜"
SYMBOL_NEW="🆕"
SYMBOL_UPDATE="🔄"
```

## Segurança

- Todos os scripts requerem privilégios root
- Validação de entrada do usuário
- Confirmações para operações críticas
- Backup antes de modificações importantes
- Logs de operações realizadas

## Solução de Problemas

### Script não atualiza
```bash
# Força atualização completa
cd /TcTI/SCRIPTS/PROXMOX && rm -f main.sh && curl -sL -o main.sh https://raw.githubusercontent.com/TcTI-BR/PVE-SCRIPTS-V2/main/main.sh && chmod +x main.sh && ./main.sh
```

### Auto-start não funciona
```bash
# Verifica se o arquivo existe
ls -la /etc/profile.d/tcti-proxmox-auto.sh

# Reinstala
bash functions/pve/menu_instala_script.sh
```

### Erro de permissão
```bash
# Garante execução como root
cd /TcTI/SCRIPTS/PROXMOX && bash main.sh

# Corrige permissões de todos os scripts
cd /TcTI/SCRIPTS/PROXMOX && find . -name "*.sh" -exec chmod +x {} \;
```

### Erro de dependências
```bash
# Atualiza sistema
apt update && apt upgrade -y

# Instala dependências mínimas
apt install -y curl
```

## Contribuindo

Contribuições são bem-vindas! 

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/MinhaFeature`)
3. Commit suas mudanças (`git commit -m 'Adiciona MinhaFeature'`)
4. Push para a branch (`git push origin feature/MinhaFeature`)
5. Abra um Pull Request

## Licença

Este projeto é distribuído sob licença livre. Use por sua conta e risco.

## Avisos

- Teste em ambiente não-produção primeiro
- Faça backup antes de modificações críticas
- Leia a documentação do Proxmox para entender os comandos
- O uso é de inteira responsabilidade do usuário

## Suporte

Para reportar bugs ou solicitar features:
- Abra uma issue no GitHub
- Descreva o problema detalhadamente
- Inclua logs e mensagens de erro
- Informe versão do Proxmox e do script

## Changelog

### v2.0
- Refatoração completa da estrutura de código
- Interface modernizada com cores e símbolos
- Sistema de auto-atualização via GitHub
- Suporte para instalação de aplicações terceiras
- Adição do TacticalRMM e Cloudflare Tunnel
- Migração ao vivo de VMs melhorada
- Documentação expandida

### v1.0
- Versão inicial
- Funcionalidades básicas de gerenciamento PVE/PBS

---

Desenvolvido por [TcTI-BR](https://github.com/TcTI-BR)
