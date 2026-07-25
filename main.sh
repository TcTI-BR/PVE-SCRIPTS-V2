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

# ============================================================
# MOTOR GRÁFICO E MULTI-IDIOMA (i18n)
# ============================================================
ui_print_menu_item() {
    local opt_num="$1"
    local opt_text="$2"
    local opt_color="${3:-$COLOR_YELLOW}"
    local max_len="${4:-63}"
    
    # Contamos o tamanho visual do texto (Chinês ocupa 2 colunas visuais no bash para a maioria dos terminais)
    local text_len=${#opt_text}
    
    local cjk_count=$(echo -n "$opt_text" | grep -o -P '[\p{Han}]' | wc -l)
    text_len=$(( text_len + cjk_count ))

    local fixed_len=7 # Espaços e setas: "  X ➜  "
    local total_len=$(( fixed_len + text_len ))
    local spaces_needed=$(( max_len - total_len ))
    
    if [ $spaces_needed -lt 0 ]; then spaces_needed=0; fi
    local padding=$(printf '%*s' "$spaces_needed" "")
    
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${opt_color}${opt_num}${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}${opt_text}${COLOR_RESET}${padding}${COLOR_CYAN}│${COLOR_RESET}"
}

ui_print_menu_desc() {
    local opt_desc="$1"
    local max_len="${2:-63}"
    
    local text_len=${#opt_desc}
    local cjk_count=$(echo -n "$opt_desc" | grep -o -P '[\p{Han}]' | wc -l)
    text_len=$(( text_len + cjk_count ))

    local fixed_len=7 # Subtítulos recuados igual: "       "
    local total_len=$(( fixed_len + text_len ))
    local spaces_needed=$(( max_len - total_len ))
    
    if [ $spaces_needed -lt 0 ]; then spaces_needed=0; fi
    local padding=$(printf '%*s' "$spaces_needed" "")
    
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}       ${COLOR_GRAY}${opt_desc}${COLOR_RESET}${padding}${COLOR_CYAN}│${COLOR_RESET}"
}

ui_print_header_line() {
    local text="$1"
    local color="${2:-$COLOR_WHITE}"
    local max_len="${3:-79}" # Inner width matches the 79 ═ characters
    
    local plain_text=$(echo -e "$text" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")
    # Remove emoji variation selectors (U+FE0F) which are invisible but count as 1 char in bash
    plain_text=$(echo "$plain_text" | sed $'s/\xEF\xB8\x8F//g')
    local text_len=${#plain_text}
    local cjk_count=$(echo -n "$plain_text" | grep -o -P '[\p{Han}]' | wc -l)
    text_len=$(( text_len + cjk_count ))

    local spaces_needed=$(( max_len - text_len ))
    if [ $spaces_needed -lt 0 ]; then spaces_needed=0; fi
    
    # Let's center it:
    local left_pad=$(( spaces_needed / 2 ))
    local right_pad=$(( spaces_needed - left_pad ))
    
    local pad_l=$(printf '%*s' "$left_pad" "")
    local pad_r=$(printf '%*s' "$right_pad" "")
    
    # We use COLOR_CYAN at the end to keep the box border color active for the next line
    echo -e "${COLOR_CYAN}║${COLOR_RESET}${pad_l}${color}${text}${COLOR_RESET}${pad_r}${COLOR_CYAN}║"
}

ui_print_left_header_line() {
    local text="$1"
    local color="${2:-$COLOR_WHITE}"
    local max_len="${3:-79}"
    
    local plain_text=$(echo -e "$text" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")
    # Remove emoji variation selectors (U+FE0F) which are invisible but count as 1 char in bash
    plain_text=$(echo "$plain_text" | sed $'s/\xEF\xB8\x8F//g')
    local text_len=${#plain_text}
    local cjk_count=$(echo -n "$plain_text" | grep -o -P '[\p{Han}]' | wc -l)
    text_len=$(( text_len + cjk_count ))

    local spaces_needed=$(( max_len - text_len - 2 )) # 2 spaces for left padding
    if [ $spaces_needed -lt 0 ]; then spaces_needed=0; fi
    
    local pad_r=$(printf '%*s' "$spaces_needed" "")
    
    echo -e "${COLOR_CYAN}║${COLOR_RESET}  ${color}${text}${COLOR_RESET}${pad_r}${COLOR_CYAN}║"
}

LANG_CONFIG_FILE="$SCRIPT_DIR/.lang.cfg"

# Função para preenchimento dinâmico de strings (Dynamic Padding)
# Resolve o problema de alinhamento de bordas com idiomas diferentes (incluindo Chinês)
ui_print_menu_item() {
    local opt_num="$1"
    local opt_text="$2"
    local opt_color="${3:-$COLOR_YELLOW}"
    local max_len="${4:-63}"
    
    # Contamos o tamanho visual do texto (Chinês ocupa 2 colunas visuais no bash para a maioria dos terminais)
    local text_len=${#opt_text}
    
    local cjk_count=$(echo -n "$opt_text" | grep -o -P '[\p{Han}]' | wc -l)
    text_len=$(( text_len + cjk_count ))

    local fixed_len=7 # Espaços e setas: "  X ➜  "
    local total_len=$(( fixed_len + text_len ))
    local spaces_needed=$(( max_len - total_len ))
    
    if [ $spaces_needed -lt 0 ]; then spaces_needed=0; fi
    local padding=$(printf '%*s' "$spaces_needed" "")
    
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${opt_color}${opt_num}${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}${opt_text}${COLOR_RESET}${padding}${COLOR_CYAN}│${COLOR_RESET}"
}

ui_print_menu_desc() {
    local opt_desc="$1"
    local max_len="${2:-63}"
    
    local text_len=${#opt_desc}
    local cjk_count=$(echo -n "$opt_desc" | grep -o -P '[\p{Han}]' | wc -l)
    text_len=$(( text_len + cjk_count ))

    local fixed_len=7 # Subtítulos recuados igual: "       "
    local total_len=$(( fixed_len + text_len ))
    local spaces_needed=$(( max_len - total_len ))
    
    if [ $spaces_needed -lt 0 ]; then spaces_needed=0; fi
    local padding=$(printf '%*s' "$spaces_needed" "")
    
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}       ${COLOR_GRAY}${opt_desc}${COLOR_RESET}${padding}${COLOR_CYAN}│${COLOR_RESET}"
}

ui_print_header_line() {
    local text="$1"
    local color="${2:-$COLOR_WHITE}"
    local max_len="${3:-79}" # Inner width matches the 79 ═ characters
    
    local plain_text=$(echo -e "$text" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")
    # Remove emoji variation selectors (U+FE0F) which are invisible but count as 1 char in bash
    plain_text=$(echo "$plain_text" | sed $'s/\xEF\xB8\x8F//g')
    local text_len=${#plain_text}
    local cjk_count=$(echo -n "$plain_text" | grep -o -P '[\p{Han}]' | wc -l)
    text_len=$(( text_len + cjk_count ))

    local spaces_needed=$(( max_len - text_len ))
    if [ $spaces_needed -lt 0 ]; then spaces_needed=0; fi
    
    # Let's center it:
    local left_pad=$(( spaces_needed / 2 ))
    local right_pad=$(( spaces_needed - left_pad ))
    
    local pad_l=$(printf '%*s' "$left_pad" "")
    local pad_r=$(printf '%*s' "$right_pad" "")
    
    # We use COLOR_CYAN at the end to keep the box border color active for the next line
    echo -e "${COLOR_CYAN}║${COLOR_RESET}${pad_l}${color}${text}${COLOR_RESET}${pad_r}${COLOR_CYAN}║"
}

ui_print_left_header_line() {
    local text="$1"
    local color="${2:-$COLOR_WHITE}"
    local max_len="${3:-79}"
    
    local plain_text=$(echo -e "$text" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")
    # Remove emoji variation selectors (U+FE0F) which are invisible but count as 1 char in bash
    plain_text=$(echo "$plain_text" | sed $'s/\xEF\xB8\x8F//g')
    local text_len=${#plain_text}
    local cjk_count=$(echo -n "$plain_text" | grep -o -P '[\p{Han}]' | wc -l)
    text_len=$(( text_len + cjk_count ))

    local spaces_needed=$(( max_len - text_len - 2 )) # 2 spaces for left padding
    if [ $spaces_needed -lt 0 ]; then spaces_needed=0; fi
    
    local pad_r=$(printf '%*s' "$spaces_needed" "")
    
    echo -e "${COLOR_CYAN}║${COLOR_RESET}  ${color}${text}${COLOR_RESET}${pad_r}${COLOR_CYAN}║"
}

# Escolha inicial de idioma
if [ ! -f "$LANG_CONFIG_FILE" ]; then
    clear
    echo -e "${COLOR_CYAN}╔══════════════════════════════════════════════════════════════════════════╗${COLOR_RESET}"
    echo -e "${COLOR_CYAN}║${COLOR_RESET}  ${COLOR_YELLOW}Welcome! Please select your language / Por favor, selecione seu idioma${COLOR_RESET}  ${COLOR_CYAN}║${COLOR_RESET}"
    echo -e "${COLOR_CYAN}╚══════════════════════════════════════════════════════════════════════════╝${COLOR_RESET}"
    echo ""
    echo "  1 ➜ 🇧🇷 Português (Brasil)"
    echo "  2 ➜ 🇺🇸 English (US)"
    echo "  3 ➜ 🇪🇸 Español (ES)"
    echo "  4 ➜ 🇨🇳 简体中文 (Chinese)"
    echo ""
    echo -n "  Option / Opção: "
    read -r lang_opt
    case $lang_opt in
        1) echo "LANG_FILE=pt_BR.sh" > "$LANG_CONFIG_FILE" ;;
        2) echo "LANG_FILE=en_US.sh" > "$LANG_CONFIG_FILE" ;;
        3) echo "LANG_FILE=es_ES.sh" > "$LANG_CONFIG_FILE" ;;
        4) echo "LANG_FILE=zh_CN.sh" > "$LANG_CONFIG_FILE" ;;
        *) echo "LANG_FILE=pt_BR.sh" > "$LANG_CONFIG_FILE" ;; # Fallback
    esac
fi

# Carrega o idioma
source "$LANG_CONFIG_FILE"
if [ -f "$FUNCTIONS_DIR/lang/$LANG_FILE" ]; then
    source "$FUNCTIONS_DIR/lang/$LANG_FILE"
else
    # Fallback silencioso
    source "$FUNCTIONS_DIR/lang/pt_BR.sh" 2>/dev/null
fi
# ============================================================


run_updater() {
    clear
    echo -e "${COLOR_CYAN}${COLOR_BOLD}"
    echo -e "╔════════════════════════════════════════════════════════════════════╗"
    echo -e "║           🚀 ${LANG_UPD_TITLE:-TcTI Proxmox Scripts - Sistema de Atualização}          ║"
    echo -e "╚════════════════════════════════════════════════════════════════════╝"
    echo -e "${COLOR_RESET}"
    
    # Verifica se atualização automática foi desativada pelo usuário/empresa
    if [ -f "/TcTI/SCRIPTS/.no_auto_update" ] || [ -f "$SCRIPT_DIR/.no_auto_update" ]; then
        echo -e "${COLOR_YELLOW}⚠️  Atualização automática desativada nas configurações.${COLOR_RESET}"
        echo -e "${COLOR_GRAY}   Iniciando com a versão local.${COLOR_RESET}"
        sleep 1
        return 0
    fi

    mkdir -p "$FUNCTIONS_DIR/pve"
    mkdir -p "$FUNCTIONS_DIR/pbs"
    mkdir -p "$FUNCTIONS_DIR/extras"
    
    echo -e "${COLOR_BLUE}${SYMBOL_LOADING} ${LANG_UPD_CONN:-Verificando conexão com a internet...}${COLOR_RESET}"
    
    # Teste rápido de conexão
    if ! curl -s --connect-timeout 3 https://github.com > /dev/null; then
        echo -e "${COLOR_YELLOW}⚠️  Modo Offline: Sem conexão. Iniciando com a versão local.${COLOR_RESET}"
        sleep 2
        return 0
    fi
    
    echo -e "${COLOR_BLUE}${SYMBOL_LOADING} ${LANG_UPD_CHECK:-Buscando atualizações...}${COLOR_RESET}"
    
    # Obtém o ID do último commit na branch main (evita rate limits e é super rápido)
    LATEST_COMMIT=$(curl -sL "https://github.com/TcTI-BR/PVE-SCRIPTS-V2/commits/main.atom" | grep -m 1 "<id>tag:github.com,2008:Grit::Commit/" | cut -d '/' -f 2)
    
    if [ -z "$LATEST_COMMIT" ]; then
        echo -e "${COLOR_RED}${SYMBOL_ERROR} ${LANG_UPD_REPO_FAIL:-Falha ao consultar o repositório. Iniciando versão local.}${COLOR_RESET}"
        sleep 2
        return 0
    fi
    
    LOCAL_COMMIT_FILE="$SCRIPT_DIR/.local_version"
    LOCAL_COMMIT=""
    
    if [ -f "$LOCAL_COMMIT_FILE" ]; then
        LOCAL_COMMIT=$(cat "$LOCAL_COMMIT_FILE")
    fi
    
    if [ "$LATEST_COMMIT" == "$LOCAL_COMMIT" ]; then
        echo -e "${COLOR_GREEN}${SYMBOL_CHECK} ${LANG_UPD_LATEST:-O script já está na última versão!}${COLOR_RESET}"
        sleep 1
        return 0
    fi
    
    echo -e "${COLOR_YELLOW}${SYMBOL_UPDATE} ${LANG_UPD_NEW:-Nova versão detectada! Baixando atualização (tar.gz)...}${COLOR_RESET}"
    
    TMP_DIR="/tmp/pve_scripts_update_$$"
    mkdir -p "$TMP_DIR"
    
    # Adicionando um timestamp na URL para forçar o GitHub a não entregar cache antigo
    CACHE_BUSTER="?t=$(date +%s%N)"
    TAR_URL="https://raw.githubusercontent.com/TcTI-BR/PVE-SCRIPTS-V2/main/main.tar.gz$CACHE_BUSTER"
    
    if curl -sL "$TAR_URL" | tar -xz -C "$TMP_DIR"; then
        echo -e "${COLOR_GREEN}${SYMBOL_CHECK} ${LANG_UPD_DL_OK:-Download e extração concluídos.}${COLOR_RESET}"
        
        # O GitHub extrai para uma pasta (ex: PVE-SCRIPTS-V2-main), enquanto um .tar local extrai direto.
        # Vamos detectar onde está o main.sh para saber qual pasta usar.
        if [ -f "$TMP_DIR/main.sh" ]; then
            SOURCE_DIR="$TMP_DIR"
        else
            EXTRACTED_FOLDER=$(ls -1 "$TMP_DIR" | head -n 1)
            SOURCE_DIR="$TMP_DIR/$EXTRACTED_FOLDER"
        fi
        
        if [ -n "$SOURCE_DIR" ] && [ -d "$SOURCE_DIR" ] && [ -f "$SOURCE_DIR/main.sh" ]; then
            echo -e "${COLOR_BLUE}${SYMBOL_LOADING} ${LANG_UPD_APPLY:-Aplicando atualização...}${COLOR_RESET}"
            
            # Garantir permissão de execução em arquivos sh extraídos
            find "$SOURCE_DIR" -type f -name "*.sh" -exec chmod +x {} \;
            
            # Remove a pasta de funções antiga para garantir substituição limpa e remover arquivos legados
            rm -rf "$SCRIPT_DIR/functions"
            
            # Copia a nova versão por cima (usando cp -rf para forçar substituição)
            cp -rf "$SOURCE_DIR/"* "$SCRIPT_DIR/"
            
            # Garante permissões de execução no destino
            find "$SCRIPT_DIR" -type f -name "*.sh" -exec chmod +x {} \;
            
            # Atualiza o hash local para não baixar novamente
            echo "$LATEST_COMMIT" > "$LOCAL_COMMIT_FILE"
            
            # Limpeza
            rm -rf "$TMP_DIR"
            
            echo -e "${COLOR_GREEN}${SYMBOL_CHECK} ${LANG_UPD_SUCCESS:-Atualização aplicada com sucesso!}${COLOR_RESET}"
            echo -e "${COLOR_GREEN}${SYMBOL_LOADING} ${LANG_UPD_RESTART:-Reiniciando o script automaticamente...}${COLOR_RESET}"
            sleep 2
            
            # Reinicia o script passando os mesmos argumentos
            exec "$SCRIPT_DIR/main.sh" "$@"
        else
            echo -e "${COLOR_RED}${SYMBOL_ERROR} ${LANG_UPD_ERR_FOLDER:-Erro: Pasta extraída não encontrada.}${COLOR_RESET}"
            rm -rf "$TMP_DIR"
            sleep 2
        fi
    else
        echo -e "${COLOR_RED}${SYMBOL_ERROR} ${LANG_UPD_DL_FAIL:-Falha ao baixar ou extrair o pacote. Iniciando versão local.}${COLOR_RESET}"
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
echo -e "${COLOR_BLUE}${SYMBOL_LOADING} ${LANG_UPD_LOAD_MODS:-Carregando módulos...}${COLOR_RESET}"
echo ""

# Contador de funções
pve_count=0
pbs_count=0

# Carrega funções PVE
echo -e "${COLOR_CYAN}${SYMBOL_ARROW} ${LANG_UPD_PVE:-Proxmox Virtual Environment (PVE)}${COLOR_RESET}"
for f in "$FUNCTIONS_DIR/pve"/*.sh; do
    if [ -f "$f" ]; then
        source "$f"
        pve_count=$((pve_count + 1))
        printf "  ${COLOR_GRAY}▸${COLOR_RESET} $(basename "$f")\n"
    fi
done

# Carrega funções PBS
echo ""
echo -e "${COLOR_CYAN}${SYMBOL_ARROW} ${LANG_UPD_PBS:-Proxmox Backup Server (PBS)}${COLOR_RESET}"
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
echo -e "${COLOR_CYAN}${SYMBOL_ARROW} ${LANG_UPD_EXTRAS:-Ferramentas Gerais (Extras)}${COLOR_RESET}"
for f in "$FUNCTIONS_DIR/extras"/*.sh; do
    if [ -f "$f" ]; then
        source "$f"
        extras_count=$((extras_count + 1))
        printf "  ${COLOR_GRAY}▸${COLOR_RESET} $(basename "$f")\n"
    fi
done

echo ""
echo -e "${COLOR_GREEN}${SYMBOL_CHECK} ${pve_count} ${LANG_UPD_PVE_LOADED:-módulos PVE carregados}${COLOR_RESET}"
echo -e "${COLOR_GREEN}${SYMBOL_CHECK} ${pbs_count} ${LANG_UPD_PBS_LOADED:-módulos PBS carregados}${COLOR_RESET}"
echo -e "${COLOR_GREEN}${SYMBOL_CHECK} ${extras_count} ${LANG_UPD_EXTRAS_LOADED:-módulos Extras carregados}${COLOR_RESET}"
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

# ============================================================
# MOTOR GRÁFICO E MULTI-IDIOMA (i18n)
# ============================================================

# Banner e verificação inicial modernos
clear
echo -e "${COLOR_CYAN}${COLOR_BOLD}"
echo -e "╔═══════════════════════════════════════════════════════════════════════════════╗"
ui_print_header_line "" "" 79
ui_print_header_line "⚠️  ${LANG_DISCLAIMER_TITLE:-AVISO DE RESPONSABILIDADE}  ⚠️" "${COLOR_YELLOW}" 79
ui_print_header_line "" "" 79
echo -e "╠═══════════════════════════════════════════════════════════════════════════════╣"
echo -e "${COLOR_RESET}"
echo -e "${COLOR_YELLOW}${COLOR_BOLD}"
echo -e "  ${LANG_DISCLAIMER_1:-O uso deste script é de ${COLOR_RED}INTEIRA RESPONSABILIDADE${COLOR_YELLOW} do utilizador.}"
echo -e "${COLOR_RESET}"
echo ""
echo -e "${COLOR_WHITE}  • ${LANG_DISCLAIMER_2_1:-A pessoa ou empresa que forneceu o script ${COLOR_RED}NÃO SERÁ RESPONSÁVEL${COLOR_WHITE}}"
echo -e "    ${LANG_DISCLAIMER_2_2:-por quaisquer ${COLOR_RED}problemas ou danos causados${COLOR_WHITE} pelo uso do mesmo.}${COLOR_RESET}"
echo ""
echo -e "${COLOR_WHITE}  • ${LANG_DISCLAIMER_3_1:-Antes de utilizar, faça uma ${COLOR_GREEN}avaliação cuidadosa${COLOR_WHITE} e compreenda}"
echo -e "    ${LANG_DISCLAIMER_3_2:-as implicações do seu uso.}${COLOR_RESET}"
echo ""
echo -e "${COLOR_WHITE}  • ${LANG_DISCLAIMER_4_1:-${COLOR_RED}Certifique-se${COLOR_WHITE} de que o script é ${COLOR_GREEN}seguro e adequado${COLOR_WHITE} para}"
echo -e "    ${LANG_DISCLAIMER_4_2:-as suas necessidades antes de utilizá-lo.}${COLOR_RESET}"
echo ""
echo -e "${COLOR_CYAN}${COLOR_BOLD}"
echo -e "╠═══════════════════════════════════════════════════════════════════════════════╣"
ui_print_header_line "" "" 79
ui_print_left_header_line "${COLOR_YELLOW}➜${COLOR_CYAN}  ${LANG_DISCLAIMER_AGREE:-Ao pressionar ENTER você ${COLOR_RED}CONCORDA${COLOR_CYAN} com os termos acima}" "${COLOR_CYAN}" 79
ui_print_header_line "" "" 79
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

# Painel de Status dos Serviços e Configurações
show_system_status() {
    # 1. Backup de Configurações PVE
    local st_bkp="${COLOR_RED}🔴 ${LANG_ST_UNSCHEDULED:-Não agendado}${COLOR_RESET}"
    if crontab -l 2>/dev/null | grep -q "BKP-PVE" || [ -f "/TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh" ]; then
        if crontab -l 2>/dev/null | grep -q "BKP-PVE"; then
            st_bkp="${COLOR_GREEN}🟢 ${LANG_ST_SCHED_CRON:-Agendado (Cron)}${COLOR_RESET}"
        else
            st_bkp="${COLOR_YELLOW}🟡 ${LANG_ST_CREATED_NOCRON:-Criado (sem Cron)}${COLOR_RESET}"
        fi
    fi

    # 2. Monitoramento Térmico
    local st_temp="${COLOR_RED}🔴 ${LANG_ST_UNSCHEDULED:-Não agendado}${COLOR_RESET}"
    if crontab -l 2>/dev/null | grep -q "pve_temp_monitor.py"; then
        st_temp="${COLOR_GREEN}🟢 ${LANG_ST_ACTIVE_CRON2:-Ativo (Cron 2min)}${COLOR_RESET}"
    fi

    # 3. Sensores WebUI (PVE)
    local st_webui_sensors="${COLOR_RED}🔴 ${LANG_ST_DISABLED:-Desativado}${COLOR_RESET}"
    if grep -q "TCTI_SENSORS_MOD" /usr/share/perl5/PVE/API2/Nodes.pm 2>/dev/null; then
        st_webui_sensors="${COLOR_GREEN}🟢 ${LANG_ST_ENABLED:-Ativado}${COLOR_RESET}"
    fi

    # 4. Auto-inicialização Shell
    local st_autostart="${COLOR_RED}🔴 ${LANG_ST_DISABLED:-Desativado}${COLOR_RESET}"
    if [ -f "/etc/profile.d/tcti-proxmox-auto.sh" ]; then
        st_autostart="${COLOR_GREEN}🟢 ${LANG_ST_ENABLED:-Ativado}${COLOR_RESET}"
    fi

    # 5. Watchdog de VMs
    local st_watchdog="${COLOR_RED}🔴 ${LANG_ST_INACTIVE:-Inativo}${COLOR_RESET}"
    if crontab -l 2>/dev/null | grep -q "WATCHDOG" || [ -d "/TcTI/SCRIPTS/WATCHDOG" ]; then
        if crontab -l 2>/dev/null | grep -q "WATCHDOG"; then
            st_watchdog="${COLOR_GREEN}🟢 ${LANG_ST_ACTIVE_CRON:-Ativo (Cron)}${COLOR_RESET}"
        else
            st_watchdog="${COLOR_YELLOW}🟡 ${LANG_ST_CONFIGURED:-Configurado}${COLOR_RESET}"
        fi
    fi

    # 6. Bot Interativo Telegram
    local st_tg_bot="${COLOR_RED}🔴 ${LANG_ST_INACTIVE:-Inativo}${COLOR_RESET}"
    if systemctl is-active pve-telegram-bot &>/dev/null; then
        st_tg_bot="${COLOR_GREEN}🟢 ${LANG_ST_ACTIVE_RUN:-Ativo (Rodando)}${COLOR_RESET}"
    elif [ -f "/TcTI/SCRIPTS/telegram/.env" ]; then
        st_tg_bot="${COLOR_YELLOW}🟡 ${LANG_ST_CONF_STOPPED:-Configurado (Parado)}${COLOR_RESET}"
    fi

    # 7. Notificações Telegram
    local st_tg_notif="${COLOR_RED}🔴 ${LANG_ST_UNCONFIGURED:-Não configurado}${COLOR_RESET}"
    if [ -f "/TcTI/SCRIPTS/telegram/.env_notificacoes" ]; then
        local NOTIF_SERVER_NAME=""
        source "/TcTI/SCRIPTS/telegram/.env_notificacoes" 2>/dev/null
        st_tg_notif="${COLOR_GREEN}🟢 ${LANG_ST_CONFIGURED:-Configurado} (${NOTIF_SERVER_NAME:-OK})${COLOR_RESET}"
    fi

    # 8. Atualização Automática do Script
    local st_update="${COLOR_GREEN}🟢 ${LANG_ST_ENABLED_DEF:-Ativada (Padrão)}${COLOR_RESET}"
    if [ -f "/TcTI/SCRIPTS/.no_auto_update" ] || [ -f "$SCRIPT_DIR/.no_auto_update" ]; then
        st_update="${COLOR_RED}🔴 ${LANG_ST_DISABLED_FIX:-Desativada (Versão Fixa)}${COLOR_RESET}"
    fi

    # 9. Assistente de IA (Resumido em 1 linha única)
    local st_ia="${COLOR_RED}🔴 ${LANG_ST_UNCONFIGURED_F:-Não configurada}${COLOR_RESET}"
    if [ -f "/root/.ai_config" ]; then
        local AI_PROVIDER="" AI_MODEL="" AI_KEY=""
        source /root/.ai_config 2>/dev/null
        local prov="IA"
        case "$AI_PROVIDER" in
            gemini) prov="Google Gemini" ;;
            openai) prov="OpenAI" ;;
            claude) prov="Claude" ;;
            *) prov="${AI_PROVIDER:-IA}" ;;
        esac
        local mod="${AI_MODEL:-custom}"
        if [ -n "$AI_KEY" ]; then
            st_ia="${COLOR_GREEN}🟢 ${prov} (${mod}) | Key OK${COLOR_RESET}"
        else
            st_ia="${COLOR_YELLOW}🟡 ${prov} (${mod}) | Sem Key${COLOR_RESET}"
        fi
    elif [ -f "/root/.openai_key" ]; then
        st_ia="${COLOR_GREEN}🟢 OpenAI (gpt-4o-mini) | Key OK${COLOR_RESET}"
    fi

    echo -e "  ${COLOR_CYAN}${COLOR_BOLD}📊  ${LANG_MAIN_ST_TITLE:-STATUS DOS SERVIÇOS E CONFIGURAÇÕES:}${COLOR_RESET}"
    echo -e "  ${COLOR_GRAY}─────────────────────────────────────────────────────────────────${COLOR_RESET}"
    
    # Custom alignment function for labels
    print_status_line() {
        local icon="$1"
        local label="$2"
        local status="$3"
        
        # Max visual length for label column is 23 characters (e.g. "Backup Configs PVE   : ")
        local cjk_count=$(echo -n "$label" | grep -o -P '[\p{Han}]' | wc -l)
        local text_len=${#label}
        text_len=$(( text_len + cjk_count ))
        local max_len=23
        local spaces_needed=$(( max_len - text_len ))
        if [ $spaces_needed -lt 0 ]; then spaces_needed=0; fi
        local padding=$(printf '%*s' "$spaces_needed" "")
        
        echo -e "  ${COLOR_WHITE}${icon}  ${label}${padding}:${COLOR_RESET} ${status}"
    }

    print_status_line "📦" "${LANG_MAIN_ST_BKP:-Backup Configs PVE}" "$st_bkp"
    print_status_line "🌡️" "${LANG_MAIN_ST_TEMP:-Monitor Temp (Cron)}" "$st_temp"
    print_status_line "💻" "${LANG_MAIN_ST_WEBUI:-Sensores WebUI (PVE)}" "$st_webui_sensors"
    print_status_line "🚀" "${LANG_MAIN_ST_AUTOSTART:-Auto-Start Shell}" "$st_autostart"
    print_status_line "🐕" "${LANG_MAIN_ST_WATCHDOG:-Watchdog de VMs}" "$st_watchdog"
    print_status_line "🤖" "${LANG_MAIN_ST_TGBOT:-Bot Telegram (Inter)}" "$st_tg_bot"
    print_status_line "📣" "${LANG_MAIN_ST_TGNOTIF:-Notificação Telegram}" "$st_tg_notif"
    print_status_line "🔄" "${LANG_MAIN_ST_UPDATE:-Auto-Update Script}" "$st_update"
    print_status_line "🧙" "${LANG_MAIN_ST_IA:-Assistente de IA}" "$st_ia"

    echo -e "  ${COLOR_GRAY}─────────────────────────────────────────────────────────────────${COLOR_RESET}"
    echo ""
}

# Menu Principal Moderno
main_menu(){
    clear
    echo -e "${COLOR_CYAN}${COLOR_BOLD}"
    echo -e "╔═══════════════════════════════════════════════════════════════════════════════╗"
    ui_print_header_line ""
    ui_print_header_line "🚀  TcTI Proxmox Scripts - ${LANG_MAIN_TITLE:-Menu Principal}" "${COLOR_WHITE}"
    ui_print_header_line "${LANG_MAIN_VERSION:-Versão:} ${version}" "${COLOR_YELLOW}"
    ui_print_header_line "${LANG_MAIN_AUTHOR:-Desenvolvido por:} Marcelo Machado" "${COLOR_WHITE}"
    ui_print_header_line ""
    echo -e "╚═══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${COLOR_RESET}"
    echo ""
    show_system_status
    echo -e "${COLOR_BOLD}  ${LANG_SELECT_OPT:-Selecione uma opção:}${COLOR_RESET}"
    echo ""
    echo -e "  ${COLOR_CYAN}┌─────────────────────────────────────────────────────────────────┐${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                                 ${COLOR_CYAN}│${COLOR_RESET}"
    
    ui_print_menu_item "1" "${LANG_MAIN_OPT_1}" "${COLOR_YELLOW}" 65
    ui_print_menu_desc "${LANG_MAIN_DESC_1}" 65
    
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                                 ${COLOR_CYAN}│${COLOR_RESET}"
    
    ui_print_menu_item "2" "${LANG_MAIN_OPT_2}" "${COLOR_YELLOW}" 65
    ui_print_menu_desc "${LANG_MAIN_DESC_2}" 65
    
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                                 ${COLOR_CYAN}│${COLOR_RESET}"
    
    ui_print_menu_item "3" "${LANG_MAIN_OPT_3}" "${COLOR_YELLOW}" 65
    ui_print_menu_desc "${LANG_MAIN_DESC_3}" 65
    
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                                 ${COLOR_CYAN}│${COLOR_RESET}"
    
    ui_print_menu_item "4" "${LANG_MAIN_OPT_4}" "${COLOR_YELLOW}" 65
    ui_print_menu_desc "${LANG_MAIN_DESC_4}" 65
    
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                                 ${COLOR_CYAN}│${COLOR_RESET}"
    
    ui_print_menu_item "0" "${LANG_MAIN_OPT_0}" "${COLOR_RED}" 65
    
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                                 ${COLOR_CYAN}│${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}└─────────────────────────────────────────────────────────────────┘${COLOR_RESET}"
    echo ""
    echo -e "${COLOR_YELLOW}  ${LANG_TYPE_OPT:-Digite sua opção} ${COLOR_GRAY}${LANG_PRESS_ENTER:-(ou pressione ENTER para sair)}${COLOR_YELLOW}: ${COLOR_RESET}"
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
	    4) clear;
		menu_config
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

