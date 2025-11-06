#!/bin/bash

# Funções de atualização e upgrade do Proxmox VE

update_menu(){
	clear
	NORMAL=`echo "\033[m"`
	MENU=`echo "\033[36m"` #Blue
	NUMBER=`echo "\033[33m"` #yellow
	FGRED=`echo "\033[41m"`
	RED_TEXT=`echo "\033[31m"`
	ENTER_LINE=`echo "\033[33m"`
	echo -e "${MENU}********* Script ($version) para Proxmox Virtual Environment *********${NORMAL}"
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
		upgrade_menu
			;;
		2) clear;
		mv /etc/apt/sources.list.d/pve-enterprise.list /root/
		clear
		sed -i '/subscription/d' /etc/apt/sources.list
		echo "deb http://download.proxmox.com/debian/pve $distribution pve-no-subscription" >> /etc/apt/sources.list
		apt update
		apt upgrade -y
		apt install libsasl2-modules -y
		apt install lm-sensors
		apt install ifupdown2 -y
		apt install ntfs-3g -y
		apt install ethtool -y
		apt install zip -y
		apt install mutt -y 			
		read -p "Pressione uma tecla para continuar..."
		clear 
		update_menu;	
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

upgrade_menu(){
	clear
	NORMAL=`echo "\033[m"`
	MENU=`echo "\033[36m"` #Blue
	NUMBER=`echo "\033[33m"` #yellow
	FGRED=`echo "\033[41m"`
	RED_TEXT=`echo "\033[31m"`
	ENTER_LINE=`echo "\033[33m"`
	echo -e "${MENU}********* Script ($version) para Proxmox Virtual Environment *********${NORMAL}"
	echo -e "${MENU}********************** Por Marcelo Machado ****************************${NORMAL}"
	echo " "
	echo -e "${MENU}**${NUMBER} 1)${MENU} Upgrade da versão 5x para a versão 6x ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 2)${MENU} Upgrade da versão 6x para a versão 7x ${NORMAL}"
 	echo -e "${MENU}**${NUMBER} 3)${MENU} Upgrade da versão 7x para a versão 8x ${NORMAL}"
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

pve_menu(){
    clear
    NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"` #Azul
    NUMBER=`echo "\033[33m"` #Amarelo
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
    ENTER_LINE=`echo "\033[33m"`
    echo -e "${MENU}********* Script ($version) para Proxmox Virtual Environment *********${NORMAL}"
    echo -e "${MENU}********************** Por Marcelo Machado ****************************${NORMAL}"
    echo " "
    echo -e "${MENU}**${NUMBER} 1)${MENU} Atualização, instalação e upgrade do sistema ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 2)${MENU} Ferramentas de disco ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 3)${MENU} Tarefas de backup ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 4)${MENU} Configuração do email ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 5)${MENU} Operações de VMs ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 6)${MENU} Configurações e ajustes ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 7)${MENU} Configurações de rede ${NORMAL}"	
    echo -e "${MENU}**${NUMBER} 8)${MENU} Comandos e informações úteis  ${NORMAL}"	
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
		update_menu
			;;
	    2) clear;
		disco_menu
			;;
	    3) clear;
		bkp_menu
			;;
	    4) clear;
		email_menu
			;;
	    5) clear;
		vm_operations_menu
			;;
	    6) clear;
		tweaks_menu
			;;
	    7) clear;
		lan_menu
			;;
	    8) clear;
		com_menu
			;;	  
		0)
		clear
		main_menu
			;;
		*)
		clear
		main_menu
			;;
      esac
    fi
  done
  pve_menu
}

