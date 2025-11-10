#!/bin/bash

# Menu para configurar watchdog de VMs

watch_dog(){
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
	echo -e "${MENU}**${NUMBER} 1)${MENU} Cria o agendamento do watchdog de 10 em 10 minutos ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 2)${MENU} Remove o agendamento do watchdog ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 3)${MENU} Lista as VMs que estão monitoradas pelo watchdog ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 4)${MENU} Adiciona uma VM ao monitoramento do watchdog ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 5)${MENU} Remove uma VM do monitoramento do watchdog ${NORMAL}"
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
        sed -i '/WATCHDOG/d' /var/spool/cron/crontabs/root
        echo "*/10 * * * * /TcTI/SCRIPTS/WATCHDOG/*.sh" >> /var/spool/cron/crontabs/root
		read -p "Pressione uma tecla para continuar..."
		clear	  
		watch_dog
			;;
		2) clear;
        sed -i '/WATCHDOG/d' /var/spool/cron/crontabs/root
		read -p "Pressione uma tecla para continuar..."
		clear
		watch_dog
			;;
		3) clear;
		ls -t /TcTI/SCRIPTS/WATCHDOG/
		read -p "Pressione uma tecla para continuar..."
		clear
		watch_dog
			;;
		4) clear;
		echo "Qual ID da VM? EX: 230"
		read WATCHDOGVMID
		echo "Qual IP da VM? EX: 192.168.0.230"
		read WATCHDOGVMIP
		mkdir /TcTI/SCRIPTS/WATCHDOG/
		touch /TcTI/SCRIPTS/WATCHDOG/$WATCHDOGVMID.sh
		echo '#!/bin/bash' > /TcTI/SCRIPTS/WATCHDOG/$WATCHDOGVMID.sh
		echo 'ping -c4 $WATCHDOGVMIP > /dev/null' >> /TcTI/SCRIPTS/WATCHDOG/$WATCHDOGVMID.sh
		echo 'if [ $? != 1 ]' >> /TcTI/SCRIPTS/WATCHDOG/$WATCHDOGVMID.sh
		echo 'then' >> /TcTI/SCRIPTS/WATCHDOG/$WATCHDOGVMID.sh
		echo 'echo "Host encontrado"' >> /TcTI/SCRIPTS/WATCHDOG/$WATCHDOGVMID.sh
		echo 'qm status $WATCHDOGVMID' >> /TcTI/SCRIPTS/WATCHDOG/$WATCHDOGVMID.sh
		echo 'else' >> /TcTI/SCRIPTS/WATCHDOG/$WATCHDOGVMID.sh
		echo 'echo "host não encontaado - reiniciando...."' >> /TcTI/SCRIPTS/WATCHDOG/$WATCHDOGVMID.sh
		echo 'qm stop $WATCHDOGVMID' >> /TcTI/SCRIPTS/WATCHDOG/$WATCHDOGVMID.sh
		echo 'qm start $WATCHDOGVMID' >> /TcTI/SCRIPTS/WATCHDOG/$WATCHDOGVMID.sh
		echo 'qm status $WATCHDOGVMID' >> /TcTI/SCRIPTS/WATCHDOG/$WATCHDOGVMID.sh
		echo 'fi' >> /TcTI/SCRIPTS/WATCHDOG/$WATCHDOGVMID.sh
		clear	 
		echo "Monitoramento da VM ativada" 
		read -p "Pressione uma tecla para continuar..."
		clear	  
		watch_dog
			;;	
		5) clear;
		echo "Qual ID da VM? EX: 230"
		read WATCHDOGVMIDDEL
		rm /TcTI/SCRIPTS/WATCHDOG/$WATCHDOGVMIDDEL.sh
		read -p "Pressione uma tecla para continuar..."
		clear
		watch_dog
			;;			
		0) clear;
		tweaks_menu;
			;;				
		*)clear;
		tweaks_menu;
      ;;
      esac
    fi
  done
watch_dog
}

