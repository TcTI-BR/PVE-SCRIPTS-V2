#!/bin/bash

# Menu de instalação de aplicativos

instala_aplicativos_menu(){
	clear
	NORMAL=`echo "\033[m"`
	MENU=`echo "\033[36m"`
	NUMBER=`echo "\033[33m"`
	FGRED=`echo "\033[41m"`
	RED_TEXT=`echo "\033[31m"`
	ENTER_LINE=`echo "\033[33m"`
	
	echo -e "${COLOR_CYAN}${COLOR_BOLD}"
	echo -e "╔════════════════════════════════════════════════════════════════════╗"
	echo -e "║             📦 Instalação de Aplicativos e Ferramentas             ║"
	echo -e "╚════════════════════════════════════════════════════════════════════╝"
	echo -e "${COLOR_RESET}"
	echo ""
	echo -e "${COLOR_WHITE}Selecione o aplicativo que deseja instalar:${COLOR_RESET}"
	echo ""
	echo -e "${MENU}**${NUMBER} 1)${MENU} TacticalRMM - Remote Monitoring & Management ${NORMAL}"
	echo -e "${COLOR_GRAY}       Agente de monitoramento remoto (Netvolt)${NORMAL}"
	echo ""
	echo -e "${MENU}**${NUMBER} 2)${MENU} ${COLOR_GRAY}Zabbix Agent (Em breve)${NORMAL}"
	echo -e "${COLOR_GRAY}       Sistema de monitoramento de infraestrutura${NORMAL}"
	echo ""
	echo -e "${MENU}**${NUMBER} 3)${MENU} ${COLOR_GRAY}Outros aplicativos (Em breve)${NORMAL}"
	echo ""
	echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar ao menu anterior ${NORMAL}"
	echo ""
	echo -e "${MENU}***********************************************************************${NORMAL}"
	echo -e "${ENTER_LINE}Digite um número dentre as opções acima ou pressione ${RED_TEXT}ENTER ${ENTER_LINE}para sair.${NORMAL}"
	read -rsn1 opt
	
	while [ opt != '' ]
	do
		if [[ $opt = "" ]]; then
			update_menu
		else
			case $opt in
				1) clear;
				   instala_tactical_rmm_menu
				   ;;
				2) clear;
				   echo -e "${COLOR_YELLOW}${SYMBOL_INFO} Funcionalidade em desenvolvimento...${COLOR_RESET}"
				   sleep 2
				   instala_aplicativos_menu
				   ;;
				3) clear;
				   echo -e "${COLOR_YELLOW}${SYMBOL_INFO} Funcionalidade em desenvolvimento...${COLOR_RESET}"
				   sleep 2
				   instala_aplicativos_menu
				   ;;
				0) clear;
				   update_menu
				   ;;
				*) clear;
				   update_menu
				   ;;
			esac
		fi
	done
}


