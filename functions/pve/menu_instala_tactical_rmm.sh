#!/bin/bash

# Script de Gerenciamento Interativo para TacticalRMM
# Adaptado ao padrão visual moderno do projeto

# Configurações
INSTALL_DIR="/TcTI/TRMM"
SCRIPT_URL="https://raw.githubusercontent.com/netvolt/LinuxRMM-Script/main/rmmagent-linux.sh"
SCRIPT_NAME="rmmagent-linux.sh"
SCRIPT_PATH="$INSTALL_DIR/$SCRIPT_NAME"

# Função auxiliar para preparar ambiente
trmm_preparar_ambiente() {
    echo -e "${COLOR_CYAN}${SYMBOL_LOADING} Preparando o ambiente...${COLOR_RESET}"
    echo ""
    
    # Verifica e instala dependências
    echo -e "${COLOR_BLUE}${SYMBOL_INFO} Verificando dependências (wget, unzip)...${COLOR_RESET}"
    if ! command -v wget &> /dev/null || ! command -v unzip &> /dev/null; then
        apt update
        apt install wget unzip -y
    fi
    echo -e "${COLOR_GREEN}${SYMBOL_CHECK} Dependências OK${COLOR_RESET}"
    echo ""
    
    # Cria diretório de instalação
    mkdir -p "$INSTALL_DIR"
    
    # Baixa o script do RMM
    if [ ! -f "$SCRIPT_PATH" ] || [ "$1" == "force" ]; then
        echo -e "${COLOR_BLUE}${SYMBOL_LOADING} Baixando script 'rmmagent-linux.sh'...${COLOR_RESET}"
        wget -O "$SCRIPT_PATH" "$SCRIPT_URL"
        chmod +x "$SCRIPT_PATH"
        echo -e "${COLOR_GREEN}${SYMBOL_CHECK} Download concluído${COLOR_RESET}"
    else
        echo -e "${COLOR_GREEN}${SYMBOL_CHECK} Script 'rmmagent-linux.sh' já existe${COLOR_RESET}"
        chmod +x "$SCRIPT_PATH"
    fi
    echo ""
    
    cd "$INSTALL_DIR" || exit 1
}

