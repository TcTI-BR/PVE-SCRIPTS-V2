#!/bin/bash

# Função para destrancar, desligar e reiniciar VMs

destranca_desliga(){
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
	echo -e "║                🔓 Destranca, Desliga e Reinicia VM                   ║"
	echo -e "║                                                                     ║"
	echo -e "╚═════════════════════════════════════════════════════════════════════╝"
	echo -e "${COLOR_RESET}"
	echo ""
	echo -e "${COLOR_BOLD}  Selecione uma opção:${COLOR_RESET}"
	echo ""
	echo -e "  ${COLOR_CYAN}┌───────────────────────────────────────────────────────────────┐${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                               ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}1${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Destranca VM${COLOR_RESET}                                            ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}2${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Destranca e desliga a VM${COLOR_RESET}                                ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}3${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Destranca, desliga e reinicia VM${COLOR_RESET}                        ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                               ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_RED}0${COLOR_RESET} ${COLOR_RED}➜${COLOR_RESET}  ${COLOR_WHITE}Voltar${COLOR_RESET}                                                  ${COLOR_CYAN}│${COLOR_RESET}"
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

