#!/bin/bash

# Menu de instalação e configuração do Cloudflared

# Função auxiliar para verificar se cloudflared está instalado
cloudflared_check_installed() {
    if command -v cloudflared &> /dev/null; then
        return 0  # Instalado
    else
        return 1  # Não instalado
    fi
}

# Função auxiliar para verificar se o serviço está configurado
cloudflared_check_service() {
    if systemctl is-enabled cloudflared &> /dev/null; then
        return 0  # Serviço configurado
    else
        return 1  # Serviço não configurado
    fi
}

# Função para instalar cloudflared
cloudflared_install() {
    clear
    echo -e "${COLOR_CYAN}${COLOR_BOLD}"
    echo -e "╔═════════════════════════════════════════════════════════════════════╗"
    echo -e "║                                                                     ║"
    echo -e "║              ☁️  Instalação do Cloudflare Tunnel                    ║"
    echo -e "║                                                                     ║"
    echo -e "╚═════════════════════════════════════════════════════════════════════╝"
    echo -e "${COLOR_RESET}"
    echo ""
    
    echo -e "${COLOR_YELLOW}${SYMBOL_LOADING} Iniciando instalação do Cloudflared...${COLOR_RESET}"
    echo ""
    
    # Cria diretório para as chaves
    echo -e "${COLOR_BLUE}${SYMBOL_INFO} Criando diretório de chaves...${COLOR_RESET}"
    mkdir -p --mode=0755 /usr/share/keyrings
    
    # Baixa a chave GPG do Cloudflare
    echo -e "${COLOR_BLUE}${SYMBOL_INFO} Baixando chave GPG do Cloudflare...${COLOR_RESET}"
    curl -fsSL https://pkg.cloudflare.com/cloudflare-public-v2.gpg | tee /usr/share/keyrings/cloudflare-public-v2.gpg >/dev/null
    
    # Adiciona o repositório
    echo -e "${COLOR_BLUE}${SYMBOL_INFO} Adicionando repositório...${COLOR_RESET}"
    echo 'deb [signed-by=/usr/share/keyrings/cloudflare-public-v2.gpg] https://pkg.cloudflare.com/cloudflared any main' | tee /etc/apt/sources.list.d/cloudflared.list
    
    # Atualiza e instala
    echo -e "${COLOR_BLUE}${SYMBOL_INFO} Atualizando lista de pacotes...${COLOR_RESET}"
    apt-get update
    
    echo -e "${COLOR_BLUE}${SYMBOL_INFO} Instalando cloudflared...${COLOR_RESET}"
    apt-get install cloudflared -y
    
    if cloudflared_check_installed; then
        echo ""
        echo -e "${COLOR_GREEN}${SYMBOL_CHECK} Cloudflared instalado com sucesso!${COLOR_RESET}"
    else
        echo ""
        echo -e "${COLOR_RED}${SYMBOL_ERROR} Erro na instalação do Cloudflared!${COLOR_RESET}"
    fi
    
    echo ""
    read -p "Pressione ENTER para continuar..."
    instala_cloudflared_menu
}

