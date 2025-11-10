#!/bin/bash

# Script modular para Proxmox VE e PBS
# Versão: V002.R001
# Por: Marcelo Machado

version=V002.R001

# Define o diretório base do script, independentemente de onde é chamado
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Remove script antigo da inicialização (versão anterior)
rm -f /etc/profile.d/proxmox-ini.sh 2>/dev/null

# Variáveis de Repositório
BASE_URL="https://raw.githubusercontent.com/TcTI-BR/PVE-SCRIPTS-V2/main"
FUNCTIONS_DIR="$SCRIPT_DIR/functions"

# Timestamp para forçar bypass de cache (cache busting)
CACHE_BUSTER="?t=$(date +%s%N)"

# Lista de arquivos necessários (nova estrutura modular)
REQUIRED_FILES=(
    # Script Principal
    "$SCRIPT_DIR/main.sh"
    # Funções PVE
    "$FUNCTIONS_DIR/pve/menu_pve.sh"
    "$FUNCTIONS_DIR/pve/menu_update.sh"
    "$FUNCTIONS_DIR/pve/menu_upgrade.sh"
    "$FUNCTIONS_DIR/pve/menu_disco.sh"
    "$FUNCTIONS_DIR/pve/menu_bkp.sh"
    "$FUNCTIONS_DIR/pve/menu_email.sh"
    "$FUNCTIONS_DIR/pve/menu_vm_operations.sh"
    "$FUNCTIONS_DIR/pve/live_migration.sh"
    "$FUNCTIONS_DIR/pve/menu_tweaks.sh"
    "$FUNCTIONS_DIR/pve/destranca_desliga.sh"
    "$FUNCTIONS_DIR/pve/menu_instala_script.sh"
    "$FUNCTIONS_DIR/pve/menu_instala_x.sh"
    "$FUNCTIONS_DIR/pve/menu_watch_dog.sh"
    "$FUNCTIONS_DIR/pve/menu_lan.sh"
    "$FUNCTIONS_DIR/pve/menu_commands.sh"
    "$FUNCTIONS_DIR/pve/menu_instala_aplicativos.sh"
    "$FUNCTIONS_DIR/pve/menu_instala_tactical_rmm.sh"
    # Funções PBS
    "$FUNCTIONS_DIR/pbs/menu_pbs.sh"
    "$FUNCTIONS_DIR/pbs/menu_update_pbs.sh"
    "$FUNCTIONS_DIR/pbs/menu_upgrade_pbs.sh"
    "$FUNCTIONS_DIR/pbs/menu_disco_pbs.sh"
    "$FUNCTIONS_DIR/pbs/menu_email_pbs.sh"
    "$FUNCTIONS_DIR/pbs/menu_lan_pbs.sh"
    "$FUNCTIONS_DIR/pbs/menu_tweaks_pbs.sh"
)

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
    
    local total_files=${#REQUIRED_FILES[@]}
    local current=0
    local new_count=0
    local updated_count=0
    local ok_count=0
    local error_count=0
    local main_updated=0
    
    echo -e "${COLOR_BLUE}${SYMBOL_LOADING} Verificando ${total_files} arquivos...${COLOR_RESET}\n"
    
    for FILE_PATH in "${REQUIRED_FILES[@]}"; do
        current=$((current + 1))
        
        # Extrai o caminho relativo (ex: functions/pve/arquivo.sh ou main.sh)
        RELATIVE_PATH="${FILE_PATH#"$SCRIPT_DIR/"}"
        REMOTE_URL="$BASE_URL/$RELATIVE_PATH$CACHE_BUSTER"
        TMP_FILE="/tmp/$(basename "$FILE_PATH").remote.$$"
        
        # Nome do arquivo para exibição
        FILE_NAME=$(basename "$FILE_PATH")
        
        # Exibe progresso
        printf "${COLOR_GRAY}[%2d/${total_files}]${COLOR_RESET} %-40s " "$current" "$FILE_NAME"
        
        # Baixa com flags para evitar cache
        if ! curl -sL -H "Cache-Control: no-cache, no-store, must-revalidate" \
                    -H "Pragma: no-cache" \
                    -H "Expires: 0" \
                    -o "$TMP_FILE" "$REMOTE_URL" 2>/dev/null; then
            echo -e "${COLOR_RED}${SYMBOL_ERROR} Erro ao baixar${COLOR_RESET}"
            error_count=$((error_count + 1))
            continue
        fi
        
        # Verifica se o arquivo foi baixado corretamente
        if [ ! -s "$TMP_FILE" ]; then
            echo -e "${COLOR_RED}${SYMBOL_ERROR} Arquivo vazio${COLOR_RESET}"
            rm -f "$TMP_FILE"
            error_count=$((error_count + 1))
            continue
        fi
        
        if [ ! -f "$FILE_PATH" ]; then
            # Arquivo não existe - instalar
            mv "$TMP_FILE" "$FILE_PATH"
            chmod +x "$FILE_PATH"
            echo -e "${COLOR_MAGENTA}${SYMBOL_NEW} NOVO${COLOR_RESET}"
            new_count=$((new_count + 1))
        else
            # Compara usando checksum (mais confiável que diff)
            local_hash=$(md5sum "$FILE_PATH" 2>/dev/null | awk '{print $1}')
            remote_hash=$(md5sum "$TMP_FILE" 2>/dev/null | awk '{print $1}')
            
            if [ "$local_hash" != "$remote_hash" ]; then
                # Arquivos são diferentes - atualizar
                if [[ "$FILE_NAME" == "main.sh" ]]; then
                    mv "$TMP_FILE" "$FILE_PATH"
                    chmod +x "$FILE_PATH"
                    echo -e "${COLOR_YELLOW}${SYMBOL_UPDATE} ATUALIZADO ${COLOR_MAGENTA}(reinicie o script)${COLOR_RESET}"
                    updated_count=$((updated_count + 1))
                    main_updated=1
                else
                    mv "$TMP_FILE" "$FILE_PATH"
                    chmod +x "$FILE_PATH"
                    echo -e "${COLOR_YELLOW}${SYMBOL_UPDATE} ATUALIZADO${COLOR_RESET}"
                    updated_count=$((updated_count + 1))
                fi
            else
                # Arquivos são idênticos - manter
                rm "$TMP_FILE"
                echo -e "${COLOR_GREEN}${SYMBOL_CHECK} OK${COLOR_RESET}"
                ok_count=$((ok_count + 1))
            fi
        fi
    done
    
    echo ""
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
    echo -e "${COLOR_BOLD}📊 Resumo da Verificação:${COLOR_RESET}"
    echo ""
    
    if [ $new_count -gt 0 ]; then
        echo -e "   ${COLOR_MAGENTA}${SYMBOL_NEW} Novos:        ${new_count} arquivo(s)${COLOR_RESET}"
    fi
    
    if [ $updated_count -gt 0 ]; then
        echo -e "   ${COLOR_YELLOW}${SYMBOL_UPDATE} Atualizados:  ${updated_count} arquivo(s)${COLOR_RESET}"
    fi
    
    if [ $ok_count -gt 0 ]; then
        echo -e "   ${COLOR_GREEN}${SYMBOL_CHECK} Atualizados:  ${ok_count} arquivo(s)${COLOR_RESET}"
    fi
    
    if [ $error_count -gt 0 ]; then
        echo -e "   ${COLOR_RED}${SYMBOL_ERROR} Erros:        ${error_count} arquivo(s)${COLOR_RESET}"
    fi
    
    echo ""
    
    if [ $((new_count + updated_count)) -gt 0 ]; then
        echo -e "${COLOR_GREEN}${SYMBOL_CHECK} Verificação concluída com atualizações!${COLOR_RESET}"
        
        # Se o main.sh foi atualizado, avisar e reiniciar automaticamente
        if [ $main_updated -eq 1 ]; then
            echo ""
            echo -e "${COLOR_YELLOW}${COLOR_BOLD}⚠️  ATENÇÃO:${COLOR_RESET}"
            echo -e "${COLOR_YELLOW}   O arquivo main.sh foi atualizado!${COLOR_RESET}"
            echo -e "${COLOR_GREEN}   Reiniciando automaticamente em:${COLOR_RESET}"
            echo ""
            
            # Contador regressivo de 5 segundos
            for i in 5 4 3 2 1; do
                echo -ne "   ${COLOR_CYAN}${COLOR_BOLD}$i${COLOR_RESET} segundos...\r"
                sleep 1
            done
            
            echo ""
            echo -e "${COLOR_GREEN}${SYMBOL_LOADING} Reiniciando o script...${COLOR_RESET}"
            echo ""
            sleep 1
            
            # Reinicia o script automaticamente
            exec "$SCRIPT_DIR/main.sh"
        fi
    else
        echo -e "${COLOR_GREEN}${SYMBOL_CHECK} Todos os arquivos estão atualizados!${COLOR_RESET}"
    fi
    
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
    echo ""
    sleep 2
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

echo ""
echo -e "${COLOR_GREEN}${SYMBOL_CHECK} ${pve_count} módulos PVE carregados${COLOR_RESET}"
echo -e "${COLOR_GREEN}${SYMBOL_CHECK} ${pbs_count} módulos PBS carregados${COLOR_RESET}"
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
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}1${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Proxmox Virtual Environment (PVE)${COLOR_RESET}                          ${COLOR_CYAN}│${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}       ${COLOR_GRAY}Gerenciamento completo do Proxmox VE${COLOR_RESET}                              ${COLOR_CYAN}│${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                                 ${COLOR_CYAN}│${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}2${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Proxmox Backup Server (PBS)${COLOR_RESET}                                ${COLOR_CYAN}│${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}       ${COLOR_GRAY}Gerenciamento do Proxmox Backup Server${COLOR_RESET}                            ${COLOR_CYAN}│${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                                 ${COLOR_CYAN}│${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_RED}0${COLOR_RESET} ${COLOR_RED}➜${COLOR_RESET}  ${COLOR_WHITE}Sair${COLOR_RESET}                                                          ${COLOR_CYAN}│${COLOR_RESET}"
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

