#!/bin/bash

# Funções de comandos e informações úteis do Proxmox VE

com_menu(){
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
	echo -e "${MENU}**${NUMBER} 1)${MENU} Comandos linux ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 2)${MENU} Comandos PVE ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 3)${MENU} Caminho e informações gerais ${NORMAL}"
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
		echo "ip address = Ver os IPs setados nas interfaces"
		echo "df -h = Lista o tamanho dos pontos de montagem"
		echo "rsync --progress /CAMINHO_DE_ORIGEM.EXTENSÃO   /CAMINHO_DE_DESTINO/ = Comando para copiar com progressão"
		echo ""
		echo ""
		read -p "Pressione uma tecla para continuar..."
		clear
		com_menu
			;;
		2) clear
		echo "qm stop|shutdown|start|unlock VMID = comando para desligar|desligar via sistema|ligar|desbloquear VMs"
		echo "qm  VMID = Destranca VM bloqueada"
		echo ""
		echo ""
		read -p "Pressione uma tecla para continuar..."
		clear
		com_menu
			;;
		3) clear
		echo "/etc/pve/nodes/nome-do-node/qemu-server/ = Caminho onde ficam os VMIDS"
		echo "/var/lib/vz/template/iso = Caminho os ficam os arquivos ISO"
		echo ""
		echo ""
		read -p "Pressione uma tecla para continuar..."
		clear
		com_menu
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

