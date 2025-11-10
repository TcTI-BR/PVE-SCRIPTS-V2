#!/bin/bash

# Menu de instalação e configuração do Zabbix Agent

ZABBIX_CONFIG_FILE="/etc/zabbix/zabbix_agentd.conf"

# Função para detectar informações do sistema operacional
zabbix_get_os_info() {
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        OS_ID="$ID"
        OS_CODENAME="$VERSION_CODENAME"
        OS_VERSION_ID="$VERSION_ID"
    else
        echo -e "${COLOR_RED}${SYMBOL_ERROR} Não foi possível determinar as informações do SO.${COLOR_RESET}"
        return 1
    fi
    
    if [[ -z "$OS_ID" || -z "$OS_CODENAME" ]]; then
        echo -e "${COLOR_RED}${SYMBOL_ERROR} Falha ao obter informações do SO.${COLOR_RESET}"
        return 1
    fi
    return 0
}

# Função para verificar se o Zabbix Agent está instalado
zabbix_check_installed() {
    if command -v zabbix_agentd &> /dev/null; then
        return 0  # Instalado
    else
        return 1  # Não instalado
    fi
}

# Função para verificar se o serviço está ativo
zabbix_check_service() {
    if systemctl is-active --quiet zabbix-agent 2>/dev/null; then
        return 0  # Ativo
    else
        return 1  # Inativo
    fi
}

# Função para obter o nome do pacote de release do Zabbix
zabbix_get_repo_package_name() {
    local zabbix_ver="$1"
    local os_id="$2"
    local os_codename="$3"
    local pkg_name=""
    
    case "$zabbix_ver" in
        "7.2")
            case "$os_id" in
                ubuntu)
                    case "$os_codename" in
                        noble) pkg_name="zabbix-release_7.2-1+ubuntu24.04_all.deb";;  # Ubuntu 24.04
                        jammy) pkg_name="zabbix-release_7.2-1+ubuntu22.04_all.deb";;  # Ubuntu 22.04
                        focal) pkg_name="zabbix-release_7.2-1+ubuntu20.04_all.deb";;  # Ubuntu 20.04
                        *) return 1;;
                    esac
                    ;;
                debian)
                    case "$os_codename" in
                        trixie) pkg_name="zabbix-release_7.2-1+debian13_all.deb";;    # Debian 13 (Proxmox 9)
                        bookworm) pkg_name="zabbix-release_7.2-1+debian12_all.deb";;  # Debian 12
                        bullseye) pkg_name="zabbix-release_7.2-1+debian11_all.deb";;  # Debian 11
                        *) return 1;;
                    esac
                    ;;
                *) return 1;;
            esac
            ;;
        "7.0")
            case "$os_id" in
                ubuntu)
                    case "$os_codename" in
                        noble) pkg_name="zabbix-release_7.0-2+ubuntu24.04_all.deb";;
                        jammy) pkg_name="zabbix-release_7.0-2+ubuntu22.04_all.deb";;
                        focal) pkg_name="zabbix-release_7.0-2+ubuntu20.04_all.deb";;
                        *) return 1;;
                    esac
                    ;;
                debian)
                    case "$os_codename" in
                        bookworm) pkg_name="zabbix-release_7.0-2+debian12_all.deb";;
                        bullseye) pkg_name="zabbix-release_7.0-2+debian11_all.deb";;
                        *) return 1;;
                    esac
                    ;;
                *) return 1;;
            esac
            ;;
        "6.4")
            case "$os_id" in
                ubuntu)
                    case "$os_codename" in
                        jammy) pkg_name="zabbix-release_6.4-1+ubuntu22.04_all.deb";;
                        focal) pkg_name="zabbix-release_6.4-1+ubuntu20.04_all.deb";;
                        *) return 1;;
                    esac
                    ;;
                debian)
                    case "$os_codename" in
                        bookworm) pkg_name="zabbix-release_6.4-1+debian12_all.deb";;
                        bullseye) pkg_name="zabbix-release_6.4-1+debian11_all.deb";;
                        *) return 1;;
                    esac
                    ;;
                *) return 1;;
            esac
            ;;
        *)
            return 1
            ;;
    esac
    
    echo "$pkg_name"
    return 0
}

