#!/bin/bash

# Menu de ferramentas de disco do Proxmox Backup Server

disco_pbs_menu(){
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
	echo -e "║                    💾 Ferramentas de Disco                          ║"
	echo -e "║                                                                     ║"
	echo -e "╚═════════════════════════════════════════════════════════════════════╝"
	echo -e "${COLOR_RESET}"
	echo ""
	echo -e "${COLOR_BOLD}  Selecione uma opção:${COLOR_RESET}"
	echo ""
	echo -e "  ${COLOR_CYAN}┌───────────────────────────────────────────────────────────────┐${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                               ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}1${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Configura discos${COLOR_RESET}                                  ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}2${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Teste de velocidade dos discos${COLOR_RESET}                    ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}3${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Verifica setores defeituosos em discos${COLOR_RESET}            ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}4${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Verifica o SMART do disco${COLOR_RESET}                         ${COLOR_CYAN}│${COLOR_RESET}"
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
				1) clear
				lsblk -o NAME,SIZE,LABEL,MOUNTPOINT,FSTYPE
				echo "Qual o disco que vai ser preparado? EX: sda / nvme0n1"
				read FORMATADISCO
				echo "Qual o nome do Datastore? EX: BACKUP_REDE / STORE_01 / BACKUP_01"
				read STORAGE
				echo "O disco será para backup ou VM?: Digite exatamente "images" para VM ou "backup" para BACKUP sem as aspas"
				echo -e "g\nn\np\n1\n\n\nw" | fdisk /dev/$FORMATADISCO
				mkfs.ext4 -L $STORAGE /dev/$FORMATADISCO
				mkdir -p /mnt/$STORAGE
				sed -i /"$STORAGE"/d /etc/fstab
				echo "" >> /etc/fstab
				echo "LABEL=$STORAGE /mnt/$STORAGE ext4 defaults,auto,nofail 0 0" >> /etc/fstab
				mount -a
				proxmox-backup-manager datastore create $STORAGE /mnt/$STORAGE
				read -p "Pressione uma tecla para continuar..."
				clear
				disco_pbs_menu
				;;
				2) clear
				lsblk -o NAME,SIZE,LABEL,MOUNTPOINT,FSTYPE
				echo "Qual disco será testado o desempenho? EX: sda / nvme0n1"
				read TESTEDISCO
				clear
				hdparm -tT /dev/$TESTEDISCO
				read -p "Pressione uma tecla para continuar..."
				clear
				disco_pbs_menu
				;;
				3) clear
				lsblk -o NAME,SIZE,LABEL,MOUNTPOINT,FSTYPE
				echo "Qual disco será testado os setores? EX: sda / nvme0n1"
				read TESTESETORES
				clear
				badblocks -sv -c 10240 /dev/$TESTESETORES
				read -p "Pressione uma tecla para continuar..."
				disco_pbs_menu
				;;
				4) clear
				lsblk -o NAME,SIZE,LABEL,MOUNTPOINT,FSTYPE
				echo "Qual disco será verificado o status do SMART? EX: sda / nvme0n1"
				read TESTESMART
				clear
				smartctl -a /dev/$TESTESMART
				read -p "Pressione uma tecla para continuar..."
				disco_pbs_menu
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

