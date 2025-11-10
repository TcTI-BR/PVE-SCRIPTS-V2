#!/bin/bash

# Menu de comandos e informações úteis do Proxmox VE

com_menu(){
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
	echo -e "║               📚 Comandos e Informações Úteis                       ║"
	echo -e "║                                                                     ║"
	echo -e "╚═════════════════════════════════════════════════════════════════════╝"
	echo -e "${COLOR_RESET}"
	echo ""
	echo -e "${COLOR_BOLD}  Selecione uma categoria:${COLOR_RESET}"
	echo ""
	echo -e "  ${COLOR_CYAN}┌───────────────────────────────────────────────────────────────┐${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                               ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}1${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Comandos Linux${COLOR_RESET}                                    ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}2${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Comandos PVE${COLOR_RESET}                                      ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}3${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Caminhos e informações gerais${COLOR_RESET}                     ${COLOR_CYAN}│${COLOR_RESET}"
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