# Função para instalar o Zabbix Agent
zabbix_install() {
    clear
    echo -e "${COLOR_CYAN}${COLOR_BOLD}"
    echo -e "╔═════════════════════════════════════════════════════════════════════╗"
    echo -e "║                                                                     ║"
    echo -e "║               📊 Instalação do Zabbix Agent                         ║"
    echo -e "║                                                                     ║"
    echo -e "╚═════════════════════════════════════════════════════════════════════╝"
    echo -e "${COLOR_RESET}"
    echo ""
    
    # Detecta SO
    if ! zabbix_get_os_info; then
        echo ""
        read -p "Pressione ENTER para continuar..."
        instala_zabbix_menu
        return
    fi
    
    echo -e "${COLOR_GREEN}${SYMBOL_CHECK} Sistema: ${COLOR_WHITE}$OS_ID $OS_VERSION_ID ($OS_CODENAME)${COLOR_RESET}"
    echo ""
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
    echo ""
    
    # Seleciona versão do Zabbix
    echo -e "${COLOR_BOLD}Selecione a versão do Zabbix Agent:${COLOR_RESET}"
    echo ""
    echo -e "  ${COLOR_YELLOW}1${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}7.2 LTS${COLOR_RESET} ${COLOR_GRAY}(Recomendado para Proxmox 9)${COLOR_RESET}"
    echo -e "  ${COLOR_YELLOW}2${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}7.0 LTS${COLOR_RESET}"
    echo -e "  ${COLOR_YELLOW}3${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}6.4 Standard${COLOR_RESET}"
    echo -e "  ${COLOR_RED}0${COLOR_RESET} ${COLOR_RED}➜${COLOR_RESET}  ${COLOR_WHITE}Cancelar${COLOR_RESET}"
    echo ""
    read -p "→ " version_choice
    
    case "$version_choice" in
        1) ZABBIX_VERSION="7.2";;
        2) ZABBIX_VERSION="7.0";;
        3) ZABBIX_VERSION="6.4";;
        0|"") 
            echo -e "${COLOR_YELLOW}${SYMBOL_INFO} Instalação cancelada.${COLOR_RESET}"
            sleep 2
            instala_zabbix_menu
            return
            ;;
        *)
            echo -e "${COLOR_RED}${SYMBOL_ERROR} Opção inválida!${COLOR_RESET}"
            sleep 2
            zabbix_install
            return
            ;;
    esac
    
    # Obtém nome do pacote
    REPO_PKG_NAME=$(zabbix_get_repo_package_name "$ZABBIX_VERSION" "$OS_ID" "$OS_CODENAME")
    if [ $? -ne 0 ] || [ -z "$REPO_PKG_NAME" ]; then
        echo ""
        echo -e "${COLOR_RED}${SYMBOL_ERROR} Sistema operacional não suportado para Zabbix $ZABBIX_VERSION${COLOR_RESET}"
        echo -e "${COLOR_YELLOW}Consulte: https://www.zabbix.com/download${COLOR_RESET}"
        echo ""
        read -p "Pressione ENTER para continuar..."
        instala_zabbix_menu
        return
    fi
    
    REPO_URL="https://repo.zabbix.com/zabbix/${ZABBIX_VERSION}/${OS_ID}/pool/main/z/zabbix-release/${REPO_PKG_NAME}"
    
    clear
    echo -e "${COLOR_CYAN}${COLOR_BOLD}"
    echo -e "╔═════════════════════════════════════════════════════════════════════╗"
    echo -e "║                                                                     ║"
    echo -e "║               📊 Configuração do Zabbix Agent                       ║"
    echo -e "║                                                                     ║"
    echo -e "╚═════════════════════════════════════════════════════════════════════╝"
    echo -e "${COLOR_RESET}"
    echo ""
    
    # Solicita IP do servidor
    echo -e "${COLOR_WHITE}IP ou hostname do Zabbix Server:${COLOR_RESET}"
    read -p "→ " ZABBIX_SERVER_IP
    
    while [[ -z "$ZABBIX_SERVER_IP" ]]; do
        echo -e "${COLOR_RED}${SYMBOL_ERROR} IP/hostname não pode estar vazio!${COLOR_RESET}"
        read -p "→ " ZABBIX_SERVER_IP
    done
    
    echo ""
    echo -e "${COLOR_WHITE}Hostname para este agente no Zabbix:${COLOR_RESET}"
    echo -e "${COLOR_GRAY}(Sugestão: $(hostname))${COLOR_RESET}"
    read -p "→ " ZABBIX_AGENT_HOSTNAME
    
    while [[ -z "$ZABBIX_AGENT_HOSTNAME" ]]; do
        echo -e "${COLOR_RED}${SYMBOL_ERROR} Hostname não pode estar vazio!${COLOR_RESET}"
        read -p "→ " ZABBIX_AGENT_HOSTNAME
    done
    
    # Confirmação
    echo ""
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
    echo -e "${COLOR_MAGENTA}${COLOR_BOLD}📋 Resumo da Instalação:${COLOR_RESET}"
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
    echo ""
    echo -e "  ${COLOR_YELLOW}Versão:${COLOR_RESET}         Zabbix Agent ${COLOR_WHITE}$ZABBIX_VERSION LTS${COLOR_RESET}"
    echo -e "  ${COLOR_YELLOW}Sistema:${COLOR_RESET}        ${COLOR_WHITE}$OS_ID $OS_VERSION_ID ($OS_CODENAME)${COLOR_RESET}"
    echo -e "  ${COLOR_YELLOW}Server:${COLOR_RESET}         ${COLOR_WHITE}$ZABBIX_SERVER_IP${COLOR_RESET}"
    echo -e "  ${COLOR_YELLOW}Hostname:${COLOR_RESET}       ${COLOR_WHITE}$ZABBIX_AGENT_HOSTNAME${COLOR_RESET}"
    echo ""
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
    echo ""
    echo -e "${COLOR_YELLOW}Confirmar instalação?${COLOR_RESET} (${COLOR_GREEN}s${COLOR_RESET}/${COLOR_RED}n${COLOR_RESET})"
    read -p "→ " CONFIRM
    
    if [[ ! "$CONFIRM" =~ ^[Ss]$ ]]; then
        echo ""
        echo -e "${COLOR_YELLOW}${SYMBOL_INFO} Instalação cancelada.${COLOR_RESET}"
        sleep 2
        instala_zabbix_menu
        return
    fi
    
    # Inicia instalação
    echo ""
    echo -e "${COLOR_YELLOW}${SYMBOL_LOADING} Iniciando instalação...${COLOR_RESET}"
    echo ""
    
    # Baixa pacote de release
    echo -e "${COLOR_BLUE}${SYMBOL_INFO} Baixando repositório Zabbix...${COLOR_RESET}"
    if ! wget -q "$REPO_URL" -O /tmp/"$REPO_PKG_NAME" 2>/dev/null; then
        echo -e "${COLOR_RED}${SYMBOL_ERROR} Erro ao baixar repositório!${COLOR_RESET}"
        echo ""
        read -p "Pressione ENTER para continuar..."
        instala_zabbix_menu
        return
    fi
    
    # Instala pacote de release
    echo -e "${COLOR_BLUE}${SYMBOL_INFO} Instalando repositório...${COLOR_RESET}"
    dpkg -i /tmp/"$REPO_PKG_NAME" >/dev/null 2>&1
    rm -f /tmp/"$REPO_PKG_NAME"
    
    # Atualiza lista de pacotes
    echo -e "${COLOR_BLUE}${SYMBOL_INFO} Atualizando lista de pacotes...${COLOR_RESET}"
    apt update >/dev/null 2>&1
    
    # Instala Zabbix Agent
    echo -e "${COLOR_BLUE}${SYMBOL_INFO} Instalando Zabbix Agent $ZABBIX_VERSION...${COLOR_RESET}"
    if ! apt install -y zabbix-agent >/dev/null 2>&1; then
        echo -e "${COLOR_RED}${SYMBOL_ERROR} Erro ao instalar Zabbix Agent!${COLOR_RESET}"
        echo ""
        read -p "Pressione ENTER para continuar..."
        instala_zabbix_menu
        return
    fi
    
    # Configura
    echo -e "${COLOR_BLUE}${SYMBOL_INFO} Configurando Zabbix Agent...${COLOR_RESET}"
    if [ -f "$ZABBIX_CONFIG_FILE" ]; then
        sed -i "s/^Server=.*/Server=${ZABBIX_SERVER_IP}/" "$ZABBIX_CONFIG_FILE"
        sed -i "s/^ServerActive=.*/ServerActive=${ZABBIX_SERVER_IP}/" "$ZABBIX_CONFIG_FILE"
        sed -i "s/^Hostname=.*/Hostname=${ZABBIX_AGENT_HOSTNAME}/" "$ZABBIX_CONFIG_FILE"
        sed -i "s/^# HostnameItem=system.hostname/#HostnameItem=system.hostname/" "$ZABBIX_CONFIG_FILE"
        sed -i "s/^HostnameItem=system.hostname/#HostnameItem=system.hostname/" "$ZABBIX_CONFIG_FILE"
    fi
    
    # Reinicia e habilita serviço
    echo -e "${COLOR_BLUE}${SYMBOL_INFO} Iniciando serviço...${COLOR_RESET}"
    systemctl restart zabbix-agent >/dev/null 2>&1
    systemctl enable zabbix-agent >/dev/null 2>&1
    
    echo ""
    echo -e "${COLOR_GREEN}${SYMBOL_CHECK} Zabbix Agent instalado e configurado com sucesso!${COLOR_RESET}"
    echo ""
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
    echo -e "${COLOR_YELLOW}${COLOR_BOLD}Próximos passos:${COLOR_RESET}"
    echo -e "  ${COLOR_WHITE}1.${COLOR_RESET} Adicione o host no Zabbix Server"
    echo -e "  ${COLOR_WHITE}2.${COLOR_RESET} Use o hostname: ${COLOR_CYAN}$ZABBIX_AGENT_HOSTNAME${COLOR_RESET}"
    echo -e "  ${COLOR_WHITE}3.${COLOR_RESET} Configure os templates desejados"
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
    echo ""
    read -p "Pressione ENTER para continuar..."
    instala_zabbix_menu
}

