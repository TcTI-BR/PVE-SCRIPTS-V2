#!/bin/bash

# Script modular para Proxmox VE e PBS
# Versão: V003.R002
# Por: Marcelo Machado


version=V003.R002

# Define o diretório base do script, independentemente de onde é chamado
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Remove script antigo da inicialização (versão anterior)
rm -f /etc/profile.d/proxmox-ini.sh 2>/dev/null
rm -f /TcTI/SCRIPTS/proxmox-conf.sh 2>/dev/null
rm -f /TcTI/SCRIPTS/proxmox-ini.sh 2>/dev/null

# Variáveis de Repositório
BASE_URL="https://raw.githubusercontent.com/TcTI-BR/PVE-SCRIPTS-V2/main"
FUNCTIONS_DIR="$SCRIPT_DIR/functions"

# Timestamp para forçar bypass de cache (cache busting)
CACHE_BUSTER="?t=$(date +%s%N)"

# Lista de arquivos não é mais necessária pois usaremos o tar.gz
# Cores modernas
COLOR_RESET="\033[0m"
COLOR_BOLD="\033[1m"
COLOR_GREEN="\033[1;32m"
COLOR_BLUE="\033[1;34m"
COLOR_CYAN="\033[1;36m"
COLOR_YELLOW="\033[1;33m"
COLOR_RED="\033[1;31m"
COLOR_MAGENTA="\033[1;35m"
COLOR_WHITE="\033[1;37m"
COLOR_GRAY="\033[0;90m"

# Símbolos modernos
SYMBOL_CHECK="✓"
SYMBOL_ARROW="→"
SYMBOL_NEW="✨"
SYMBOL_UPDATE="⚡"
SYMBOL_ERROR="✗"
SYMBOL_INFO="ℹ"
SYMBOL_LOADING="⟳"

