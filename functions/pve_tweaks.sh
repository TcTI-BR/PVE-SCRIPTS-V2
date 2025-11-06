#!/bin/bash

# Funções de configurações e ajustes do Proxmox VE

tweaks_menu(){
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
	echo -e "${MENU}**${NUMBER} 1)${MENU} Verifica temperatura ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 2)${MENU} Destranca, desliga e reinicia VM ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 3)${MENU} Configura SWAP ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 4)${MENU} Informações do Host ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 5)${MENU} Instala ou desinstala o script ao carregar o usuário ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 6)${MENU} Instala interface grafica e o Chromium ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 7)${MENU} Configura o watchdog  ${NORMAL}"
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
		apt install lm-sensors -y
		watch -n 1 sensors
		clear
		tweaks_menu
			;;
		2) clear;
		destranca_desliga
			;;
		3)clear;
		lsblk | grep -qi swap
		swapenabled=$?
	   	if [ $swapenabled -eq 0 ]; then
		read -p "- Gostaria editar ou desativar o swap? s = sim / n = não: " -n 1 -r
		if [[ $REPLY =~ ^[Ss]$ ]]; then
		swapvalue=$(cat /proc/sys/vm/swappiness)
		echo ""
		echo "- Swap esta definido como $swapvalue"
		echo "- Valor recomendado: 1 - O valor mais baixo - menos swap será usado - 0 para usar swap somente quando estiver sem memória"
		echo ""
		echo "- Qual é o novo valor de swap? 0 a 100 "
		read newswapvalue
		echo "- Configurando o swap para $newswapvalue"
		sysctl vm.swappiness=$newswapvalue
		echo "vm.swappiness=$newswapvalue" > /etc/sysctl.d/swappiness.conf
		echo "- Esvaziando o swap - isto pode levar algum tempo"
		swapoff -a
		echo "- Re-habilitando o swap com valor $newswapvalue " 
		swapon -a
		sleep 3	
		fi
		else
		echo " - O sistema não tem swap - Nada a fazer"
		fi
		read -p "Pressione uma tecla para continuar..."
		tweaks_menu
			;;
		4) clear;
		red="\e[31m"
		default="\e[39m"
		white="\e[97m"
		green="\e[32m"
		date=`date`
		load=`cat /proc/loadavg | awk '{print $1}'`
		memory_usage=`free -m | awk '/Mem:/ { total=$2; used=$3 } END { printf("%3.1f%%", used/total*100)}'`
		users=`users | wc -w`
		time=`uptime | grep -ohe 'up .*' | sed 's/,/\ hours/g' | awk '{ printf $2" "$3 }'`
		processes=`ps aux | wc -l`
		ip=`hostname -I | awk '{print $1}'`
		root_usage=`df -h / | awk '/\// {print $(NF-1)}'`
		root_free_space=`df -h / | awk '/\// {print $(NF-4)}'`
		printf "${green}System information as of: ${white}$date \n"
		echo
		printf "${red}System Load${white}:${default}\t%s\t${red}IP Address${white}:${default}\t%s\n" $load $ip
		printf "${red}Memory Usage${white}:${default}\t%s\t${red}System Uptime${white}:${default}\t%s\n" $memory_usage "$time"
		printf "${red}Local Users${white}:${default}\t%s\t${red}Processes${white}:${default}\t%s\n" $users $processes
		echo
		printf "${green}Disk information as of: ${white}$date \n"
		echo
		printf "${red}Usage On /${white}:${default}\t\t%s\t${red}Free On /${white}:${default}\t\t%s\n" $root_usage $root_free_space
		echo
		read -p "Pressione uma tecla para continuar..."
		clear
		tweaks_menu	
			;;
		5) clear;
		instala_script
			;;
		6) clear;
		instala_x			
			;;
		7) clear;
		watch_dog			
			;;					
		0) clear;
		pve_menu;
			;;
		*) clear
		pve_menu;
			;;
      esac
    fi
  done
tweaks_menu
}

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
		
instala_script(){
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
	echo -e "${MENU}**${NUMBER} 1)${MENU} Instala verificação de scripts na inicialização ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 2)${MENU} Desinstala verificação de scripts na inicialização ${NORMAL}"
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
		funcao_instalar_na_inicializacao
			;;
		2) clear;
		# Remove qualquer cron job do script
		(crontab -l 2>/dev/null | grep -v "$SCRIPT_DIR/main.sh update" | crontab -)
		echo "Verificação de scripts na inicialização removida!"
		read -p "Pressione uma tecla para continuar..."
		clear	  
		instala_script
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
instala_script
}

funcao_instalar_na_inicializacao() {
    echo "Configurando verificação de scripts na inicialização..."
    
    # O caminho será /TcTI/SCRIPTS/PROXMOX/main.sh
    MAIN_SCRIPT_PATH="$SCRIPT_DIR/main.sh"
    
    # Remove qualquer cron job antigo
    (crontab -l 2>/dev/null | grep -v "$MAIN_SCRIPT_PATH update" | crontab -)
    
    # Adiciona o novo cron job
    # Ele rodará o main.sh com o parâmetro 'update' na inicialização
    (crontab -l 2>/dev/null; echo "@reboot $MAIN_SCRIPT_PATH update > /var/log/tcti-pve-scripts-update.log 2>&1") | crontab -
    
    echo "Agendado com sucesso."
    echo "Log de atualização será salvo em /var/log/tcti-pve-scripts-update.log"
    read -p "Pressione uma tecla para continuar..."
    clear
    instala_script
}
						
instala_x(){
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
	echo -e "${MENU}**${NUMBER} 1)${MENU} Instala interface grafica e o Chromium ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 2)${MENU} Inicia a interface grafico ${NORMAL}"
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
		apt-get update
		apt-get upgrade -y
		apt-get install xfce4 chromium lightdm -y
		clear	 
		mkdir /root/Desktop
		touch /root/Desktop/"Chromium Web Browser.desktop"
		echo [Desktop Entry] > /root/Desktop/"Chromium Web Browser.desktop"
		echo Version=1.0 >> /root/Desktop/"Chromium Web Browser.desktop"
		echo Type=Application	>> /root/Desktop/"Chromium Web Browser.desktop"
		echo Name=Chromium Web Browser	>> /root/Desktop/"Chromium Web Browser.desktop"
		echo Comment=Access the Internet	>> /root/Desktop/"Chromium Web Browser.desktop"
		echo Exec=/usr/bin/chromium %U --no-sandbox	  "https://127.0.0.1:8006" >> /root/Desktop/"Chromium Web Browser.desktop"
		echo Icon=chromium	>> /root/Desktop/"Chromium Web Browser.desktop"
		echo Path=	>> /root/Desktop/"Chromium Web Browser.desktop"
		echo Terminal=false	>> /root/Desktop/"Chromium Web Browser.desktop"
		echo StartupNotify=true	>> /root/Desktop/"Chromium Web Browser.desktop"
		chmod +x /root/Desktop/"Chromium Web Browser.desktop"
		apt-get install dbus-x11
		systemctl disable display-manager
		clear	 
		echo "Interface grafica instalada!" 
		read -p "Pressione uma tecla para continuar..."
		clear	  
		instala_x
			;;
		2) clear;
		startx
		clear	  
		instala_x
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
  instala_x
}
	
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