# Função para INSTALAR o agente
trmm_instalar_agente() {
    clear
    echo -e "${COLOR_CYAN}${COLOR_BOLD}"
    echo -e "╔════════════════════════════════════════════════════════════════════╗"
    echo -e "║        🚀 Assistente de Instalação - TacticalRMM Agent             ║"
    echo -e "╚════════════════════════════════════════════════════════════════════╝"
    echo -e "${COLOR_RESET}"
    echo ""
    echo -e "${COLOR_YELLOW}Por favor, insira as informações do seu painel RMM:${COLOR_RESET}"
    echo ""
    
    # Solicita parâmetros
    echo -e "${COLOR_WHITE}1.${COLOR_RESET} Insira a URL do ${COLOR_CYAN}Mesh agent${COLOR_RESET} (com aspas simples):"
    read -p "   → " MESH_URL
    
    echo -e "${COLOR_WHITE}2.${COLOR_RESET} Insira a ${COLOR_CYAN}API URL${COLOR_RESET} (ex: https://api.example.com):"
    read -p "   → " API_URL
    
    echo -e "${COLOR_WHITE}3.${COLOR_RESET} Insira o ${COLOR_CYAN}Client ID${COLOR_RESET} (numérico):"
    read -p "   → " CLIENT_ID
    
    echo -e "${COLOR_WHITE}4.${COLOR_RESET} Insira o ${COLOR_CYAN}Site ID${COLOR_RESET} (numérico):"
    read -p "   → " SITE_ID
    
    echo -e "${COLOR_WHITE}5.${COLOR_RESET} Insira a ${COLOR_CYAN}Auth Key${COLOR_RESET} (chave longa):"
    read -p "   → " AUTH_KEY
    
    echo -e "${COLOR_WHITE}6.${COLOR_RESET} Insira o ${COLOR_CYAN}Agent Type${COLOR_RESET} (server/workstation) [Padrão: ${COLOR_GREEN}server${COLOR_RESET}]:"
    read -p "   → " AGENT_TYPE
    AGENT_TYPE=${AGENT_TYPE:-server}
    
    # Revisão
    echo ""
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
    echo -e "${COLOR_BOLD}📋 Revisão das Informações:${COLOR_RESET}"
    echo ""
    echo -e "  ${COLOR_WHITE}Mesh URL:${COLOR_RESET}    \"${COLOR_CYAN}$MESH_URL${COLOR_RESET}\""
    echo -e "  ${COLOR_WHITE}API URL:${COLOR_RESET}     \"${COLOR_CYAN}$API_URL${COLOR_RESET}\""
    echo -e "  ${COLOR_WHITE}Client ID:${COLOR_RESET}   ${COLOR_CYAN}$CLIENT_ID${COLOR_RESET}"
    echo -e "  ${COLOR_WHITE}Site ID:${COLOR_RESET}     ${COLOR_CYAN}$SITE_ID${COLOR_RESET}"
    echo -e "  ${COLOR_WHITE}Auth Key:${COLOR_RESET}    \"${COLOR_CYAN}$AUTH_KEY${COLOR_RESET}\""
    echo -e "  ${COLOR_WHITE}Agent Type:${COLOR_RESET}  ${COLOR_CYAN}$AGENT_TYPE${COLOR_RESET}"
    echo ""
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
    echo ""
    
    # Exibe o comando que será executado (em uma única linha)
    echo -e "${COLOR_MAGENTA}${COLOR_BOLD}🔧 Comando que será executado:${COLOR_RESET}"
    echo -e "${COLOR_GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
    echo ""
    echo "./$SCRIPT_NAME install \"$MESH_URL\" \"$API_URL\" $CLIENT_ID $SITE_ID \"$AUTH_KEY\" $AGENT_TYPE"
    echo ""
    echo -e "${COLOR_GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
    echo ""
    
    echo -e "${COLOR_YELLOW}As informações estão corretas?${COLOR_RESET} (${COLOR_GREEN}s${COLOR_RESET}/${COLOR_RED}n${COLOR_RESET})"
    read -p "→ " CONFIRM
    
    if [[ "$CONFIRM" =~ ^[Ss]$ ]]; then
        echo ""
        trmm_preparar_ambiente
        
        echo -e "${COLOR_YELLOW}${SYMBOL_LOADING} Executando instalação... ${COLOR_GRAY}(Isso pode demorar alguns minutos)${COLOR_RESET}"
        echo ""
        
        ./"$SCRIPT_NAME" install "$MESH_URL" "$API_URL" "$CLIENT_ID" "$SITE_ID" "$AUTH_KEY" "$AGENT_TYPE"
        
        echo ""
        echo -e "${COLOR_GREEN}${SYMBOL_CHECK} Instalação concluída!${COLOR_RESET}"
    else
        echo ""
        echo -e "${COLOR_RED}${SYMBOL_ERROR} Instalação abortada pelo usuário.${COLOR_RESET}"
    fi
    
    echo ""
    read -p "Pressione ENTER para continuar..."
    instala_tactical_rmm_menu
}

