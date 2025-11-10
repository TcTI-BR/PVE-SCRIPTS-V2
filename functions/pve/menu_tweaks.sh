#!/bin/bash

# Menu de configurações e ajustes do Proxmox VE

tweaks_menu(){
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
	echo -e "║                    ⚙️  Configurações e Ajustes                       ║"
	echo -e "║                                                                     ║"
	echo -e "╚═════════════════════════════════════════════════════════════════════╝"
	echo -e "${COLOR_RESET}"
	echo ""
	echo -e "${COLOR_BOLD}  Selecione uma opção:${COLOR_RESET}"
	echo ""
	echo -e "  ${COLOR_CYAN}┌───────────────────────────────────────────────────────────────┐${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                               ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}1${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Verifica temperatura${COLOR_RESET}                                    ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}2${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Destranca, desliga e reinicia VM${COLOR_RESET}                        ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}3${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Configura SWAP${COLOR_RESET}                                          ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}4${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Informações do Host${COLOR_RESET}                                     ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}5${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Instala/desinstala script no carregamento${COLOR_RESET}               ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}6${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Instala interface gráfica e Chromium${COLOR_RESET}                    ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}7${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Configura o watchdog${COLOR_RESET}                                    ${COLOR_CYAN}│${COLOR_RESET}"
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

