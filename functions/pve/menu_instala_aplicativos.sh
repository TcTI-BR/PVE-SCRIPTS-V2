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
	echo -e "╔═════════════════════════════════════════════════════════════════════╗"
	echo -e "║                                                                     ║"
	echo -e "║            📦 Instalação de Aplicativos e Ferramentas              ║"
	echo -e "║                                                                     ║"
	echo -e "╚═════════════════════════════════════════════════════════════════════╝"
	echo -e "${COLOR_RESET}"
	echo ""
	echo -e "${COLOR_BOLD}  Selecione uma opção:${COLOR_RESET}"
	echo ""
	echo -e "  ${COLOR_CYAN}┌───────────────────────────────────────────────────────────────┐${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                               ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}1${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}TacticalRMM - Remote Monitoring & Management${COLOR_RESET}      ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}2${COLOR_RESET} ${COLOR_GRAY}➜  Zabbix Agent${COLOR_RESET} ${COLOR_GRAY}(Em breve)${COLOR_RESET}                        ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}3${COLOR_RESET} ${COLOR_GRAY}➜  Outros aplicativos${COLOR_RESET} ${COLOR_GRAY}(Em breve)${COLOR_RESET}                   ${COLOR_CYAN}│${COLOR_RESET}"
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