# Função para remover o Zabbix Agent
zabbix_remove() {
    clear
    echo -e "${COLOR_RED}${COLOR_BOLD}"
    echo -e "╔═════════════════════════════════════════════════════════════════════╗"
    echo -e "║                                                                     ║"
    echo -e "║               ⚠️  Remover Zabbix Agent                              ║"
    echo -e "║                                                                     ║"
    echo -e "╚═════════════════════════════════════════════════════════════════════╝"
    echo -e "${COLOR_RESET}"
    echo ""
    
    echo -e "${COLOR_YELLOW}${COLOR_BOLD}ATENÇÃO:${COLOR_RESET}"
    echo -e "${COLOR_YELLOW}• Isso removerá completamente o Zabbix Agent${COLOR_RESET}"
    echo -e "${COLOR_YELLOW}• Todas as configurações serão perdidas${COLOR_RESET}"
    echo -e "${COLOR_YELLOW}• O serviço será parado e desabilitado${COLOR_RESET}"
    echo ""
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
    echo ""
    
    echo -e "${COLOR_RED}${COLOR_BOLD}Confirmar remoção?${COLOR_RESET} (${COLOR_GREEN}s${COLOR_RESET}/${COLOR_RED}n${COLOR_RESET})"
    read -p "→ " CONFIRM
    
    if [[ ! "$CONFIRM" =~ ^[Ss]$ ]]; then
        echo ""
        echo -e "${COLOR_YELLOW}${SYMBOL_INFO} Remoção cancelada.${COLOR_RESET}"
        sleep 2
        instala_zabbix_menu
        return
    fi
    
    echo ""
    echo -e "${COLOR_YELLOW}${SYMBOL_LOADING} Removendo Zabbix Agent...${COLOR_RESET}"
    echo ""
    
    # Para e desabilita serviço
    echo -e "${COLOR_BLUE}${SYMBOL_INFO} Parando serviço...${COLOR_RESET}"
    systemctl stop zabbix-agent >/dev/null 2>&1
    systemctl disable zabbix-agent >/dev/null 2>&1
    
    # Remove pacotes
    echo -e "${COLOR_BLUE}${SYMBOL_INFO} Removendo pacotes...${COLOR_RESET}"
    apt purge -y zabbix-agent zabbix-release >/dev/null 2>&1
    
    # Remove diretório de configuração
    echo -e "${COLOR_BLUE}${SYMBOL_INFO} Removendo configurações...${COLOR_RESET}"
    rm -rf /etc/zabbix 2>/dev/null
    
    # Limpa dependências
    echo -e "${COLOR_BLUE}${SYMBOL_INFO} Limpando dependências...${COLOR_RESET}"
    apt autoremove -y >/dev/null 2>&1
    apt update >/dev/null 2>&1
    
    echo ""
    echo -e "${COLOR_GREEN}${SYMBOL_CHECK} Zabbix Agent removido com sucesso!${COLOR_RESET}"
    echo ""
    read -p "Pressione ENTER para continuar..."
    instala_zabbix_menu
}

