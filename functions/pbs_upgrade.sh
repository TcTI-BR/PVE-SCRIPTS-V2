#!/bin/bash

# Funções de atualização e upgrade do Proxmox Backup Server

pbs_menu(){
    clear
    NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"` #Azul
    NUMBER=`echo "\033[33m"` #Amarelo
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
    ENTER_LINE=`echo "\033[33m"`
    echo -e "${MENU}************ Script ($version) para Proxmox Backup Server ************${NORMAL}"
    echo -e "${MENU}********************** Por Marcelo Machado ****************************${NORMAL}"
    echo " "
    echo -e "${MENU}**${NUMBER} 1)${MENU} Atualização, instalação e upgrade do sistema ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 2)${MENU} Ferramentas de disco ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 3)${MENU} Configuração do email ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 4)${MENU} Configurações e ajustes ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 5)${MENU} Configurações de rede ${NORMAL}"	
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
		update_pbs_menu
      ;;
	     2) clear;
		disco_pbs_menu
	  ;;
	     3) clear;
		email_pbs_menu
      ;;
	     4) clear;
		tweaks_pbs_menu
	  ;;
	     5) clear;
		lan_pbs_menu
      ;;	  
      0)
	  clear
      main_menu
      ;;
      esac
    fi
  done
  pve_menu
}

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