# Função para DESINSTALAR o agente
trmm_desinstalar_agente() {
    clear
    echo -e "${COLOR_RED}${COLOR_BOLD}"
    echo -e "╔════════════════════════════════════════════════════════════════════╗"
    echo -e "║        ⚠️  Assistente de Desinstalação - TacticalRMM Agent         ║"
    echo -e "╚════════════════════════════════════════════════════════════════════╝"
    echo -e "${COLOR_RESET}"
    echo ""
    echo -e "${COLOR_YELLOW}${COLOR_BOLD}ATENÇÃO:${COLOR_RESET}"
    echo -e "${COLOR_YELLOW}• Isso remove o agente da máquina${COLOR_RESET}"
    echo -e "${COLOR_YELLOW}• O agente ${COLOR_RED}NÃO${COLOR_YELLOW} será removido do painel RMM${COLOR_RESET}"
    echo -e "${COLOR_YELLOW}• Você terá que removê-lo ${COLOR_WHITE}manualmente${COLOR_YELLOW} no painel${COLOR_RESET}"
    echo ""
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
    echo ""
    
    # Solicita parâmetros
    echo -e "${COLOR_WHITE}1.${COLOR_RESET} Insira o ${COLOR_CYAN}Mesh FQDN${COLOR_RESET} (ex: mesh.example.com):"
    read -p "   → " MESH_FQDN
    
    echo -e "${COLOR_WHITE}2.${COLOR_RESET} Insira o ${COLOR_CYAN}Mesh ID${COLOR_RESET} (chave longa de 64 caracteres):"
    read -p "   → " MESH_ID
    
    # Revisão
    echo ""
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
    echo -e "${COLOR_BOLD}📋 Revisão das Informações:${COLOR_RESET}"
    echo ""
    echo -e "  ${COLOR_WHITE}Mesh FQDN:${COLOR_RESET}  ${COLOR_CYAN}$MESH_FQDN${COLOR_RESET}"
    echo -e "  ${COLOR_WHITE}Mesh ID:${COLOR_RESET}    ${COLOR_CYAN}$MESH_ID${COLOR_RESET}"
    echo ""
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
    echo ""
    
    # Exibe o comando que será executado (em uma única linha)
    echo -e "${COLOR_MAGENTA}${COLOR_BOLD}🔧 Comando que será executado:${COLOR_RESET}"
    echo -e "${COLOR_GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
    echo ""
    echo "./$SCRIPT_NAME uninstall \"$MESH_FQDN\" \"$MESH_ID\""
    echo ""
    echo -e "${COLOR_GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
    echo ""
    
    echo -e "${COLOR_RED}${COLOR_BOLD}Confirmar desinstalação?${COLOR_RESET} (${COLOR_GREEN}s${COLOR_RESET}/${COLOR_RED}n${COLOR_RESET})"
    read -p "→ " CONFIRM
    
    if [[ "$CONFIRM" =~ ^[Ss]$ ]]; then
        echo ""
        trmm_preparar_ambiente
        
        echo -e "${COLOR_YELLOW}${SYMBOL_LOADING} Executando desinstalação...${COLOR_RESET}"
        echo ""
        
        ./"$SCRIPT_NAME" uninstall "$MESH_FQDN" "$MESH_ID"
        
        echo ""
        echo -e "${COLOR_GREEN}${SYMBOL_CHECK} Desinstalação concluída!${COLOR_RESET}"
    else
        echo ""
        echo -e "${COLOR_YELLOW}${SYMBOL_INFO} Desinstalação abortada pelo usuário.${COLOR_RESET}"
    fi
    
    echo ""
    read -p "Pressione ENTER para continuar..."
    instala_tactical_rmm_menu
}

# Menu principal
instala_tactical_rmm_menu() {
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
    echo -e "║             📡 Gerenciador de Agente TacticalRMM                    ║"
    echo -e "║                                                                     ║"
    echo -e "╚═════════════════════════════════════════════════════════════════════╝"
    echo -e "${COLOR_RESET}"
    echo ""
    echo -e "${COLOR_BOLD}  Selecione uma opção:${COLOR_RESET}"
    echo ""
    echo -e "  ${COLOR_CYAN}┌───────────────────────────────────────────────────────────────┐${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                               ${COLOR_CYAN}│${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}1${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Instalar novo agente${COLOR_RESET}                              ${COLOR_CYAN}│${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}2${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Desinstalar agente existente${COLOR_RESET}                      ${COLOR_CYAN}│${COLOR_RESET}"
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
                1) clear;
                   trmm_instalar_agente
                   ;;
                2) clear;
                   trmm_desinstalar_agente
                   ;;
                0) clear;
                   instala_aplicativos_menu
                   ;;
                *) clear;
                   instala_aplicativos_menu
                   ;;
            esac
        fi
    done
}

