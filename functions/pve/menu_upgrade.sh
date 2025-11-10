#!/bin/bash

# Menu de upgrade de versões do Proxmox VE

upgrade_menu(){
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
	echo -e "║              🚀 Upgrade de Versões do Proxmox VE                     ║"
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
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}1${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Upgrade da versão 5.x para 6.x${COLOR_RESET}                          ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}2${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Upgrade da versão 6.x para 7.x${COLOR_RESET}                          ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}3${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Upgrade da versão 7.x para 8.x${COLOR_RESET}                          ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                               ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_RED}0${COLOR_RESET} ${COLOR_RED}➜${COLOR_RESET}  ${COLOR_WHITE}Voltar${COLOR_RESET}                                                  ${COLOR_CYAN}│${COLOR_RESET}"
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
				mv /etc/apt/sources.list.d/pve-enterprise.list /root/
				clear
				systemctl stop pve-ha-lrm
				systemctl stop pve-ha-crm
				echo "deb http://download.proxmox.com/debian/corosync-3/ stretch main" > /etc/apt/sources.list.d/corosync3.list
				apt update
				apt dist-upgrade -y
				systemctl start pve-ha-lrm
				systemctl start pve-ha-crm
				apt update
				apt dist-upgrade -y
				sed -i 's/stretch/buster/g' /etc/apt/sources.list
				echo "deb http://download.proxmox.com/debian/pve buster pve-no-subscription" > /etc/apt/sources.list.d/sources.list
				sed -i -e 's/stretch/buster/g' /etc/apt/sources.list.d/pve-install-repo.list 
				echo "deb http://download.proxmox.com/debian/ceph-luminous buster main" > /etc/apt/sources.list.d/ceph.list
				apt update
				apt dist-upgrade -y
				rm /etc/apt/sources.list.d/corosync3.list
				apt update
				apt dist-upgrade -y
				apt remove linux-image-amd64
				systemctl disable display-manager
				clear
				read -p "Pressione uma tecla para continuar..."
				clear
				update_menu;
					;;
				2) clear;
				mv /etc/apt/sources.list.d/pve-enterprise.list /root/
				clear
				sed -i '/proxmox/d' /etc/apt/sources.list
				echo	"deb http://download.proxmox.com/debian/pve buster pve-no-subscription"	>> /etc/apt/sources.list
				dpkg --configure -a
				apt update
				apt upgrade -y
				sed -i '/proxmox/d' /etc/apt/sources.list
				sed -i '/debian/d' /etc/apt/sources.list
				sed -i '/update/d' /etc/apt/sources.list
				echo "deb http://security.debian.org/debian-security bullseye-security main contrib" >> /etc/apt/sources.list
				echo "deb http://ftp.debian.org/debian bullseye-updates main contrib" >> /etc/apt/sources.list
				echo "deb http://download.proxmox.com/debian/pve bullseye pve-no-subscription" >> /etc/apt/sources.list
				echo "deb http://ftp.debian.org/debian bullseye main contrib" >> /etc/apt/sources.list
				apt update
				apt upgrade -y
				apt dist-upgrade
				systemctl disable display-manager
				clear
				read -p "Pressione uma tecla para continuar..."
				clear
				upgrade_menu;	
					;;
				3) clear;
				mv /etc/apt/sources.list.d/pve-enterprise.list /root/
				clear
				apt update
				apt upgrade -y
				sed -i '/proxmox/d' /etc/apt/sources.list
				sed -i '/debian/d' /etc/apt/sources.list
				sed -i '/update/d' /etc/apt/sources.list
				echo "deb http://security.debian.org/debian-security bookworm-security main contrib" >> /etc/apt/sources.list
				echo "deb http://ftp.debian.org/debian bookworm-updates main contrib" >> /etc/apt/sources.list
				echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" >> /etc/apt/sources.list
				echo "deb http://ftp.debian.org/debian bookworm main contrib" >> /etc/apt/sources.list
				apt update
				apt upgrade -y
				apt dist-upgrade
				systemctl disable display-manager
				clear
				read -p "Pressione uma tecla para continuar..."
				clear
				upgrade_menu;	
					;;
				0) clear;
				update_menu;
					;;
				*)clear;
				update_menu;
					;;
			esac
		fi
	done
}