# Função para configurar o serviço
cloudflared_configure_service() {
    clear
    echo -e "${COLOR_CYAN}${COLOR_BOLD}"
    echo -e "╔═════════════════════════════════════════════════════════════════════╗"
    echo -e "║                                                                     ║"
    echo -e "║           🔧 Configuração do Serviço Cloudflare Tunnel              ║"
    echo -e "║                                                                     ║"
    echo -e "╚═════════════════════════════════════════════════════════════════════╝"
    echo -e "${COLOR_RESET}"
    echo ""
    
    echo -e "${COLOR_YELLOW}Para configurar o túnel, você precisa da chave fornecida pelo Cloudflare.${COLOR_RESET}"
    echo ""
    echo -e "${COLOR_WHITE}A chave tem este formato:${COLOR_RESET}"
    echo -e "${COLOR_GRAY}eyJhIjoiNzk5M2ExZGQxMmEzNGY5NGE4YzUyNTEyODYwNjU0ZjQiLCJ0IjoiM...${COLOR_RESET}"
    echo ""
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
    echo ""
    
    echo -e "${COLOR_WHITE}Cole a chave do túnel:${COLOR_RESET}"
    read -p "→ " TUNNEL_TOKEN
    
    if [ -z "$TUNNEL_TOKEN" ]; then
        echo ""
        echo -e "${COLOR_RED}${SYMBOL_ERROR} Chave não pode estar vazia!${COLOR_RESET}"
        sleep 2
        instala_cloudflared_menu
        return
    fi
    
    echo ""
    echo -e "${COLOR_YELLOW}${SYMBOL_LOADING} Configurando serviço...${COLOR_RESET}"
    echo ""
    
    # Instala o serviço com a chave
    cloudflared service install $TUNNEL_TOKEN
    
    if cloudflared_check_service; then
        echo ""
        echo -e "${COLOR_GREEN}${SYMBOL_CHECK} Serviço configurado com sucesso!${COLOR_RESET}"
        echo -e "${COLOR_GREEN}${SYMBOL_CHECK} O túnel iniciará automaticamente no boot.${COLOR_RESET}"
    else
        echo ""
        echo -e "${COLOR_RED}${SYMBOL_ERROR} Erro ao configurar o serviço!${COLOR_RESET}"
    fi
    
    echo ""
    read -p "Pressione ENTER para continuar..."
    instala_cloudflared_menu
}

# Função para remover cloudflared
cloudflared_remove() {
    clear
    echo -e "${COLOR_RED}${COLOR_BOLD}"
    echo -e "╔═════════════════════════════════════════════════════════════════════╗"
    echo -e "║                                                                     ║"
    echo -e "║           ⚠️  Remover Cloudflare Tunnel                             ║"
    echo -e "║                                                                     ║"
    echo -e "╚═════════════════════════════════════════════════════════════════════╝"
    echo -e "${COLOR_RESET}"
    echo ""
    
    echo -e "${COLOR_YELLOW}${COLOR_BOLD}ATENÇÃO:${COLOR_RESET}"
    echo -e "${COLOR_YELLOW}• Isso removerá completamente o Cloudflared do sistema${COLOR_RESET}"
    echo -e "${COLOR_YELLOW}• O serviço será parado e desabilitado${COLOR_RESET}"
    echo -e "${COLOR_YELLOW}• Você precisará reinstalar para usar novamente${COLOR_RESET}"
    echo ""
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
    echo ""
    
    echo -e "${COLOR_RED}${COLOR_BOLD}Confirmar remoção?${COLOR_RESET} (${COLOR_GREEN}s${COLOR_RESET}/${COLOR_RED}n${COLOR_RESET})"
    read -p "→ " CONFIRM
    
    if [[ "$CONFIRM" =~ ^[Ss]$ ]]; then
        echo ""
        echo -e "${COLOR_YELLOW}${SYMBOL_LOADING} Removendo Cloudflared...${COLOR_RESET}"
        echo ""
        
        # Para e desabilita o serviço se estiver rodando
        if cloudflared_check_service; then
            systemctl stop cloudflared 2>/dev/null
            systemctl disable cloudflared 2>/dev/null
        fi
        
        # Remove o pacote
        apt purge cloudflared -y
        
        # Remove o repositório
        rm -f /etc/apt/sources.list.d/cloudflared.list
        
        echo ""
        echo -e "${COLOR_GREEN}${SYMBOL_CHECK} Cloudflared removido com sucesso!${COLOR_RESET}"
    else
        echo ""
        echo -e "${COLOR_YELLOW}${SYMBOL_INFO} Remoção cancelada.${COLOR_RESET}"
    fi
    
    echo ""
    read -p "Pressione ENTER para continuar..."
    instala_cloudflared_menu
}