# Menu principal
instala_zabbix_menu() {
    clear
    NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"`
    NUMBER=`echo "\033[33m"`
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
    ENTER_LINE=`echo "\033[33m"`
    
    echo -e "${COLOR_CYAN}${COLOR_BOLD}"
    echo -e "╔═════════════════════════════════════════════════════════════════════╗"
    echo -e "║                                                                     ║"
    echo -e "║                 📊 Gerenciador Zabbix Agent                         ║"
    echo -e "║                                                                     ║"
    echo -e "╚═════════════════════════════════════════════════════════════════════╝"
    echo -e "${COLOR_RESET}"
    echo ""
    
    # Status da instalação
    echo -e "${COLOR_BOLD}  Status:${COLOR_RESET}"
    echo ""
    if zabbix_check_installed; then
        ZABBIX_VERSION=$(zabbix_agentd -V 2>/dev/null | head -n 1 | awk '{print $NF}')
        echo -e "  ${COLOR_GREEN}${SYMBOL_CHECK} Zabbix Agent instalado${COLOR_RESET} ${COLOR_GRAY}(v$ZABBIX_VERSION)${COLOR_RESET}"
        
        if zabbix_check_service; then
            echo -e "  ${COLOR_GREEN}${SYMBOL_CHECK} Serviço ativo e rodando${COLOR_RESET}"
        else
            echo -e "  ${COLOR_YELLOW}${SYMBOL_INFO} Serviço parado${COLOR_RESET}"
        fi
        
        # Mostra configurações atuais
        if [ -f "$ZABBIX_CONFIG_FILE" ]; then
            CURRENT_SERVER=$(grep "^Server=" "$ZABBIX_CONFIG_FILE" | cut -d'=' -f2)
            CURRENT_HOSTNAME=$(grep "^Hostname=" "$ZABBIX_CONFIG_FILE" | cut -d'=' -f2)
            if [ -n "$CURRENT_SERVER" ]; then
                echo -e "  ${COLOR_CYAN}${SYMBOL_INFO} Server: ${COLOR_WHITE}$CURRENT_SERVER${COLOR_RESET}"
            fi
            if [ -n "$CURRENT_HOSTNAME" ]; then
                echo -e "  ${COLOR_CYAN}${SYMBOL_INFO} Hostname: ${COLOR_WHITE}$CURRENT_HOSTNAME${COLOR_RESET}"
            fi
        fi
    else
        echo -e "  ${COLOR_RED}${SYMBOL_ERROR} Zabbix Agent não instalado${COLOR_RESET}"
    fi
    
    echo ""
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
    echo ""
    echo -e "${COLOR_BOLD}  Selecione uma opção:${COLOR_RESET}"
    echo ""
    echo -e "  ${COLOR_CYAN}┌───────────────────────────────────────────────────────────────┐${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                               ${COLOR_CYAN}│${COLOR_RESET}"
    
    # Opção 1 - Instalar (desabilitada se já instalado)
    if zabbix_check_installed; then
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_GRAY}1 ➜  Instalar/Configurar Zabbix Agent${COLOR_RESET} ${COLOR_GRAY}(já instalado)${COLOR_RESET}  ${COLOR_CYAN}│${COLOR_RESET}"
    else
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}1${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Instalar/Configurar Zabbix Agent${COLOR_RESET}                    ${COLOR_CYAN}│${COLOR_RESET}"
    fi
    
    # Opção 2 - Remover (requer instalação)
    if zabbix_check_installed; then
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}2${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Remover Zabbix Agent${COLOR_RESET}                                ${COLOR_CYAN}│${COLOR_RESET}"
    else
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_GRAY}2 ➜  Remover Zabbix Agent${COLOR_RESET} ${COLOR_GRAY}(requer instalação)${COLOR_RESET}          ${COLOR_CYAN}│${COLOR_RESET}"
    fi
    
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                               ${COLOR_CYAN}│${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_RED}0${COLOR_RESET} ${COLOR_RED}➜${COLOR_RESET}  ${COLOR_WHITE}Voltar${COLOR_RESET}                                              ${COLOR_CYAN}│${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                               ${COLOR_CYAN}│${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}└───────────────────────────────────────────────────────────────┘${COLOR_RESET}"
    echo ""
    echo -e "${COLOR_YELLOW}  Digite sua opção ${COLOR_GRAY}(ou pressione ENTER para sair)${COLOR_YELLOW}: ${COLOR_RESET}"
    read -rsn1 opt
    
    while [ opt != '' ]
    do
        if [[ $opt = "" ]]; then
            instala_aplicativos_menu
        else
            case $opt in
                1)
                    if zabbix_check_installed; then
                        clear
                        echo -e "${COLOR_YELLOW}${SYMBOL_INFO} Zabbix Agent já está instalado!${COLOR_RESET}"
                        echo -e "${COLOR_YELLOW}${SYMBOL_INFO} Para reinstalar, remova primeiro.${COLOR_RESET}"
                        sleep 3
                        instala_zabbix_menu
                    else
                        clear
                        zabbix_install
                    fi
                    ;;
                2)
                    if zabbix_check_installed; then
                        clear
                        zabbix_remove
                    else
                        clear
                        echo -e "${COLOR_RED}${SYMBOL_ERROR} Zabbix Agent não está instalado!${COLOR_RESET}"
                        sleep 2
                        instala_zabbix_menu
                    fi
                    ;;
                0)
                    clear
                    instala_aplicativos_menu
                    ;;
                *)
                    clear
                    instala_aplicativos_menu
                    ;;
            esac
        fi
    done
}

