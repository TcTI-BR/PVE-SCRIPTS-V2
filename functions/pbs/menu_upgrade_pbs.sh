#!/bin/bash

# Menu de upgrade de versões do Proxmox Backup Server

upgrade_pbs_menu(){

	NORMAL=`echo "\033[m"`
	MENU=`echo "\033[36m"` #Blue
	NUMBER=`echo "\033[33m"` #yellow
	FGRED=`echo "\033[41m"`
	RED_TEXT=`echo "\033[31m"`
	ENTER_LINE=`echo "\033[33m"`
	echo -e "${MENU}************ Script ($version) para Proxmox Backup Server ************${NORMAL}"
	echo -e "${MENU}********************** Por Marcelo Machado ****************************${NORMAL}"
	echo " "
	echo -e "${MENU}**${NUMBER} 1)${MENU} Upgrade da versão 1x para a versão 2x ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar ${NORMAL}"
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

