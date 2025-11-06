#!/bin/bash

# Funções de configurações e ajustes do Proxmox Backup Server

tweaks_pbs_menu(){
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
	echo -e "${MENU}**${NUMBER} 1)${MENU} Verifica temperatura ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 2)${MENU} Configura SWAP ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 3)${MENU} Informações do Host ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 4)${MENU} Instala o script ao carregar o usuario ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 5)${MENU} Remove o script ao carregar o usuario ${NORMAL}"
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
	tweaks_pbs_menu
	;;
	2)clear;
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
  tweaks_pbs_menu
	;;
	3)	clear;
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
  tweaks_pbs_menu	
	;;
	4)	clear;
	echo cd\ > /etc/profile.d/proxmox-ini.sh
	echo cd /TcTI/SCRIPTS >> /etc/profile.d/proxmox-ini.sh
	echo rm proxmox-conf.sh	>> /etc/profile.d/proxmox-ini.sh
	echo wget https://raw.githubusercontent.com/TcTI-BR/PROXMOX-SCRIPTS/main/proxmox-conf.sh >> /etc/profile.d/proxmox-ini.sh
	echo chmod +x proxmox-conf.sh	>> /etc/profile.d/proxmox-ini.sh
	echo ./proxmox-conf.sh	>> /etc/profile.d/proxmox-ini.sh
	chmod +x /etc/profile.d/proxmox-ini.sh
	echo "Script instalado!"		
	read -p "Pressione uma tecla para continuar..."
	clear	  
  tweaks_pbs_menu
	;;
	7)	clear;
	rm /etc/profile.d/proxmox-ini.sh
	echo "Script removido!"
	read -p "Pressione uma tecla para continuar..."
	clear	  
  tweaks_pbs_menu
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

