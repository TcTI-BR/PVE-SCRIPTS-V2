#!/bin/bash

# Função para destrancar, desligar e reiniciar VMs

destranca_desliga(){
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
	echo -e "${MENU}**${NUMBER} 1)${MENU} Destranca VM ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 2)${MENU} Destranca e desliga a VM ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 3)${MENU} Destranca, desliga e reinicia VM ${NORMAL}"
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
		echo "Qual ID da VM? EX: 230"
		read DESTRANCAVM
		rm /var/lock/qemu-server/lock-$DESTRANCAVM.conf
		qm unlock $DESTRANCAVM
		echo "VM destrancada com sucesso!"
		read -p "Pressione uma tecla para continuar..."
		clear	  
		destranca_desliga
			;;
		2) clear;
		echo "Qual ID da VM? EX: 230"
		read DESTRANCADESLIGAVM
		rm /var/lock/qemu-server/lock-$DESTRANCADESLIGAVM.conf
		qm unlock $DESTRANCADESLIGAVM
		sleep 10
		qm stop $DESTRANCADESLIGAVM
		sleep 5
		echo "VM destrancada e desligada com sucesso!"
		read -p "Pressione uma tecla para continuar..."
		clear
		destranca_desliga	
			;;
		3) clear;
		echo "Qual ID da VM? EX: 230"
		read DESTRANCADESLIGAREINICIAVM
		rm /var/lock/qemu-server/lock-$DESTRANCADESLIGAREINICIAVM.conf
		qm unlock $DESTRANCADESLIGAREINICIAVM
		sleep 10
		qm stop $DESTRANCADESLIGAREINICIAVM
		sleep 5
		qm start $DESTRANCADESLIGAREINICIAVM
		sleep 2
		echo "VM destrancada, desligada e reiniciada!"
		read -p "Pressione uma tecla para continuar..."
		clear
		destranca_desliga	
			;;
		0) clear;
		tweaks_menu;
			;;
		*) clear
		tweaks_menu;
			;;			
      esac
    fi
  done
destranca_desliga
}

