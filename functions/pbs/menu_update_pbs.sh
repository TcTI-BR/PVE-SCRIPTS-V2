#!/bin/bash

# Menu de atualização do Proxmox Backup Server

update_pbs_menu(){

	NORMAL=`echo "\033[m"`
	MENU=`echo "\033[36m"` #Blue
	NUMBER=`echo "\033[33m"` #yellow
	FGRED=`echo "\033[41m"`
	RED_TEXT=`echo "\033[31m"`
	ENTER_LINE=`echo "\033[33m"`
	echo -e "${MENU}************ Script ($version) para Proxmox Backup Server ************${NORMAL}"
	echo -e "${MENU}********************** Por Marcelo Machado ****************************${NORMAL}"
	echo " "
	echo -e "${MENU}**${NUMBER} 1)${MENU} Upgrade de versões ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 2)${MENU} Atualização do sistema e instalação de aplicativos mais utilizados ${NORMAL}"
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

