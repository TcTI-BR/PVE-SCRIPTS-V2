#!/bin/bash

# Menu de upgrade de versões do Proxmox Backup Server

upgrade_pbs_menu(){
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
	echo -e "║              🚀 Upgrade de Versões do Proxmox PBS                   ║"
	echo -e "║                                                                     ║"
	echo -e "╚═════════════════════════════════════════════════════════════════════╝"
	echo -e "${COLOR_RESET}"
	echo ""
	echo -e "${COLOR_YELLOW}${COLOR_BOLD}  ⚠️  ATENÇÃO:${COLOR_RESET}"
	echo -e "${COLOR_YELLOW}  Faça backup antes de realizar qualquer upgrade!${COLOR_RESET}"
	echo ""
	echo -e "${COLOR_BOLD}  Selecione a versão de destino:${COLOR_RESET}"
	echo ""
	echo -e "  ${COLOR_CYAN}┌───────────────────────────────────────────────────────────────┐${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                               ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}1${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Upgrade da versão 1.x para 2.x${COLOR_RESET}                    ${COLOR_CYAN}│${COLOR_RESET}"
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
				mv /etc/apt/sources.list.d/pbs-enterprise.list /root/
				sed -i 's/buster\/updates/bullseye-security/g;s/buster/bullseye/g' /etc/apt/sources.list
				echo "deb http://download.proxmox.com/debian/pbs bullseye pbs-no-subscription" >> /etc/apt/sources.list
				apt update
				systemctl stop proxmox-backup-proxy.service proxmox-backup.servic
				apt update
				apt dist-upgrade -y
				apt upgrade -y 
				systemctl start proxmox-backup-proxy.service proxmox-backup.service
				clear 
				update_pbs_menu;
				;;
				0) clear;
				update_pbs_menu;
				;;
				x)exit;
				;;
				\n)exit;
				;;
				*)clear;
				update_pbs_menu;
				;;
			esac
		fi
	done
}

