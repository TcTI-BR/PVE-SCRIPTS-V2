#!/bin/bash

# Menu de ferramentas de disco do Proxmox VE

disco_menu(){
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
	echo -e "║                    💾 Ferramentas de Disco                           ║"
	echo -e "║                                                                     ║"
	echo -e "╚═════════════════════════════════════════════════════════════════════╝"
	echo -e "${COLOR_RESET}"
	echo ""
	echo -e "${COLOR_BOLD}  Selecione uma opção:${COLOR_RESET}"
	echo ""
	echo -e "  ${COLOR_CYAN}┌───────────────────────────────────────────────────────────────┐${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                               ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}1${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Configura discos${COLOR_RESET}                                        ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}2${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Teste de velocidade dos discos${COLOR_RESET}                          ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}3${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Verifica setores defeituosos em discos${COLOR_RESET}                  ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}4${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Verifica o SMART do disco${COLOR_RESET}                               ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}5${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Remove o storage local-lvm${COLOR_RESET}                              ${COLOR_CYAN}│${COLOR_RESET}"
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
		1) clear
		lsblk -o NAME,SIZE,LABEL,MOUNTPOINT,FSTYPE
		echo "Qual o disco que vai ser preparado? EX: sda / nvme0n1"
		read FORMATADISCO
		echo "Qual o nome do Storage? EX: VM01 / RECOVER / BACKUP_2HD / BACKUP_REDE / EXTERNO_TERCA / EXTERNO_QUINTA"
		read STORAGE
		echo "O disco será para backup ou VM?: Digite exatamente "images" para VM ou "backup" para BACKUP sem as aspas"
		read IMAGEBACKUP
		pvesm remove $STORAGE
		echo -e "g\nn\np\n1\n\n\nw" | fdisk /dev/$FORMATADISCO
		mkfs.ext4 -L $STORAGE /dev/$FORMATADISCO
		mkdir -p /mnt/$STORAGE
		sed -i /"$STORAGE"/d /etc/fstab
		echo "" >> /etc/fstab
		echo "LABEL=$STORAGE /mnt/$STORAGE ext4 defaults,auto,nofail 0 0" >> /etc/fstab
		mount -a
		pvesm add dir $STORAGE --path /mnt/$STORAGE --content $IMAGEBACKUP 
		read -p "Pressione uma tecla para continuar..."
		clear
		disco_menu
			;;
		2) clear
		lsblk -o NAME,SIZE,LABEL,MOUNTPOINT,FSTYPE
		echo "Qual disco será testado o desempenho? EX: sda / nvme0n1"
		read TESTEDISCO
		clear
		hdparm -tT /dev/$TESTEDISCO
		read -p "Pressione uma tecla para continuar..."
		clear
		disco_menu
			;;
		3) clear
		lsblk -o NAME,SIZE,LABEL,MOUNTPOINT,FSTYPE
		echo "Qual disco será testado os setores? EX: sda / nvme0n1"
		read TESTESETORES
		clear
		badblocks -sv -c 10240 /dev/$TESTESETORES
		read -p "Pressione uma tecla para continuar..."
		disco_menu
			;;
		4) clear
		lsblk -o NAME,SIZE,LABEL,MOUNTPOINT,FSTYPE
		echo "Qual disco será verificado o status do SMART? EX: sda / nvme0n1"
		read TESTESMART
		clear
		smartctl -a /dev/$TESTESMART
		read -p "Pressione uma tecla para continuar..."
		disco_menu
			;;
		5) clear
		lvremove /dev/pve/data
		lvresize -l +100%FREE /dev/pve/root
		resize2fs /dev/mapper/pve-root
		pvesm remove local-lvm
		read -p "Pressione uma tecla para continuar..."
		disco_menu
			;;			
		0) clear;
		pve_menu;
			;;
		*)clear;
		pve_menu;
			;;
      esac
    fi
  done
}

