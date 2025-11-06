#!/bin/bash

# Script modular para Proxmox VE e PBS
# Versão: V002.R001
# Por: Marcelo Machado

version=V002.R001

# Define o diretório base do script, independentemente de onde é chamado
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Variáveis de Repositório
BASE_URL="https://raw.githubusercontent.com/TcTI-BR/PVE-SCRIPTS-V2/main"
FUNCTIONS_DIR="$SCRIPT_DIR/functions"

# Lista de arquivos de função necessários
REQUIRED_FILES=(
    "$FUNCTIONS_DIR/pve_upgrade.sh"
    "$FUNCTIONS_DIR/pve_disco.sh"
    "$FUNCTIONS_DIR/pve_backup.sh"
    "$FUNCTIONS_DIR/pve_email.sh"
    "$FUNCTIONS_DIR/pve_vm_operations.sh"
    "$FUNCTIONS_DIR/pve_tweaks.sh"
    "$FUNCTIONS_DIR/pve_network.sh"
    "$FUNCTIONS_DIR/pve_commands.sh"
    "$FUNCTIONS_DIR/pbs_upgrade.sh"
    "$FUNCTIONS_DIR/pbs_disco.sh"
    "$FUNCTIONS_DIR/pbs_email.sh"
    "$FUNCTIONS_DIR/pbs_tweaks.sh"
    "$FUNCTIONS_DIR/pbs_network.sh"
)

# Função de atualização/loader
run_updater() {
    echo "Verificando atualizações dos scripts em $SCRIPT_DIR..."
    mkdir -p "$FUNCTIONS_DIR"
    
    for FILE_PATH in "${REQUIRED_FILES[@]}"; do
        # Extrai o caminho relativo (ex: functions/arquivo.sh)
        RELATIVE_PATH="${FILE_PATH#"$SCRIPT_DIR/"}"
        REMOTE_URL="$BASE_URL/$RELATIVE_PATH"
        TMP_FILE="/tmp/$(basename "$FILE_PATH").remote"
        
        echo "Verificando $RELATIVE_PATH..."
        if ! curl -sL -o "$TMP_FILE" "$REMOTE_URL"; then
            echo "Erro ao baixar $REMOTE_URL"
            continue
        fi
        
        if [ ! -f "$FILE_PATH" ]; then
            mv "$TMP_FILE" "$FILE_PATH"
            chmod +x "$FILE_PATH"
            echo "Novo script instalado: $RELATIVE_PATH"
        elif ! diff -q "$FILE_PATH" "$TMP_FILE" >/dev/null; then
            mv "$TMP_FILE" "$FILE_PATH"
            chmod +x "$FILE_PATH"
            echo "Script atualizado: $RELATIVE_PATH"
        else
            rm "$TMP_FILE" # Sem mudanças
        fi
    done
    echo "Verificação concluída."
}

# Se o script for chamado com o argumento "update"
if [ "$1" == "update" ]; then
    run_updater
    exit 0
fi

# Se for execução normal (sem "update"), rodar o updater E depois o menu
run_updater

# Carrega todas as funções
echo "Carregando funções..."
for f in "$FUNCTIONS_DIR"/*.sh; do
    if [ -f "$f" ]; then
        source "$f"
    fi
done

# -----------------VARIAVEIS DE SISTEMA----------------------
dnstesthost=google.com.br
pve_log_folder="/var/log/pve/tasks/"
proxmoxlib="/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js"
distribution=$(. /etc/*-release;echo $VERSION_CODENAME)
execdir=$(dirname $0)
hostname=$(hostname)
date=$(date +%Y_%m_%d-%H_%M_%S)
# ---------------FIM DAS VARIAVEIS DE SISTEMA-----------------

# Banner e verificação inicial
clear
echo -e "\033[33m *********************************************************************************** \033[0m"
echo -e "\033[33m * Atenção! O uso do script fornecido é de inteira responsabilidade do utilizador. *\n * A pessoa ou empresa que forneceu o script não será responsável por quaisquer    *\n *\033[31mproblemas ou danos causados\033[33m pelo uso do mesmo.                                   *\033[0m"
echo -e "\033[33m *                                                                                 * \033[0m"
echo -e "\033[33m * Antes de utilizar o script, é importante que você faça uma avaliação cuidadosa e*\n *compreenda as implicações do seu uso. \033[31mCertifique-se de que o script é            \033[33m*\n *\033[0m\033[31mseguro e adequado\033[33m para as suas necessidades antes de utilizá-lo.                 *\033[0m"
echo -e "\033[33m *                                                                                 * \033[0m"
echo -e "\033[33m * Em resumo, \033[31mutilize o script por sua conta e risco\033[33m. A pessoa ou empresa          *\n *que forneceu o script não será responsável por quaisquer problemas ou            *\n *danos causadospelo seu uso.                                                      *\033[0m"
echo -e "\033[33m *                                                                                 * \033[0m"
echo -e "\033[33m * Ao pressionar uma tecla você concorda com os riscos...                          *\033[0m"
echo -e "\033[33m *********************************************************************************** \033[0m"
read -p  " "
clear

# Verificando se é root
if [[ $(id -u) -ne 0 ]] ; then echo "- Por favor execute com o root / sudo" ; exit 1 ; fi

# Menu Principal
main_menu(){
    clear
    NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"` #Azul
    NUMBER=`echo "\033[33m"` #Amarelo
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
    ENTER_LINE=`echo "\033[33m"`
    echo -e "${MENU}******************* Script ($version) para Proxmox *******************${NORMAL}"
    echo -e "${MENU}********************** Por Marcelo Machado ****************************${NORMAL}"
    echo " "
    echo -e "${MENU}**${NUMBER} 1)${MENU} Proxmox Virtual Environment ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 2)${MENU} Proxmox Backup Server ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 0)${MENU} Sair ${NORMAL}"
    echo " "
    echo -e "${MENU}***********************************************************************${NORMAL}"
    echo -e "${ENTER_LINE}Digite um numero dentre as opções acima ou pressione ${RED_TEXT}ENTER ${ENTER_LINE}para sair.${NORMAL} "
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