# Menu principal
instala_cloudflared_menu() {
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
    echo -e "║              ☁️  Gerenciador Cloudflare Tunnel                      ║"
    echo -e "║                                                                     ║"
    echo -e "╚═════════════════════════════════════════════════════════════════════╝"
    echo -e "${COLOR_RESET}"
    echo ""
    
    # Status da instalação
    echo -e "${COLOR_BOLD}  Status:${COLOR_RESET}"
    echo ""
    if cloudflared_check_installed; then
        CLOUDFLARED_VERSION=$(cloudflared --version 2>/dev/null | head -n1)
        echo -e "  ${COLOR_GREEN}${SYMBOL_CHECK} Cloudflared instalado${COLOR_RESET} ${COLOR_GRAY}($CLOUDFLARED_VERSION)${COLOR_RESET}"
        
        if cloudflared_check_service; then
            if systemctl is-active cloudflared &> /dev/null; then
                echo -e "  ${COLOR_GREEN}${SYMBOL_CHECK} Serviço ativo e rodando${COLOR_RESET}"
            else
                echo -e "  ${COLOR_YELLOW}${SYMBOL_INFO} Serviço configurado mas não está rodando${COLOR_RESET}"
            fi
        else
            echo -e "  ${COLOR_YELLOW}${SYMBOL_INFO} Serviço não configurado${COLOR_RESET}"
        fi
    else
        echo -e "  ${COLOR_RED}${SYMBOL_ERROR} Cloudflared não instalado${COLOR_RESET}"
    fi
    
    echo ""
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
    echo ""
    echo -e "${COLOR_BOLD}  Selecione uma opção:${COLOR_RESET}"
    echo ""
    echo -e "  ${COLOR_CYAN}┌───────────────────────────────────────────────────────────────┐${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                               ${COLOR_CYAN}│${COLOR_RESET}"
    
    # Opção 1 - Instalar (desabilitada se já instalado)
    if cloudflared_check_installed; then
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_GRAY}1 ➜  Instalação do túnel Cloudflare${COLOR_RESET} ${COLOR_GRAY}(já instalado)${COLOR_RESET}   ${COLOR_CYAN}│${COLOR_RESET}"
    else
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}1${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Instalação do túnel Cloudflare${COLOR_RESET}                    ${COLOR_CYAN}│${COLOR_RESET}"
    fi
    
    # Opção 2 - Configurar serviço (requer instalação)
    if cloudflared_check_installed; then
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}2${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Configurar serviço e chave do cliente${COLOR_RESET}             ${COLOR_CYAN}│${COLOR_RESET}"
    else
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_GRAY}2 ➜  Configurar serviço e chave do cliente${COLOR_RESET} ${COLOR_GRAY}(requer instalação)${COLOR_RESET} ${COLOR_CYAN}│${COLOR_RESET}"
    fi
    
    # Opção 3 - Remover (requer instalação)
    if cloudflared_check_installed; then
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}3${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Remover o túnel${COLOR_RESET}                                    ${COLOR_CYAN}│${COLOR_RESET}"
    else
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_GRAY}3 ➜  Remover o túnel${COLOR_RESET} ${COLOR_GRAY}(requer instalação)${COLOR_RESET}              ${COLOR_CYAN}│${COLOR_RESET}"
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
                    if cloudflared_check_installed; then
                        clear
                        echo -e "${COLOR_YELLOW}${SYMBOL_INFO} Cloudflared já está instalado!${COLOR_RESET}"
                        sleep 2
                        instala_cloudflared_menu
                    else
                        clear
                        cloudflared_install
                    fi
                    ;;
                2)
                    if cloudflared_check_installed; then
                        clear
                        cloudflared_configure_service
                    else
                        clear
                        echo -e "${COLOR_RED}${SYMBOL_ERROR} Você precisa instalar o Cloudflared primeiro!${COLOR_RESET}"
                        sleep 2
                        instala_cloudflared_menu
                    fi
                    ;;
                3)
                    if cloudflared_check_installed; then
                        clear
                        cloudflared_remove
                    else
                        clear
                        echo -e "${COLOR_RED}${SYMBOL_ERROR} Cloudflared não está instalado!${COLOR_RESET}"
                        sleep 2
                        instala_cloudflared_menu
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


