#!/bin/bash

# Menu para configurar watchdog de VMs

watch_dog(){
	clear
	NORMAL=`echo "\033[m"`
	MENU=`echo "\033[36m"`
	NUMBER=`echo "\033[33m"`
	FGRED=`echo "\033[41m"`
	RED_TEXT=`echo "\033[31m"`
	ENTER_LINE=`echo "\033[33m"`
	
	echo -e "${COLOR_CYAN}${COLOR_BOLD}"
	echo -e "╔═════════════════════════════════════════════════════════════════════╗"
	echo -e "║                                                                     ║"
	echo -e "║                  🐕 Configuração do Watchdog                        ║"
	echo -e "║                                                                     ║"
	echo -e "╚═════════════════════════════════════════════════════════════════════╝"
	echo -e "${COLOR_RESET}"
	echo ""
	echo -e "${COLOR_WHITE}  Watchdog: Monitora VMs e reinicia automaticamente caso offline${COLOR_RESET}"
	echo ""
	echo -e "${COLOR_BOLD}  Selecione uma opção:${COLOR_RESET}"
	echo ""
	echo -e "  ${COLOR_CYAN}┌───────────────────────────────────────────────────────────────┐${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                               ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}1${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Cria agendamento (executa a cada 10 minutos)${COLOR_RESET}     ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}2${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Remove o agendamento${COLOR_RESET}                               ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}3${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Lista VMs monitoradas${COLOR_RESET}                              ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}4${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Adiciona VM ao monitoramento${COLOR_RESET}                       ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}5${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Remove VM do monitoramento${COLOR_RESET}                         ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                               ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_RED}0${COLOR_RESET} ${COLOR_RED}➜${COLOR_RESET}  ${COLOR_WHITE}Voltar${COLOR_RESET}                                              ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                               ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}└───────────────────────────────────────────────────────────────┘${COLOR_RESET}"
	echo ""
	echo -e "${COLOR_YELLOW}  Digite sua opção ${COLOR_GRAY}(ou pressione ENTER para sair)${COLOR_YELLOW}: ${COLOR_RESET}"
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