# Função de atualização/loader moderna
run_updater() {
    clear
    echo -e "${COLOR_CYAN}${COLOR_BOLD}"
    echo -e "╔════════════════════════════════════════════════════════════════════╗"
    echo -e "║           🚀 TcTI Proxmox Scripts - Sistema de Atualização          ║"
    echo -e "╚════════════════════════════════════════════════════════════════════╝"
    echo -e "${COLOR_RESET}"
    
    mkdir -p "$FUNCTIONS_DIR/pve"
    mkdir -p "$FUNCTIONS_DIR/pbs"
    mkdir -p "$FUNCTIONS_DIR/extras"
    
    echo -e "${COLOR_BLUE}${SYMBOL_LOADING} Verificando conexão com a internet...${COLOR_RESET}"
    
    # Teste rápido de conexão
    if ! curl -s --connect-timeout 3 https://github.com > /dev/null; then
        echo -e "${COLOR_YELLOW}⚠️  Modo Offline: Sem conexão. Iniciando com a versão local.${COLOR_RESET}"
        sleep 2
        return 0
    fi
    
    echo -e "${COLOR_BLUE}${SYMBOL_LOADING} Buscando atualizações...${COLOR_RESET}"
    
    # Obtém o ID do último commit na branch main (evita rate limits e é super rápido)
    LATEST_COMMIT=$(curl -sL "https://github.com/TcTI-BR/PVE-SCRIPTS-V2/commits/main.atom" | grep -m 1 "<id>tag:github.com,2008:Grit::Commit/" | cut -d '/' -f 2)
    
    if [ -z "$LATEST_COMMIT" ]; then
        echo -e "${COLOR_RED}${SYMBOL_ERROR} Falha ao consultar o repositório. Iniciando versão local.${COLOR_RESET}"
        sleep 2
        return 0
    fi
    
    LOCAL_COMMIT_FILE="$SCRIPT_DIR/.local_version"
    LOCAL_COMMIT=""
    
    if [ -f "$LOCAL_COMMIT_FILE" ]; then
        LOCAL_COMMIT=$(cat "$LOCAL_COMMIT_FILE")
    fi
    
    if [ "$LATEST_COMMIT" == "$LOCAL_COMMIT" ]; then
        echo -e "${COLOR_GREEN}${SYMBOL_CHECK} O script já está na última versão!${COLOR_RESET}"
        sleep 1
        return 0
    fi
    
    echo -e "${COLOR_YELLOW}${SYMBOL_UPDATE} Nova versão detectada! Baixando atualização (tar.gz)...${COLOR_RESET}"
    
    TMP_DIR="/tmp/pve_scripts_update_$$"
    mkdir -p "$TMP_DIR"
    
    TAR_URL="https://github.com/TcTI-BR/PVE-SCRIPTS-V2/archive/refs/heads/main.tar.gz"
    
    if curl -sL "$TAR_URL" | tar -xz -C "$TMP_DIR"; then
        echo -e "${COLOR_GREEN}${SYMBOL_CHECK} Download e extração concluídos.${COLOR_RESET}"
        
        # O GitHub extrai para uma pasta (ex: PVE-SCRIPTS-V2-main), enquanto um .tar local extrai direto.
        # Vamos detectar onde está o main.sh para saber qual pasta usar.
        if [ -f "$TMP_DIR/main.sh" ]; then
            SOURCE_DIR="$TMP_DIR"
        else
            EXTRACTED_FOLDER=$(ls -1 "$TMP_DIR" | head -n 1)
            SOURCE_DIR="$TMP_DIR/$EXTRACTED_FOLDER"
        fi
        
        if [ -n "$SOURCE_DIR" ] && [ -d "$SOURCE_DIR" ] && [ -f "$SOURCE_DIR/main.sh" ]; then
            echo -e "${COLOR_BLUE}${SYMBOL_LOADING} Aplicando atualização...${COLOR_RESET}"
            
            # Garantir permissão de execução em arquivos sh
            find "$SOURCE_DIR" -type f -name "*.sh" -exec chmod +x {} \;
            
            # Copia os arquivos por cima (usando cp -a para preservar permissões)
            cp -a "$SOURCE_DIR/"* "$SCRIPT_DIR/"
            
            # Atualiza o hash local para não baixar novamente
            echo "$LATEST_COMMIT" > "$LOCAL_COMMIT_FILE"
            
            # Limpeza
            rm -rf "$TMP_DIR"
            
            echo -e "${COLOR_GREEN}${SYMBOL_CHECK} Atualização aplicada com sucesso!${COLOR_RESET}"
            echo -e "${COLOR_GREEN}${SYMBOL_LOADING} Reiniciando o script automaticamente...${COLOR_RESET}"
            sleep 2
            
            # Reinicia o script passando os mesmos argumentos
            exec "$SCRIPT_DIR/main.sh" "$@"
        else
            echo -e "${COLOR_RED}${SYMBOL_ERROR} Erro: Pasta extraída não encontrada.${COLOR_RESET}"
            rm -rf "$TMP_DIR"
            sleep 2
        fi
    else
        echo -e "${COLOR_RED}${SYMBOL_ERROR} Falha ao baixar ou extrair o pacote. Iniciando versão local.${COLOR_RESET}"
        rm -rf "$TMP_DIR"
        sleep 2
    fi
}

# Se o script for chamado com o argumento "update"
if [ "$1" == "update" ]; then
    run_updater
    exit 0
fi

# Se for execução normal (sem "update"), rodar o updater E depois o menu
run_updater

# Carrega todas as funções das novas estruturas com visual moderno
echo -e "${COLOR_BLUE}${SYMBOL_LOADING} Carregando módulos...${COLOR_RESET}"
echo ""

# Contador de funções
pve_count=0
pbs_count=0

