#!/bin/bash

# Funções de configuração de rede do Proxmox VE

lan_menu(){
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
	echo -e "${MENU}**${NUMBER} 1)${MENU} Configura rede${NORMAL}"
	echo -e "${MENU}**${NUMBER} 2)${MENU} Configura DNS ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 3)${MENU} Configura hosts ${NORMAL}"
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
		1) clear
		nano /etc/network/interfaces
		read -p "Pressione uma tecla para continuar..."
		clear
		lan_menu
			;;
		2) clear;
		nano /etc/resolv.conf
		read -p "Pressione uma tecla para continuar..."
		clear	  
		lan_menu
			;;
		3) clear;
		nano /etc/hosts
		read -p "Pressione uma tecla para continuar..."
		clear
		lan_menu	
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

