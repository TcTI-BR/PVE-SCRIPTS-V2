#!/bin/bash

# Menu de atualização do Proxmox Backup Server

update_pbs_menu(){
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
	echo -e "║           📦 Atualização, Instalação e Upgrade do Sistema          ║"
	echo -e "║                                                                     ║"
	echo -e "╚═════════════════════════════════════════════════════════════════════╝"
	echo -e "${COLOR_RESET}"
	echo ""
	echo -e "${COLOR_BOLD}  Selecione uma opção:${COLOR_RESET}"
	echo ""
	echo -e "  ${COLOR_CYAN}┌───────────────────────────────────────────────────────────────┐${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                               ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}1${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Upgrade de versões${COLOR_RESET}                                ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}2${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Atualização do sistema e aplicativos comuns${COLOR_RESET}       ${COLOR_CYAN}│${COLOR_RESET}"
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
			exit;
		else
			case $opt in
				1) clear;
				upgrade_pbs_menu
				;;
				2) clear;
				mv /etc/apt/sources.list.d/pbs-enterprise.list /root/
				echo "deb http://download.proxmox.com/debian/pbs $distribution pbs-no-subscription" >> /etc/apt/sources.list
				apt update
				apt upgrade -y
				apt install libsasl2-modules -y
				apt install lm-sensors
				apt install ifupdown2 -y
				apt install ethtool -y
				apt install hdparm -y
				
				read -p "Pressione uma tecla para continuar..."
				clear 
				update_pbs_menu;	
					;;
				0) clear;
				pbs_menu;
				;;
				x)exit;
				;;
				\n)exit;
				;;
				*)clear;
				pbs_menu;
				;;
			esac
		fi
	done
}

