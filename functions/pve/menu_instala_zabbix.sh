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

# Função para obter o nome do pacote e URL de release do Zabbix
zabbix_get_repo_package_name() {
    local zabbix_ver="$1"
    local os_codename="$3"
    local pkg_name=""
    local debian_ver=""
    
    # Mapeia codename para número do Debian
    case "$os_codename" in
        trixie) debian_ver="13";;      # Proxmox 9
        bookworm) debian_ver="12";;    # Proxmox 8
        bullseye) debian_ver="11";;    # Proxmox 7
        buster) debian_ver="10";;      # Proxmox 6
        stretch) debian_ver="9";;      # Proxmox 5
        *) return 1;;
    esac
    
    # Estrutura: zabbix-release_latest_X.X+debianYY_all.deb
    case "$zabbix_ver" in
        "8.0")
            pkg_name="zabbix-release_latest_8.0+debian${debian_ver}_all.deb"
            ;;
        "7.4")
            pkg_name="zabbix-release_latest_7.4+debian${debian_ver}_all.deb"
            ;;
        "7.2")
            pkg_name="zabbix-release_latest_7.2+debian${debian_ver}_all.deb"
            ;;
        "7.0")
            pkg_name="zabbix-release_latest_7.0+debian${debian_ver}_all.deb"
            ;;
        "6.0")
            pkg_name="zabbix-release_latest_6.0+debian${debian_ver}_all.deb"
            ;;
        *)
            return 1
            ;;
    esac
    
    echo "$pkg_name"
    return 0
}

# Função para obter a URL base do repositório (algumas usam /release/, outras não)
zabbix_get_repo_base_url() {
    local zabbix_ver="$1"
    
    case "$zabbix_ver" in
        "8.0"|"7.4"|"7.2")
            echo "https://repo.zabbix.com/zabbix/${zabbix_ver}/release/debian/pool/main/z/zabbix-release"
            ;;
        "7.0"|"6.0")
            echo "https://repo.zabbix.com/zabbix/${zabbix_ver}/debian/pool/main/z/zabbix-release"
            ;;
        *)
            return 1
            ;;
    esac
    return 0
}