# Carrega funções PVE
echo -e "${COLOR_CYAN}${SYMBOL_ARROW} Proxmox Virtual Environment (PVE)${COLOR_RESET}"
for f in "$FUNCTIONS_DIR/pve"/*.sh; do
    if [ -f "$f" ]; then
        source "$f"
        pve_count=$((pve_count + 1))
        printf "  ${COLOR_GRAY}▸${COLOR_RESET} $(basename "$f")\n"
    fi
done

# Carrega funções PBS
echo ""
echo -e "${COLOR_CYAN}${SYMBOL_ARROW} Proxmox Backup Server (PBS)${COLOR_RESET}"
for f in "$FUNCTIONS_DIR/pbs"/*.sh; do
    if [ -f "$f" ]; then
        source "$f"
        pbs_count=$((pbs_count + 1))
        printf "  ${COLOR_GRAY}▸${COLOR_RESET} $(basename "$f")\n"
    fi
done

extras_count=0
# Carrega funções Extras
echo ""
echo -e "${COLOR_CYAN}${SYMBOL_ARROW} Ferramentas Gerais (Extras)${COLOR_RESET}"
for f in "$FUNCTIONS_DIR/extras"/*.sh; do
    if [ -f "$f" ]; then
        source "$f"
        extras_count=$((extras_count + 1))
        printf "  ${COLOR_GRAY}▸${COLOR_RESET} $(basename "$f")\n"
    fi
done

echo ""
echo -e "${COLOR_GREEN}${SYMBOL_CHECK} ${pve_count} módulos PVE carregados${COLOR_RESET}"
echo -e "${COLOR_GREEN}${SYMBOL_CHECK} ${pbs_count} módulos PBS carregados${COLOR_RESET}"
echo -e "${COLOR_GREEN}${SYMBOL_CHECK} ${extras_count} módulos Extras carregados${COLOR_RESET}"
echo ""
sleep 1

# -----------------VARIAVEIS DE SISTEMA----------------------
dnstesthost=google.com.br
pve_log_folder="/var/log/pve/tasks/"
proxmoxlib="/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js"
distribution=$(. /etc/*-release;echo $VERSION_CODENAME)
execdir=$(dirname $0)
hostname=$(hostname)
date=$(date +%Y_%m_%d-%H_%M_%S)
# ---------------FIM DAS VARIAVEIS DE SISTEMA-----------------

# Banner e verificação inicial modernos
clear
echo -e "${COLOR_CYAN}${COLOR_BOLD}"
echo -e "╔═══════════════════════════════════════════════════════════════════════════════╗"
echo -e "║                                                                               ║"
echo -e "║                    ⚠️  AVISO DE RESPONSABILIDADE  ⚠️                            ║"
echo -e "║                                                                               ║"
echo -e "╠═══════════════════════════════════════════════════════════════════════════════╣"
echo -e "${COLOR_RESET}"
echo -e "${COLOR_YELLOW}${COLOR_BOLD}"
echo -e "  O uso deste script é de ${COLOR_RED}INTEIRA RESPONSABILIDADE${COLOR_YELLOW} do utilizador."
echo -e "${COLOR_RESET}"
echo ""
echo -e "${COLOR_WHITE}  • A pessoa ou empresa que forneceu o script ${COLOR_RED}NÃO SERÁ RESPONSÁVEL${COLOR_WHITE}"
echo -e "    por quaisquer ${COLOR_RED}problemas ou danos causados${COLOR_WHITE} pelo uso do mesmo.${COLOR_RESET}"
echo ""
echo -e "${COLOR_WHITE}  • Antes de utilizar, faça uma ${COLOR_GREEN}avaliação cuidadosa${COLOR_WHITE} e compreenda"
echo -e "    as implicações do seu uso.${COLOR_RESET}"
echo ""
echo -e "${COLOR_WHITE}  • ${COLOR_RED}Certifique-se${COLOR_WHITE} de que o script é ${COLOR_GREEN}seguro e adequado${COLOR_WHITE} para"
echo -e "    as suas necessidades antes de utilizá-lo.${COLOR_RESET}"
echo ""
echo -e "${COLOR_CYAN}${COLOR_BOLD}"
echo -e "╠═══════════════════════════════════════════════════════════════════════════════╣"
echo -e "║                                                                               ║"
echo -e "║  ${COLOR_YELLOW}➜${COLOR_CYAN}  Ao pressionar ENTER você ${COLOR_RED}CONCORDA${COLOR_CYAN} com os termos acima                     ║"
echo -e "║                                                                               ║"
echo -e "╚═══════════════════════════════════════════════════════════════════════════════╝"
echo -e "${COLOR_RESET}"
read -p ""
clear

# Verificando se é root com visual moderno
if [[ $(id -u) -ne 0 ]] ; then 
    echo -e "${COLOR_RED}${COLOR_BOLD}"
    echo -e "╔═══════════════════════════════════════════════════════════════╗"
    echo -e "║                                                               ║"
    echo -e "║  ✗ ERRO: Este script precisa ser executado como ROOT         ║"
    echo -e "║                                                               ║"
    echo -e "║  Por favor execute com:                                       ║"
    echo -e "║    • sudo ./main.sh                                           ║"
    echo -e "║    • su - (e depois execute ./main.sh)                        ║"
    echo -e "║                                                               ║"
    echo -e "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${COLOR_RESET}"
    exit 1
fi

# Menu Principal Moderno
main_menu(){
    clear
    echo -e "${COLOR_CYAN}${COLOR_BOLD}"
    echo -e "╔═══════════════════════════════════════════════════════════════════════════════╗"
    echo -e "║                                                                               ║"
    echo -e "║               🚀  TcTI Proxmox Scripts - Menu Principal                        ║"
    echo -e "║                      Versão: ${COLOR_YELLOW}$version${COLOR_CYAN}                                        ║"
    echo -e "║                    Desenvolvido por: ${COLOR_WHITE}Marcelo Machado${COLOR_CYAN}                          ║"
    echo -e "║                                                                               ║"
    echo -e "╚═══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${COLOR_RESET}"
    echo ""
    echo -e "${COLOR_BOLD}  Selecione uma opção:${COLOR_RESET}"
    echo ""
    echo -e "  ${COLOR_CYAN}┌─────────────────────────────────────────────────────────────────┐${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                                 ${COLOR_CYAN}│${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}1${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Proxmox Virtual Environment (PVE)${COLOR_RESET}                         ${COLOR_CYAN}│${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}       ${COLOR_GRAY}Gerenciamento completo do Proxmox VE${COLOR_RESET}                      ${COLOR_CYAN}│${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                                 ${COLOR_CYAN}│${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}2${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Proxmox Backup Server (PBS)${COLOR_RESET}                               ${COLOR_CYAN}│${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}       ${COLOR_GRAY}Gerenciamento do Proxmox Backup Server${COLOR_RESET}                    ${COLOR_CYAN}│${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                                 ${COLOR_CYAN}│${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}3${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Ferramentas Gerais e Extras${COLOR_RESET}                               ${COLOR_CYAN}│${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}       ${COLOR_GRAY}Testes de disco, badblocks, SMART, etc.${COLOR_RESET}                   ${COLOR_CYAN}│${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                                 ${COLOR_CYAN}│${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_RED}0${COLOR_RESET} ${COLOR_RED}➜${COLOR_RESET}  ${COLOR_WHITE}Sair${COLOR_RESET}                                                      ${COLOR_CYAN}│${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                                 ${COLOR_CYAN}│${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}└─────────────────────────────────────────────────────────────────┘${COLOR_RESET}"
    echo ""
    echo -e "${COLOR_YELLOW}  Digite sua opção ${COLOR_GRAY}(ou pressione ENTER para sair)${COLOR_YELLOW}: ${COLOR_RESET}"
    read -rsn1 opt
	while [ opt != '' ]
  do
    if [[ $opt = "" ]]; then
      exit;
    else
      case $opt in
	   	1) clear;
		pve_menu
			;;
	    2) clear;
		pbs_menu
			;;
	    3) clear;
		extras_menu
			;;
		0)
		clear
		exit
			;;
		*)
		clear
		exit
			;;
      esac
    fi
  done
  main_menu
}

# Inicia o menu principal
main_menu

