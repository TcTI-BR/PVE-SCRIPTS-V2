#!/bin/bash

# Menu principal do Proxmox Backup Server

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