# Função para instalar o Zabbix Agent
zabbix_install() {
    clear
    echo -e "${COLOR_CYAN}${COLOR_BOLD}"
    echo -e "╔═════════════════════════════════════════════════════════════════════╗"
    echo -e "║                                                                     ║"
    echo -e "║               📊 Instalação do Zabbix Agent                          ║"
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
    echo -e "  ${COLOR_YELLOW}1${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}8.0${COLOR_RESET} ${COLOR_GRAY}(PRE-RELEASE)${COLOR_RESET}"
    echo -e "  ${COLOR_YELLOW}2${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}7.4${COLOR_RESET}"
    echo -e "  ${COLOR_YELLOW}3${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}7.2${COLOR_RESET}"
    echo -e "  ${COLOR_YELLOW}4${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}7.0 LTS${COLOR_RESET}"
    echo -e "  ${COLOR_YELLOW}5${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}6.0 LTS${COLOR_RESET}"
    echo -e "  ${COLOR_RED}0${COLOR_RESET} ${COLOR_RED}➜${COLOR_RESET}  ${COLOR_WHITE}Cancelar${COLOR_RESET}"
    echo ""
    read -p "→ " version_choice
    
    case "$version_choice" in
        1) ZABBIX_VERSION="8.0";;
        2) ZABBIX_VERSION="7.4";;
        3) ZABBIX_VERSION="7.2";;
        4) ZABBIX_VERSION="7.0";;
        5) ZABBIX_VERSION="6.0";;
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
    
    # Obtém nome do pacote e URL base
    REPO_PKG_NAME=$(zabbix_get_repo_package_name "$ZABBIX_VERSION" "$OS_ID" "$OS_CODENAME")
    if [ $? -ne 0 ] || [ -z "$REPO_PKG_NAME" ]; then
        echo ""
        echo -e "${COLOR_RED}${SYMBOL_ERROR} Sistema operacional não suportado para Zabbix $ZABBIX_VERSION${COLOR_RESET}"
        echo -e "${COLOR_YELLOW}Sistema: $OS_ID $OS_VERSION_ID ($OS_CODENAME)${COLOR_RESET}"
        echo -e "${COLOR_YELLOW}Consulte: https://www.zabbix.com/download${COLOR_RESET}"
        echo ""
        read -p "Pressione ENTER para continuar..."
        instala_zabbix_menu
        return
    fi
    
    REPO_BASE_URL=$(zabbix_get_repo_base_url "$ZABBIX_VERSION")
    if [ $? -ne 0 ] || [ -z "$REPO_BASE_URL" ]; then
        echo ""
        echo -e "${COLOR_RED}${SYMBOL_ERROR} Erro ao determinar URL do repositório${COLOR_RESET}"
        echo ""
        read -p "Pressione ENTER para continuar..."
        instala_zabbix_menu
        return
    fi
    
    REPO_URL="${REPO_BASE_URL}/${REPO_PKG_NAME}"
    
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
    # Determina label da versão
    local VERSION_LABEL="$ZABBIX_VERSION"
    case "$ZABBIX_VERSION" in
        "8.0") VERSION_LABEL="$ZABBIX_VERSION Latest";;
        "7.4"|"7.2"|"7.0"|"6.0") VERSION_LABEL="$ZABBIX_VERSION LTS";;
    esac
    
    # Determina nome amigável do Proxmox
    local PROXMOX_NAME=""
    case "$OS_CODENAME" in
        trixie) PROXMOX_NAME=" / Proxmox VE 9";;
        bookworm) PROXMOX_NAME=" / Proxmox VE 8";;
        bullseye) PROXMOX_NAME=" / Proxmox VE 7";;
        buster) PROXMOX_NAME=" / Proxmox VE 6";;
    esac
    
    echo -e "${COLOR_MAGENTA}${COLOR_BOLD}📋 Resumo da Instalação:${COLOR_RESET}"
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
    echo ""
    echo -e "  ${COLOR_YELLOW}Versão:${COLOR_RESET}         Zabbix Agent ${COLOR_WHITE}$VERSION_LABEL${COLOR_RESET}"
    echo -e "  ${COLOR_YELLOW}Sistema:${COLOR_RESET}        ${COLOR_WHITE}Debian $OS_VERSION_ID ($OS_CODENAME)${PROXMOX_NAME}${COLOR_RESET}"
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
    echo -e "${COLOR_BLUE}${SYMBOL_INFO} Baixando repositório Zabbix $ZABBIX_VERSION...${COLOR_RESET}"
    if ! wget -q "$REPO_URL" -O /tmp/"$REPO_PKG_NAME" 2>/dev/null; then
        echo -e "${COLOR_RED}${SYMBOL_ERROR} Erro ao baixar repositório!${COLOR_RESET}"
        echo -e "${COLOR_GRAY}URL: $REPO_URL${COLOR_RESET}"
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
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_GRAY}1 ➜  Instalar/Configurar Zabbix Agent${COLOR_RESET} ${COLOR_GRAY}(já instalado)${COLOR_RESET}      ${COLOR_CYAN}│${COLOR_RESET}"
    else
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}1${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Instalar/Configurar Zabbix Agent${COLOR_RESET}                          ${COLOR_CYAN}│${COLOR_RESET}"
    fi
    
    # Opção 2 - Remover (requer instalação)
    if zabbix_check_installed; then
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}2${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Remover Zabbix Agent${COLOR_RESET}                                ${COLOR_CYAN}│${COLOR_RESET}"
    else
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_GRAY}2 ➜  Remover Zabbix Agent${COLOR_RESET} ${COLOR_GRAY}(requer instalação)${COLOR_RESET}                ${COLOR_CYAN}│${COLOR_RESET}"
    fi
    
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                               ${COLOR_CYAN}│${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_RED}0${COLOR_RESET} ${COLOR_RED}➜${COLOR_RESET}  ${COLOR_WHITE}Voltar${COLOR_RESET}                                                  ${COLOR_CYAN}│${COLOR_RESET}"
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

